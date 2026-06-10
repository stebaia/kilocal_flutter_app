import 'package:flutter/material.dart';

/// Elevation / shadow tokens for the light theme.
///
/// From `wiki/design-system.md`. Opacities and blur are approximate — confirm
/// against the Figma effect styles.
abstract final class AppShadows {
  AppShadows._();

  /// Soft shadow for white cards on the light background.
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x0F000000), // black @ ~6%
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  /// Shadow on the top edge of the bottom navigation bar.
  static const List<BoxShadow> bar = [
    BoxShadow(
      color: Color(0x0A000000), // black @ ~4%
      blurRadius: 12,
      offset: Offset(0, -2),
    ),
  ];
}
