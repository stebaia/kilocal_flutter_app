import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/monitoring/analytics_events.dart';
import '../../../../core/network/api_exception.dart';
import '../../../path/domain/program_unlock_repository.dart';
import '../../../user/presentation/cubit/user_cubit.dart';
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
    required UserCubit userCubit,
  }) : _repository = repository,
       _analytics = analytics,
       _unlockRepository = unlockRepository,
       _userCubit = userCubit,
       super(const SurveyState());

  final SurveyRepository _repository;
  final AnalyticsEvents _analytics;

  /// Supplies the `use_for_barcode_check` catalogue for `other_validations:
  /// "barcode"` steps that are NOT gated to a specific kit
  /// (`single_product_barcode_check == true`, e.g. the restricted-access
  /// unlock flow). Shared with that sheet so both accept exactly the same
  /// codes.
  final ProgramUnlockRepository _unlockRepository;

  /// Source of the logged-in user's kit id, for the kit proof-of-purchase step
  /// (`single_product_barcode_check == false`) — see [_loadKitBarcodeProduct].
  final UserCubit _userCubit;

  // Matches the other cubit-level messages, which are Italian literals because
  // a Cubit has no BuildContext to reach AppLocalizations from.
  static const _invalidBarcodeMessage =
      'Codice a barre non riconosciuto. Controlla il codice sulla confezione '
      'del tuo Starter Kit.';
  static const _requiredMessage = 'Rispondi a questa domanda per continuare.';
  static const _validationMessage = 'Controlla la risposta per continuare.';

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
      unawaited(_loadKitBarcodeProduct(survey));
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
    // Any answer edit un-pins the `#stop#` block: it can only have been
    // reached by stepping back onto the risky question (see `previous()`),
    // and the user is actively changing that answer.
    emit(
      state.copyWith(
        answers: answers,
        visibleSections: visible,
        blockedByStop: false,
      ),
    );
  }

  // --- Navigation ------------------------------------------------------------

  Future<void> next() async {
    // The UI disables the CTA for these, but the cubit owns the invariant: an
    // unanswered required step or a failed `other_validations` rule must never
    // advance, whatever calls next().
    if (!state.canLeaveCurrentStep) return;

    // A `#stop#`-marked option (e.g. "sei in gravidanza" → "Sì") blocks the
    // survey outright: jump to the last section and show dedicated copy
    // instead of advancing normally. Checked before the barcode/alert gates —
    // there is nothing to confirm or validate past this point.
    if (state.currentResultAction == SurveyResultAction.stop) {
      emit(
        state.copyWith(
          currentIndex: state.visibleSections.length - 1,
          blockedByStop: true,
          stopOriginIndex: state.currentIndex,
        ),
      );
      return;
    }

    // A `#alert#`-marked option requires the CMS confirmation dialog before
    // continuing. The UI shows it and calls confirmAlert()/dismissAlert();
    // next() re-runs and passes once confirmedAlertAnswers has this answer.
    if (state.currentResultAction == SurveyResultAction.alert &&
        state.currentAlertNeedsConfirmation) {
      final modal = await _repository.fetchAlertModal();
      // A missing CMS entity must not trap the user on a step with no dialog
      // to confirm — degrade to letting them through.
      if (modal != null) {
        emit(state.copyWith(pendingAlert: modal));
        return;
      }
    }

    // A `barcode` step is only valid against the products catalogue, so it is
    // checked here rather than while typing.
    if (!await _barcodeAccepted()) return;

    // A `#stop#` block's CTA ("Chiudi") restarts the wizard from its very
    // first step instead of submitting — the answers (including the risky
    // one) are never sent, and there is nowhere else in the app to send the
    // user while `profile_status` still names this survey (any in-app
    // destination would just be bounced back here by the onboarding redirect
    // in router.dart).
    if (state.blockedByStop) {
      emit(
        state.copyWith(
          currentIndex: 0,
          answers: const {},
          blockedByStop: false,
          clearStopOriginIndex: true,
        ),
      );
      return;
    }

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
    // Stepping back off a `#stop#` block must return to the risky question
    // itself, not merely decrement — the jump in next() skipped over
    // whatever sections sat between it and the last one.
    if (state.blockedByStop) {
      emit(
        state.copyWith(
          currentIndex: state.stopOriginIndex ?? state.currentIndex - 1,
          blockedByStop: false,
          clearStopOriginIndex: true,
        ),
      );
      return;
    }
    if (state.currentIndex > 0) {
      emit(state.copyWith(currentIndex: state.currentIndex - 1));
    }
  }

  /// Confirms the pending `#alert#` dialog and re-runs `next()`, which now
  /// finds this answer in [SurveyState.confirmedAlertAnswers] and advances.
  Future<void> confirmAlert() async {
    final key = state._currentAlertAnswerKey;
    emit(
      state.copyWith(
        clearPendingAlert: true,
        confirmedAlertAnswers: key == null
            ? state.confirmedAlertAnswers
            : {...state.confirmedAlertAnswers, key},
      ),
    );
    await next();
  }

  /// Dismisses the pending `#alert#` dialog without confirming: the user
  /// stays on the current step.
  void dismissAlert() {
    emit(state.copyWith(clearPendingAlert: true));
  }

  /// Sends the answers. When [advanceOnly] the wizard stays in progress so the
  /// result section can render the outcome; otherwise the survey is finished.
  ///
  /// Returns whether the submit succeeded.
  Future<bool> _submit({bool advanceOnly = false}) async {
    final survey = state.survey;
    if (survey == null) return false;

    // Guard the whole survey, not just the step being left: next() only ever
    // validates the current step, so a step walked back past — or edited after
    // being passed — would otherwise reach the submit unchecked. This is what
    // let "Fine" through with an unsatisfied barcode.
    final blocking = await _firstUnsatisfiedStep();
    if (blocking != null) {
      emit(
        state.copyWith(
          status: SurveyStatus.inProgress,
          currentIndex: blocking.$1,
          errorMessage: blocking.$2,
        ),
      );
      return false;
    }

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

  /// Validates an `other_validations: "barcode"` step — the proof of
  /// purchase — against the right code source (see [_isKnownBarcode]).
  /// Returns whether the wizard may advance.
  ///
  /// Format alone proves nothing here, so the code must match the catalogue.
  /// On a mismatch the user stays on the step with an error.
  Future<bool> _barcodeAccepted() async {
    final section = state.currentSection;
    final question = section?.question;
    if (section == null || question == null) return true;
    if (!SurveyValidationRule.parse(question.otherValidations).isBarcode) {
      return true;
    }

    final code = state.currentAnswer?.textValue?.trim().toUpperCase() ?? '';
    // An empty code is the `required` check's business, not ours.
    if (code.isEmpty) return true;

    emit(state.copyWith(status: SurveyStatus.submitting, clearError: true));
    final matches = await _isKnownBarcode(code, section);
    emit(
      state.copyWith(
        status: SurveyStatus.inProgress,
        errorMessage: matches ? null : _invalidBarcodeMessage,
        // A newly valid code must clear the previous "not recognised".
        clearError: matches,
      ),
    );
    return matches;
  }

  /// Scans every visible step for one that must not reach the submit, and
  /// returns its `(index, message)` so the wizard can send the user back to it.
  ///
  /// Covers the same rules as [SurveyState.canLeaveCurrentStep] plus the async
  /// `barcode` catalogue check — the point being that the proof of purchase has
  /// to hold when the survey is *sent*, not merely when its step was passed.
  Future<(int, String)?> _firstUnsatisfiedStep() async {
    final sections = state.visibleSections;
    for (var i = 0; i < sections.length; i++) {
      final section = sections[i];
      final question = section.question;
      if (question == null) continue;

      final answer = state.answers[section.id];
      if (question.required && (answer == null || answer.isEmpty)) {
        return (i, _requiredMessage);
      }

      final raw = answer?.textValue;
      final rule = SurveyValidationRule.parse(question.otherValidations);
      if (rule.isBarcode) {
        final code = raw?.trim().toUpperCase() ?? '';
        // Empty is the `required` check's business, handled above.
        if (code.isEmpty) continue;
        if (!await _isKnownBarcode(code, section)) {
          return (i, _invalidBarcodeMessage);
        }
        continue;
      }

      if (rule.validate(raw, heightCm: state.answeredHeightCm) != null) {
        return (i, _validationMessage);
      }
    }
    return null;
  }

  /// Whether [code] is a valid proof of purchase for [section].
  ///
  /// `single_product_barcode_check == false` (the Starter Kit flow, e.g.
  /// `starter_kit`) means the code must match a product from the user's own
  /// kit ([SurveyState.kitBarcodeProduct] — see [_loadKitBarcodeProduct]);
  /// `true` (single-product flows, e.g. the restricted-access unlock) checks
  /// the generic `use_for_barcode_check` catalogue instead. A failed read
  /// returns false: letting an unverified code through would defeat the gate.
  Future<bool> _isKnownBarcode(String code, SurveySection section) async {
    if (!section.singleProductBarcodeCheck) {
      final product = state.kitBarcodeProduct;
      return product != null && product.codes.contains(code);
    }
    try {
      final products = await _unlockRepository.fetchBarcodeProducts();
      return products.any((p) => p.codes.contains(code));
    } on ApiException {
      return false;
    }
  }

  /// Picks a random product from the logged-in user's kit for the Starter
  /// Kit proof-of-purchase step (a section with `other_validations: "barcode"`
  /// and `single_product_barcode_check == false`, e.g. `starter_kit` section
  /// 11) — its title fills `{{product}}` and its barcodes (+ variants) become
  /// the accepted codes for that step, instead of the generic
  /// `use_for_barcode_check` catalogue or the hardcoded "Starter Kit Kilocal".
  ///
  /// A read failure or a survey with no such step leaves [kitBarcodeProduct]
  /// `null` — `_SectionBody` in `survey_screen.dart` then falls back to the
  /// literal "Starter Kit Kilocal" and this step's validation fails closed via
  /// [_isKnownBarcode].
  Future<void> _loadKitBarcodeProduct(Survey survey) async {
    final needsKitProduct = survey.sections.any(
      (s) =>
          !s.singleProductBarcodeCheck &&
          SurveyValidationRule.parse(s.question?.otherValidations).isBarcode,
    );
    if (!needsKitProduct) return;

    final kitId = _userCubit.state.details?.biotype?.kit?.id;
    if (kitId == null) return;

    try {
      final products = await _repository.fetchKitBarcodeProducts(kitId);
      final eligible = products.where((p) => p.codes.isNotEmpty).toList();
      if (eligible.isEmpty) return;
      eligible.shuffle();
      final chosen = eligible.first;
      emit(
        state.copyWith(
          kitBarcodeProduct: KitBarcodeProduct(
            title: chosen.title,
            codes: chosen.codes,
          ),
        ),
      );
    } on ApiException {
      // Swallowed: the step degrades to the literal fallback name and fails
      // validation closed rather than blocking the whole survey from loading.
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
