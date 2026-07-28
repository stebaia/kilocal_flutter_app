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

    /// Clears [errorMessage]. `copyWith(errorMessage: null)` cannot: a null
    /// argument is indistinguishable from "not passed", so it keeps the old
    /// message and a fixed answer would still show the previous error.
    bool clearError = false,
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
  ];
}
