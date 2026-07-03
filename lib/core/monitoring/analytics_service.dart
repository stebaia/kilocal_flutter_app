/// Abstraction over user-behavior analytics.
///
/// The app logs events through this interface so the analytics backend
/// (Firebase Analytics today, potentially Mixpanel/Amplitude later) stays
/// swappable. Production uses [FirebaseAnalyticsService]; tests use
/// [NoopAnalyticsService].
abstract interface class AnalyticsService {
  /// Logs a named event with optional parameters.
  Future<void> logEvent(String name, {Map<String, Object>? parameters});

  /// Logs a screen view (for navigation funnels).
  Future<void> logScreenView(String screenName);

  /// Associates subsequent events with a user id.
  Future<void> setUserId(String? userId);

  /// Sets a durable user property (segmentation dimension).
  Future<void> setUserProperty(String name, String? value);
}

/// No-op analytics used in tests or when analytics is intentionally off.
class NoopAnalyticsService implements AnalyticsService {
  const NoopAnalyticsService();

  @override
  Future<void> logEvent(String name, {Map<String, Object>? parameters}) async {}

  @override
  Future<void> logScreenView(String screenName) async {}

  @override
  Future<void> setUserId(String? userId) async {}

  @override
  Future<void> setUserProperty(String name, String? value) async {}
}
