import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

import 'analytics_service.dart';

/// Firebase-backed [AnalyticsService].
///
/// Collection is disabled in debug builds so local runs don't pollute the
/// analytics dashboards. Override with `--dart-define=FIREBASE_ANALYTICS_IN_DEBUG=true`.
class FirebaseAnalyticsService implements AnalyticsService {
  FirebaseAnalyticsService({FirebaseAnalytics? analytics})
    : _analytics = analytics ?? FirebaseAnalytics.instance;

  final FirebaseAnalytics _analytics;

  static const bool _collectionEnabled =
      !kDebugMode || bool.fromEnvironment('FIREBASE_ANALYTICS_IN_DEBUG');

  /// Must be called during bootstrap.
  Future<void> init() {
    return _analytics.setAnalyticsCollectionEnabled(_collectionEnabled);
  }

  /// Exposes the observer so navigation can auto-log screen views if desired.
  FirebaseAnalyticsObserver get navigatorObserver =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  @override
  Future<void> logEvent(String name, {Map<String, Object>? parameters}) {
    return _analytics.logEvent(name: name, parameters: parameters);
  }

  @override
  Future<void> logScreenView(String screenName) {
    return _analytics.logScreenView(screenName: screenName);
  }

  @override
  Future<void> setUserId(String? userId) {
    return _analytics.setUserId(id: userId);
  }

  @override
  Future<void> setUserProperty(String name, String? value) {
    return _analytics.setUserProperty(name: name, value: value);
  }
}
