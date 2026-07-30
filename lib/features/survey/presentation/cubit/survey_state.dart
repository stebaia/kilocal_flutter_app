part of 'survey_cubit.dart';

/// A product picked at random from the user's own kit, for the barcode step's
/// `{{product}}` placeholder and its code validation (see
/// [SurveyRepository.fetchKitBarcodeProducts]).
class KitBarcodeProduct extends Equatable {
  const KitBarcodeProduct({required this.title, required this.codes});

  final String title;
  final Set<String> codes;

  @override
  List<Object?> get props => [title, codes];
}

enum SurveyStatus {
  initial,
  loading,
  inProgress,
  submitting,
  completed,
  failure,
}

class SurveyState extends Equatable {
  const SurveyState({
    this.status = SurveyStatus.initial,
    this.survey,
    this.visibleSections = const [],
    this.currentIndex = 0,
    this.answers = const {},
    this.selectedPharmacy,
    this.submitResult,
    this.outcomeProfile,
    this.errorMessage,
    this.kitBarcodeProduct,
    this.blockedByStop = false,
    this.stopOriginIndex,
    this.pendingAlert,
    this.confirmedAlertAnswers = const {},
  });

  final SurveyStatus status;
  final Survey? survey;

  /// Sections currently visible given the answers so far (conditions applied).
  final List<SurveySection> visibleSections;

  /// Index into [visibleSections].
  final int currentIndex;

  /// Answers keyed by section id.
  final Map<String, SurveyAnswer> answers;

  /// The Kilocal Point chosen in a `load_kilocal_points` step, sent as
  /// `pharmacy_data`.
  final Pharmacy? selectedPharmacy;

  final SurveySubmitResult? submitResult;

  /// The biotype from [submitResult], hydrated with its `profiles` copy. The
  /// submit response only carries the profile id, so the result screen reads
  /// this rather than `submitResult.biotype`.
  final SurveyOutcome? outcomeProfile;

  final String? errorMessage;

  /// The product picked for the kit proof-of-purchase step (`starter_kit`'s
  /// barcode section, `single_product_barcode_check == false`), or `null`
  /// when not yet resolved / not applicable. See [KitBarcodeProduct].
  final KitBarcodeProduct? kitBarcodeProduct;

  /// Set once a `#stop#`-marked option is confirmed via `next()`: the wizard
  /// is pinned on the survey's last section showing dedicated stop copy
  /// instead of that section's own content, and the CTA no longer advances.
  final bool blockedByStop;

  /// The step index the `#stop#` jump was taken from, so `previous()` can
  /// return straight to the risky question instead of merely decrementing
  /// past unrelated sections in between. `null` when not currently blocked.
  final int? stopOriginIndex;

  /// Non-null while an `#alert#`-marked option's confirmation dialog is
  /// pending — `next()` set it instead of advancing. The UI shows the CMS
  /// dialog and calls `confirmAlert()` / `dismissAlert()`.
  final SurveyAlertModal? pendingAlert;

  /// `"$sectionId:$optionId"` keys already confirmed via the `#alert#`
  /// dialog, so re-visiting an unchanged answer doesn't ask again — only a
  /// *different* risky selection re-prompts.
  final Set<String> confirmedAlertAnswers;

  SurveySection? get currentSection =>
      currentIndex >= 0 && currentIndex < visibleSections.length
      ? visibleSections[currentIndex]
      : null;

  SurveyAnswer? get currentAnswer {
    final section = currentSection;
    return section == null ? null : answers[section.id];
  }

  bool get isFirstStep => currentIndex == 0;
  bool get isLastStep => currentIndex >= visibleSections.length - 1;

  /// Whether the current step may be left: a required question must be
  /// answered and any `other_validations` rule must pass.
  ///
  /// The single source of truth for both the CTA's enabled state and the
  /// cubit's own guard in `next()`, so the button cannot promise something the
  /// cubit will refuse. The `barcode` rule is excluded — it needs a catalogue
  /// read and is checked when the CTA is pressed.
  bool get canLeaveCurrentStep {
    final section = currentSection;
    if (section == null) return false;
    // A Kilocal Point step is answered by picking a pharmacy, not a question.
    if (section.loadKilocalPoints) return selectedPharmacy != null;
    if (currentValidationError != null) return false;
    final question = section.question;
    if (question == null || !question.required) return true;
    final answer = currentAnswer;
    return answer != null && !answer.isEmpty;
  }

  /// The `other_validations` failure of the current answer, or `null` when it
  /// is valid (or empty — see [SurveyValidationRule.validate]).
  ///
  /// `barcode` is excluded: it is checked against the products catalogue when
  /// the user presses the CTA, not while typing.
  SurveyValidationError? get currentValidationError {
    final question = currentSection?.question;
    if (question == null) return null;
    final rule = SurveyValidationRule.parse(question.otherValidations);
    if (rule.isEmpty || rule.isBarcode) return null;
    return rule.validate(currentAnswer?.textValue, heightCm: answeredHeightCm);
  }

  /// The height answered earlier in this survey, for the weight's `bmi` bound.
  /// Located by `user_data_field_name`, as `buildSubmitBody` does.
  ///
  /// Public so the cubit can re-check every step before submitting.
  double? get answeredHeightCm {
    final survey = this.survey;
    if (survey == null) return null;
    for (final section in survey.sections) {
      if (section.userDataFieldName != 'height') continue;
      final raw = answers[section.id]?.textValue;
      if (raw == null || raw.isEmpty) return null;
      return double.tryParse(raw.replaceAll(',', '.'));
    }
    return null;
  }

  /// 0..1 progress across the visible sections.
  double get progress =>
      visibleSections.isEmpty ? 0 : (currentIndex + 1) / visibleSections.length;

  /// The gating marker (`#stop#` / `#alert#`) of the currently selected
  /// option(s) on this step, or `null` when none is selected or its
  /// `result_value` is a plain biotype score.
  ///
  /// Radio/checkbox only: `#stop#` takes priority over `#alert#` when both
  /// somehow appear together (e.g. a multi-select question), since it is the
  /// stricter gate.
  SurveyResultAction? get currentResultAction {
    final question = currentSection?.question;
    if (question == null) return null;
    final selectedIds = currentAnswer?.selectedOptionIds ?? const <String>[];
    if (selectedIds.isEmpty) return null;
    final actions = question.options
        .where((o) => selectedIds.contains(o.id))
        .map((o) => o.resultAction)
        .whereType<SurveyResultAction>()
        .toSet();
    if (actions.contains(SurveyResultAction.stop)) {
      return SurveyResultAction.stop;
    }
    if (actions.contains(SurveyResultAction.alert)) {
      return SurveyResultAction.alert;
    }
    return null;
  }

  /// Key identifying the current step's selection for
  /// [confirmedAlertAnswers], so a *changed* answer re-prompts the alert even
  /// if the previous one had already been confirmed.
  String? get _currentAlertAnswerKey {
    final section = currentSection;
    final selectedIds = currentAnswer?.selectedOptionIds ?? const <String>[];
    if (section == null || selectedIds.isEmpty) return null;
    return '${section.id}:${selectedIds.join(',')}';
  }

  /// Whether the current `#alert#` selection still needs its confirmation
  /// dialog (`false` once already confirmed for this exact answer).
  bool get currentAlertNeedsConfirmation {
    final key = _currentAlertAnswerKey;
    return key == null || !confirmedAlertAnswers.contains(key);
  }

  SurveyState copyWith({
    SurveyStatus? status,
    Survey? survey,
    List<SurveySection>? visibleSections,
    int? currentIndex,
    Map<String, SurveyAnswer>? answers,
    Pharmacy? selectedPharmacy,
    SurveySubmitResult? submitResult,
    SurveyOutcome? outcomeProfile,
    String? errorMessage,
    KitBarcodeProduct? kitBarcodeProduct,
    bool? blockedByStop,
    Set<String>? confirmedAlertAnswers,

    /// Clears [errorMessage]. `copyWith(errorMessage: null)` cannot: a null
    /// argument is indistinguishable from "not passed", so it keeps the old
    /// message and a fixed answer would still show the previous error.
    bool clearError = false,

    /// Sets [pendingAlert]. Plain `pendingAlert: null` cannot clear it — same
    /// null-vs-not-passed ambiguity as [clearError].
    SurveyAlertModal? pendingAlert,
    bool clearPendingAlert = false,

    /// Sets [stopOriginIndex]. Plain `stopOriginIndex: null` cannot clear it —
    /// same null-vs-not-passed ambiguity as [clearError].
    int? stopOriginIndex,
    bool clearStopOriginIndex = false,
  }) {
    return SurveyState(
      status: status ?? this.status,
      survey: survey ?? this.survey,
      visibleSections: visibleSections ?? this.visibleSections,
      currentIndex: currentIndex ?? this.currentIndex,
      answers: answers ?? this.answers,
      selectedPharmacy: selectedPharmacy ?? this.selectedPharmacy,
      submitResult: submitResult ?? this.submitResult,
      outcomeProfile: outcomeProfile ?? this.outcomeProfile,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      kitBarcodeProduct: kitBarcodeProduct ?? this.kitBarcodeProduct,
      blockedByStop: blockedByStop ?? this.blockedByStop,
      stopOriginIndex: clearStopOriginIndex
          ? null
          : (stopOriginIndex ?? this.stopOriginIndex),
      pendingAlert: clearPendingAlert
          ? null
          : (pendingAlert ?? this.pendingAlert),
      confirmedAlertAnswers:
          confirmedAlertAnswers ?? this.confirmedAlertAnswers,
    );
  }

  @override
  List<Object?> get props => [
    status,
    survey,
    visibleSections,
    currentIndex,
    answers,
    selectedPharmacy,
    submitResult,
    outcomeProfile,
    errorMessage,
    kitBarcodeProduct,
    blockedByStop,
    stopOriginIndex,
    pendingAlert,
    confirmedAlertAnswers,
  ];
}
