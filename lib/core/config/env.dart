/// Environment configuration (base URLs per flavor).
///
/// From `wiki/overview.md`: the shop frontend exposes `{SHOP_URL}/api/*` and
/// `{SHOP_URL}/cms/*`. Override via `--dart-define` at build time.
abstract final class Env {
  Env._();

  /// Shop base URL (Nuxt frontend). Hosts `/api/*`, `/cms/*`, `/finder`, `/logout`.
  static const String shopUrl = String.fromEnvironment(
    'SHOP_URL',
    defaultValue: 'https://shop.kilocalprogram.it',
  );

  /// CMS (Directus) base URL. Used for documentation / direct references; the
  /// client normally reaches the CMS through the `{SHOP_URL}/cms/*` proxy.
  static const String cmsUrl = String.fromEnvironment(
    'CMS_URL',
    defaultValue: 'https://cms.kilocalprogram.it',
  );

  /// Network timeout for connect/receive/send.
  static const Duration timeout = Duration(seconds: 30);
}
