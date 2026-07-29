import 'package:flutter/foundation.dart';

/// Environment configuration (base URLs per flavor).
///
/// The mobile app talks directly to the Directus CMS with Bearer JWT.
/// Override via `--dart-define=API_BASE_URL=...` at build time.
abstract final class Env {
  Env._();

  /// Directus CMS base URL.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://cms-stg.kilocal.thefullproject.it',
  );

  /// Legacy shop base URL. Kept for any direct frontend references; prefer [baseUrl].
  static const String shopUrl = String.fromEnvironment(
    'SHOP_URL',
    defaultValue: 'https://shop.kilocalprogram.it',
  );

  /// Network timeout for connect/receive/send.
  static const Duration timeout = Duration(seconds: 30);

  /// Whether Firebase (Crashlytics/Analytics/Performance/FCM) should be
  /// initialised. The `staging` Android flavor has no app registered in the
  /// Firebase project yet, so it disables this to avoid init failures.
  /// Override with `--dart-define=FIREBASE_ENABLED=true|false`.
  static const bool isFirebaseEnabled = bool.fromEnvironment(
    'FIREBASE_ENABLED',
    defaultValue: true,
  );

  /// Ignores the CMS `is_tool_blocked` kill-switch, so a tool the backend has
  /// switched off can still be opened and tested.
  ///
  /// Debug builds ignore the flag by default (staging ships tools blocked,
  /// which would leave them untestable). Release builds always honour the CMS —
  /// `kReleaseMode` gates this so a tool the backend disabled can never be
  /// shipped open. Override either way with
  /// `--dart-define=IGNORE_TOOL_BLOCKED=true|false`.
  static const bool ignoreToolBlocked = bool.fromEnvironment(
    'IGNORE_TOOL_BLOCKED',
    defaultValue: !kReleaseMode,
  );
}
