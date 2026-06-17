/// Domain entity representing a single step in a survey or onboarding wizard.
/// Completely decoupled from presentation layer concerns.
enum SurveyStepType {
  preset,
  free,
  info,
  kitResult,
  intermezzo,
  proofOfPurchase,
  platformIntro,
}

class SurveyStep {
  const SurveyStep({
    required this.type,
    required this.title,
    this.body,
    this.choices,
    this.hint,
  });

  final SurveyStepType type;
  final String title;
  final String? body;
  final List<String>? choices;
  final String? hint;
}
