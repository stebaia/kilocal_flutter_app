part of 'survey_cubit.dart';

enum SurveyStatus { initial, inProgress, completed }

class SurveyState extends Equatable {
  const SurveyState({
    this.status = SurveyStatus.initial,
    this.steps = const [],
    this.currentStep = 0,
    this.answers = const {},
  });

  final SurveyStatus status;
  final List<SurveyStep> steps;
  final int currentStep;
  final Map<int, dynamic> answers;

  SurveyStep? get currentStepData => steps.isNotEmpty && currentStep < steps.length ? steps[currentStep] : null;

  bool get isFirstStep => currentStep == 0;
  bool get isLastStep => currentStep == steps.length - 1;

  SurveyState copyWith({
    SurveyStatus? status,
    List<SurveyStep>? steps,
    int? currentStep,
    Map<int, dynamic>? answers,
  }) {
    return SurveyState(
      status: status ?? this.status,
      steps: steps ?? this.steps,
      currentStep: currentStep ?? this.currentStep,
      answers: answers ?? this.answers,
    );
  }

  @override
  List<Object?> get props => [status, steps, currentStep, answers];
}