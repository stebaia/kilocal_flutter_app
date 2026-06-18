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
}
