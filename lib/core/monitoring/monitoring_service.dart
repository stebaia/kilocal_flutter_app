/// Abstraction over crash reporting and performance monitoring.
///
/// The rest of the app depends on this interface rather than Firebase directly,
/// keeping the presentation/data layers decoupled and testable. The production
/// implementation is [FirebaseMonitoringService]; tests and non-Firebase builds
/// can use [NoopMonitoringService].
abstract interface class MonitoringService {
  /// Initializes the underlying SDK (collection toggles, error hooks state).
  /// Called once during app bootstrap, after `Firebase.initializeApp`.
  Future<void> init();

  /// Records a fatal (uncaught) error with its stack trace.
  Future<void> recordError(
    Object error,
    StackTrace? stack, {
    bool fatal = false,
    String? reason,
  });

  /// Records a Flutter framework error (from `FlutterError.onError`).
  Future<void> recordFlutterError(FlutterErrorDetailsLike details);

  /// Leaves a breadcrumb-style log attached to the next crash report.
  Future<void> log(String message);

  /// Associates the current session with a user id (for crash grouping).
  Future<void> setUserId(String? userId);

  /// Sets a custom key/value shown alongside crash reports.
  Future<void> setCustomKey(String key, Object value);

  /// Starts a named performance trace. Returns a handle to stop it later.
  /// Returns `null` when performance monitoring is disabled.
  Future<PerfTrace?> startTrace(String name);
}

/// Minimal, SDK-agnostic view of a Flutter error, so callers don't need to
/// import Firebase types to forward framework errors.
class FlutterErrorDetailsLike {
  const FlutterErrorDetailsLike({
    required this.exception,
    this.stack,
    this.context,
  });

  final Object exception;
  final StackTrace? stack;
  final String? context;
}

/// Handle to an in-flight performance trace.
abstract interface class PerfTrace {
  /// Records a numeric metric on the trace.
  void setMetric(String name, int value);

  /// Attaches a string attribute to the trace.
  void putAttribute(String name, String value);

  /// Stops the trace and reports it.
  Future<void> stop();
}

/// No-op implementation used in tests or when monitoring is intentionally off.
class NoopMonitoringService implements MonitoringService {
  const NoopMonitoringService();

  @override
  Future<void> init() async {}

  @override
  Future<void> recordError(
    Object error,
    StackTrace? stack, {
    bool fatal = false,
    String? reason,
  }) async {}

  @override
  Future<void> recordFlutterError(FlutterErrorDetailsLike details) async {}

  @override
  Future<void> log(String message) async {}

  @override
  Future<void> setUserId(String? userId) async {}

  @override
  Future<void> setCustomKey(String key, Object value) async {}

  @override
  Future<PerfTrace?> startTrace(String name) async => null;
}
