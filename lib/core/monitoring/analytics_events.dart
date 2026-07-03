import 'analytics_service.dart';

/// Typed catalog of the app's key analytics events.
///
/// Wrapping [AnalyticsService] here keeps event names and parameter shapes in
/// one place (no stringly-typed calls scattered across cubits) and documents
/// the product funnel: onboarding → path → engagement. Event and parameter
/// names follow Firebase's snake_case convention and length limits (≤40 chars).
class AnalyticsEvents {
  const AnalyticsEvents(this._analytics);

  final AnalyticsService _analytics;

  // --- Auth ---

  /// User successfully logged in. [method] e.g. 'password'.
  Future<void> login({String method = 'password'}) =>
      _analytics.logEvent('login', parameters: {'method': method});

  /// User completed registration.
  Future<void> signUp({String method = 'password'}) =>
      _analytics.logEvent('sign_up', parameters: {'method': method});

  Future<void> logout() => _analytics.logEvent('logout');

  // --- Onboarding / survey ---

  /// The onboarding survey flow was started.
  Future<void> onboardingStarted() => _analytics.logEvent('onboarding_started');

  /// The onboarding survey flow was completed.
  Future<void> onboardingCompleted() =>
      _analytics.logEvent('onboarding_completed');

  /// A survey was submitted. [surveyId] identifies which survey.
  Future<void> surveySubmitted(String surveyId) => _analytics.logEvent(
    'survey_submitted',
    parameters: {'survey_id': surveyId},
  );

  // --- Path (percorso) ---

  /// A path/percorso was started.
  Future<void> pathStarted(String pathId) =>
      _analytics.logEvent('path_started', parameters: {'path_id': pathId});

  /// A path day/step was opened.
  Future<void> pathStepOpened({
    required String pathId,
    required String stepId,
  }) => _analytics.logEvent(
    'path_step_opened',
    parameters: {'path_id': pathId, 'step_id': stepId},
  );

  /// An extra material (video/article) was viewed.
  Future<void> materialViewed(String materialId) => _analytics.logEvent(
    'material_viewed',
    parameters: {'material_id': materialId},
  );

  // --- Engagement ---

  /// A benefit/partner offer was opened.
  Future<void> benefitOpened(String benefitId) => _analytics.logEvent(
    'benefit_opened',
    parameters: {'benefit_id': benefitId},
  );

  /// A diary/moment entry was created.
  Future<void> momentCreated() => _analytics.logEvent('moment_created');

  /// A generic screen view (also emitted automatically by the observer).
  Future<void> screenView(String screenName) =>
      _analytics.logScreenView(screenName);
}
