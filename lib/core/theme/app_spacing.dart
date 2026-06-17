/// Spacing scale (4pt-based) and corner radii.
///
/// From `wiki/design-system.md`. Values are density-independent points.
abstract final class AppSpacing {
  AppSpacing._();

  static const double space2xs = 4;
  static const double spaceXs = 8;
  static const double spaceSm = 12;
  static const double spaceMd = 16;
  static const double spaceMid = 22;
  static const double spaceLg = 24;
  static const double spaceXl = 32;

  /// Default horizontal screen gutter (left/right padding).
  static const double screenGutter = spaceMd;
}

/// Corner radii. `radiusPill` is intentionally large to fully round controls.
abstract final class AppRadius {
  AppRadius._();

  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double pill = 999;
}
