import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/monitoring/analytics_events.dart';
import '../../../../core/network/api_exception.dart';
import '../../../path/domain/program_unlock_repository.dart';
import '../../domain/entities/pharmacy.dart';
import '../../domain/entities/survey_answer.dart';
import '../../domain/entities/survey_outcome.dart';
import '../../domain/entities/survey_step.dart';
import '../../domain/survey_repository.dart';
import '../../domain/survey_validation.dart';

part 'survey_state.dart';

/// Drives the CMS-defined survey wizard: loads the survey, applies section
/// visibility conditions, collects answers, and submits.
class SurveyCubit extends Cubit<SurveyState> {
  SurveyCubit({
    required SurveyRepository repository,
    required AnalyticsEvents analytics,
    required ProgramUnlockRepository unlockRepository,
  }) : _repository = repository,
       _analytics = analytics,
       _unlockRepository = unlockRepository,
       super(const SurveyState());

  final SurveyRepository _repository;
  final AnalyticsEvents _analytics;

  /// Supplies the `use_for_barcode_check` catalogue for `other_validations:
  /// "barcode"` steps. Shared with the restricted-access unlock sheet so both
  /// accept exactly the same codes.
  final ProgramUnlockRepository _unlockRepository;

  // Matches the other cubit-level messages, which are Italian literals because
  // a Cubit has no BuildContext to reach AppLocalizations from.
  static const _invalidBarcodeMessage =
      'Codice a barre non riconosciuto. Controlla il codice sulla confezione '
      'del tuo Starter Kit.';

  /// Loads the survey [internalName] and starts the wizard.
  Future<void> start(String internalName) async {
    emit(state.copyWith(status: SurveyStatus.loading, clearError: true));
    unawaited(_analytics.onboardingStarted());
    try {
      // Ensure the user_details row exists before collecting answers.
      await _repository.ensureDetails();
      final survey = await _repository.fetchSurvey(internalName);
      emit(
        state.copyWith(
          status: SurveyStatus.inProgress,
          survey: survey,
          answers: const {},
          currentIndex: 0,
          visibleSections: _computeVisible(survey, const {}),
        ),
      );
    } on ApiException catch (e) {
      emit(
        state.copyWith(
          status: SurveyStatus.failure,
          errorMessage: e.message ?? 'Errore nel caricamento del questionario',
        ),
      );
    }
  }

  // --- Answer mutation -------------------------------------------------------

  /// Toggles a radio option (single selection).
  void selectRadio(SurveyOption option) {
    final section = state.currentSection;
    if (section == null) return;
    _updateAnswer(
      section,
      (a) => a.copyWith(
        selectedOptionIds: [option.id],
        optionValuesToStore: [option.valueToStore ?? ''],
      ),
    );
  }

  /// Toggles a checkbox option (multi selection), honoring [deselectOthers].
  void toggleCheckbox(SurveyOption option) {
    final section = state.currentSection;
    final question = section?.question;
    if (section == null || question == null) return;

    final current = state.answers[section.id];
    final selected = List<String>.from(current?.selectedOptionIds ?? const []);

    if (option.deselectOthers) {
      // Selecting an exclusive option ("Nessuna") clears everything else.
      final next = selected.contains(option.id) ? <String>[] : [option.id];
      _setSelection(section, question, next);
      return;
    }

    if (selected.contains(option.id)) {
      selected.remove(option.id);
    } else {
      // Adding a normal option removes any exclusive (deselect_others) option.
      selected
        ..removeWhere(
          (id) => question.options
              .firstWhere((o) => o.id == id, orElse: () => option)
              .deselectOthers,
        )
        ..add(option.id);
    }
    _setSelection(section, question, selected);
  }

  void _setSelection(
    SurveySection section,
    SurveyQuestion question,
    List<String> ids,
  ) {
    final byId = {for (final o in question.options) o.id: o};
    _updateAnswer(
      section,
      (a) => a.copyWith(
        selectedOptionIds: ids,
        optionValuesToStore: [
          for (final id in ids) byId[id]?.valueToStore ?? '',
        ],
      ),
    );
  }

  void setText(String value) {
    final section = state.currentSection;
    if (section == null) return;
    _updateAnswer(section, (a) => a.copyWith(textValue: value));
  }

  void setOtherValue(String value) {
    final section = state.currentSection;
    if (section == null) return;
    _updateAnswer(section, (a) => a.copyWith(otherValue: value));
  }

  void setScale(int value) {
    final section = state.currentSection;
    if (section == null) return;
    _updateAnswer(section, (a) => a.copyWith(scaleValue: value));
  }

  /// Searches Kilocal Point pharmacies for the picker (server-side search).
  Future<List<Pharmacy>> searchPharmacies(String query) {
    return _repository.searchPharmacies(query);
  }

  /// Stores the pharmacy chosen in a `load_kilocal_points` step.
  void selectPharmacy(Pharmacy pharmacy) {
    emit(state.copyWith(selectedPharmacy: pharmacy));
  }

  void _updateAnswer(
    SurveySection section,
    SurveyAnswer Function(SurveyAnswer) mutate,
  ) {
    final answers = Map<String, SurveyAnswer>.from(state.answers);
    final existing =
        answers[section.id] ??
        SurveyAnswer(
          sectionId: section.id,
          storeToField: section.storeInUserData
              ? section.userDataFieldName
              : null,
        );
    answers[section.id] = mutate(existing);

    // Re-evaluate conditional visibility whenever an answer changes.
    final survey = state.survey;
    final visible = survey == null
        ? state.visibleSections
        : _computeVisible(survey, answers);
    emit(state.copyWith(answers: answers, visibleSections: visible));
  }

  // --- Navigation ------------------------------------------------------------

  Future<void> next() async {
    // The UI disables the CTA for these, but the cubit owns the invariant: an
    // unanswered required step or a failed `other_validations` rule must never
    // advance, whatever calls next().
    if (!state.canLeaveCurrentStep) return;

    // A `barcode` step is only valid against the products catalogue, so it is
    // checked here rather than while typing.
    if (!await _barcodeAccepted()) return;

    if (state.isLastStep) {
      // Already on the final screen: a result section has had its outcome since
      // we advanced onto it, so there is nothing left to send.
      if (state.currentSection?.kind == SurveySectionKind.result) {
        emit(state.copyWith(status: SurveyStatus.completed));
        return;
      }
      await _submit();
      return;
    }

    // The result section renders the biotype outcome, so the answers must be
    // submitted *before* it is shown — not when leaving it (which would land
    // the user on a blank result and only fetch the data on the way out).
    final next = state.visibleSections[state.currentIndex + 1];
    if (next.kind == SurveySectionKind.result && state.submitResult == null) {
      final submitted = await _submit(advanceOnly: true);
      if (!submitted) return;
    }
    emit(state.copyWith(currentIndex: state.currentIndex + 1));
  }

  void previous() {
    if (state.currentIndex > 0) {
      emit(state.copyWith(currentIndex: state.currentIndex - 1));
    }
  }

  /// Sends the answers. When [advanceOnly] the wizard stays in progress so the
  /// result section can render the outcome; otherwise the survey is finished.
  ///
  /// Returns whether the submit succeeded.
  Future<bool> _submit({bool advanceOnly = false}) async {
    final survey = state.survey;
    if (survey == null) return false;
    emit(state.copyWith(status: SurveyStatus.submitting, clearError: true));
    try {
      final result = await _repository.submit(
        internalName: survey.internalName,
        answers: state.visibleSections
            .map((s) => state.answers[s.id])
            .whereType<SurveyAnswer>()
            .toList(),
        survey: survey,
        pharmacy: state.selectedPharmacy,
      );
      await _analytics.surveySubmitted(survey.internalName);
      await _analytics.onboardingCompleted();
      emit(
        state.copyWith(
          status: advanceOnly
              ? SurveyStatus.inProgress
              : SurveyStatus.completed,
          submitResult: result,
          outcomeProfile: await _hydrateOutcome(result),
        ),
      );
      return true;
    } on ApiException catch (e) {
      emit(
        state.copyWith(
          status: SurveyStatus.inProgress,
          errorMessage: e.message ?? "Errore nell'invio del questionario",
        ),
      );
      return false;
    }
  }

  /// Validates an `other_validations: "barcode"` step against the products
  /// flagged `use_for_barcode_check` — the proof of purchase for the starter
  /// kit. Returns whether the wizard may advance.
  ///
  /// Format alone proves nothing here, so the code must match the catalogue,
  /// exactly as the restricted-access unlock sheet requires. On a mismatch the
  /// user stays on the step with an error.
  Future<bool> _barcodeAccepted() async {
    final question = state.currentSection?.question;
    if (question == null) return true;
    if (!SurveyValidationRule.parse(question.otherValidations).isBarcode) {
      return true;
    }

    final code = state.currentAnswer?.textValue?.trim().toUpperCase() ?? '';
    // An empty code is the `required` check's business, not ours.
    if (code.isEmpty) return true;

    emit(state.copyWith(status: SurveyStatus.submitting, clearError: true));
    try {
      final products = await _unlockRepository.fetchBarcodeProducts();
      final matches = products.any((p) => p.codes.contains(code));
      emit(
        state.copyWith(
          status: SurveyStatus.inProgress,
          errorMessage: matches ? null : _invalidBarcodeMessage,
          // A newly valid code must clear the previous "not recognised".
          clearError: matches,
        ),
      );
      return matches;
    } on ApiException catch (e) {
      emit(
        state.copyWith(
          status: SurveyStatus.inProgress,
          errorMessage: e.message ?? _invalidBarcodeMessage,
        ),
      );
      return false;
    }
  }

  /// Loads the biotype's CMS copy for the result screen.
  ///
  /// The submit response references the profile by id only, so the texts and
  /// images need a second read. A failure here is swallowed: the result screen
  /// still shows the survey's own copy, and losing the biotype text is better
  /// than failing a submit that already succeeded server-side.
  Future<SurveyOutcome?> _hydrateOutcome(SurveySubmitResult result) async {
    final outcome = result.biotype;
    if (outcome == null) return null;
    try {
      return await _repository.fetchOutcomeProfile(
        outcome,
        gender: _genderFromAnswers(),
      );
    } on ApiException {
      return outcome;
    }
  }

  /// The gender answer (`value_to_store` of the `is_gender_question` section),
  /// which selects the `content` / `content_f` variant. Read from the answers
  /// rather than `user_details`, which the submit has only just written.
  String? _genderFromAnswers() {
    final survey = state.survey;
    if (survey == null) return null;
    for (final section in survey.sections) {
      if (!section.isGenderQuestion) continue;
      final values = state.answers[section.id]?.optionValuesToStore;
      if (values != null && values.isNotEmpty && values.first.isNotEmpty) {
        return values.first;
      }
    }
    return null;
  }

  // --- Conditions ------------------------------------------------------------

  /// Recomputes which sections are visible given [answers], applying each
  /// section's [SurveySection.conditions] and [SurveySection.conditionAction].
  ///
  /// Currently the CMS only expresses `_eq` against selected option ids
  /// (e.g. show "menopausa" only when gender == Femmina). Unconditional sections
  /// are always visible.
  static List<SurveySection> _computeVisible(
    Survey survey,
    Map<String, SurveyAnswer> answers,
  ) {
    final selectedIds = <String>{
      for (final a in answers.values) ...a.selectedOptionIds,
    };

    // TODO(survey-menopausa): rimuovere questo filtro età hardcoded quando il
    // backend aggiunge la condition età alle section menopausa nel CMS (oggi
    // hanno solo la condition genere==Femmina). La regola richiesta è: mostrare
    // la domanda menopausa SOLO a profili femminili con età > 35. Il vincolo
    // "femminile" arriva già dalle condition dell'API; qui aggiungiamo solo il
    // gate età>35 finché il CMS non lo esprime da sé (vedi survey-feature-status).
    final age = _ageFromAnswers(survey, answers);

    return survey.sections.where((section) {
      // Gate età>35 additivo per la menopausa (temporaneo, vedi TODO sopra).
      // Se non conosciamo ancora l'età (DOB non risposta) o è <= 35, nascondi.
      if (section.isMenopausaQuestion && (age == null || age <= 35)) {
        return false;
      }
      if (section.conditions.isEmpty) return true;
      final matched = section.conditions.any(
        (c) => _conditionMatches(c, selectedIds),
      );
      // condition_action "show" → visible only when matched; "hide" → the
      // inverse.
      return section.conditionAction == 'hide' ? !matched : matched;
    }).toList();
  }

  /// TODO(survey-menopausa): rimuovere insieme al filtro età hardcoded sopra.
  /// Deriva l'età in anni interi dalla risposta alla section DOB
  /// ([SurveySection.isDobQuestion]), o null se non ancora risposta / non
  /// parsabile. Stessa logica di `_computeAge` nel mapper del submit.
  static int? _ageFromAnswers(
    Survey survey,
    Map<String, SurveyAnswer> answers,
  ) {
    final dobSection = survey.sections
        .where((s) => s.isDobQuestion)
        .cast<SurveySection?>()
        .firstWhere((s) => s != null, orElse: () => null);
    if (dobSection == null) return null;
    final raw = answers[dobSection.id]?.textValue;
    if (raw == null || raw.isEmpty) return null;
    final dob = DateTime.tryParse(raw);
    if (dob == null) return null;
    final now = DateTime.now();
    var age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
  }

  static bool _conditionMatches(SurveyCondition c, Set<String> selectedIds) {
    final targets = <String>{
      if (c.valueOptionId != null) c.valueOptionId!,
      ...c.valueOptionIds,
    };
    if (targets.isEmpty) return false;
    // `_eq` / set-membership: any target option currently selected satisfies it.
    return targets.any(selectedIds.contains);
  }
}
