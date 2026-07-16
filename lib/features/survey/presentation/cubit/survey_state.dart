part of 'survey_cubit.dart';

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
      errorMessage: errorMessage ?? this.errorMessage,
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
  ];
}
