import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Typographic scale, mapped onto Material's [TextTheme].
///
/// From `wiki/design-system.md`. Single sans-serif family across the app; the
/// exact family and sizes are **to confirm** with the design team. [fontFamily]
/// is left null to use the platform default until the brand font is added.
abstract final class AppTypography {
  AppTypography._();

  static const String? fontFamily = null;

  static const TextTheme textTheme = TextTheme(
    // Screen content title (e.g. "Lorem ipsimd dpawojd").
    headlineLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      height: 1.25,
    ),
    // App-bar title.
    titleLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    // Card title / section heading.
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    // Paragraph / body copy.
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
      height: 1.4,
    ),
    // Secondary labels / metadata (e.g. "Mese 1").
    labelMedium: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: AppColors.textSecondary,
    ),
  );

  /// Emphasized numeric value in accent red (e.g. "3/15 attività", "80%").
  /// Not part of the Material [TextTheme]; use directly where needed.
  static const TextStyle numericAccent = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.accent,
  );
}
