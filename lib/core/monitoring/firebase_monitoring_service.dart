import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';

import 'monitoring_service.dart';

/// Firebase-backed [MonitoringService]: Crashlytics for crash/error reporting
/// and Performance Monitoring for traces.
///
/// Collection is disabled in debug builds so local runs don't pollute the
/// dashboards; in release/profile builds it is enabled automatically.
class FirebaseMonitoringService implements MonitoringService {
  FirebaseMonitoringService({
    FirebaseCrashlytics? crashlytics,
    FirebasePerformance? performance,
  }) : _crashlytics = crashlytics ?? FirebaseCrashlytics.instance,
       _performance = performance ?? FirebasePerformance.instance;

  final FirebaseCrashlytics _crashlytics;
  final FirebasePerformance _performance;

  /// Collect only outside debug builds. Override with a `--dart-define` if you
  /// need to force-enable Crashlytics while debugging.
  static const bool _collectionEnabled =
      !kDebugMode || bool.fromEnvironment('FIREBASE_MONITORING_IN_DEBUG');

  @override
  Future<void> init() async {
    await _crashlytics.setCrashlyticsCollectionEnabled(_collectionEnabled);
    await _performance.setPerformanceCollectionEnabled(_collectionEnabled);
  }

  @override
  Future<void> recordError(
    Object error,
    StackTrace? stack, {
    bool fatal = false,
    String? reason,
  }) {
    return _crashlytics.recordError(error, stack, reason: reason, fatal: fatal);
  }

  @override
  Future<void> recordFlutterError(FlutterErrorDetailsLike details) {
    return _crashlytics.recordError(
      details.exception,
      details.stack,
      reason: details.context,
      fatal: false,
    );
  }

  @override
  Future<void> log(String message) async {
    _crashlytics.log(message);
  }

  @override
  Future<void> setUserId(String? userId) {
    return _crashlytics.setUserIdentifier(userId ?? '');
  }

  @override
  Future<void> setCustomKey(String key, Object value) {
    return _crashlytics.setCustomKey(key, value);
  }

  @override
  Future<PerfTrace?> startTrace(String name) async {
    if (!_collectionEnabled) return null;
    final trace = _performance.newTrace(name);
    await trace.start();
    return _FirebasePerfTrace(trace);
  }
}

class _FirebasePerfTrace implements PerfTrace {
  _FirebasePerfTrace(this._trace);

  final Trace _trace;

  @override
  void setMetric(String name, int value) => _trace.setMetric(name, value);

  @override
  void putAttribute(String name, String value) =>
      _trace.putAttribute(name, value);

  @override
  Future<void> stop() => _trace.stop();
}
