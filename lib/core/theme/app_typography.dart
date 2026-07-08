import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Typographic scale mapped onto Material's [TextTheme] using Montserrat.
abstract final class AppTypography {
  AppTypography._();

  static TextTheme get textTheme {
    return GoogleFonts.montserratTextTheme(
      const TextTheme(
        // Screen content title (e.g. "Ciao Mariagiovanna").
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
      ),
    );
  }

  /// Emphasized numeric value in accent red (e.g. "3/15 attività", "80%").
  static TextStyle get numericAccent {
    return GoogleFonts.montserrat(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: AppColors.accent,
    );
  }

  static TextStyle get numericAccentCircular {
    return GoogleFonts.montserrat(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    );
  }

  static TextStyle get numericAccentCircularLarge {
    return GoogleFonts.montserrat(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    );
  }
}
