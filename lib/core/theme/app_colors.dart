import 'package:flutter/material.dart';

/// Brand and surface colors for the app.
///
/// Derived from `wiki/design-system.md` (Figma KILOCAL-PROGRAM). Hex values are
/// sampled from rendered Figma nodes / flow screenshots and are **approximate** —
/// confirm against a proper Figma variables export before treating as final.
abstract final class AppColors {
  AppColors._();

  // --- Brand (gradient theme: splash / onboarding) ---
  static const Color brandPink = Color(0xFFED1A4B);
  static const Color brandCrimson = Color(0xFFC9143C);
  static const Color coral = Color(0xFFFF5A5A);

  // --- Neutrals ---
  static const Color neutralWhite = Color(0xFFFFFFFF);
  static const Color ink = Color(0xFF1A1A1A);

  // --- Light surface palette (in-app screens) ---
  static const Color background = Color(0xFFF4F4F6);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color accent = Color(0xFFE51E4D);
  static const Color accentSoft = Color(0xFFFCE7EC);
  static const Color textPrimary = ink;
  static const Color textSecondary = Color(0xFF6B6B72);
  static const Color divider = Color(0xFFECECEF);

  /// Signature vertical brand gradient (top -> bottom), used full-bleed behind
  /// illustration screens (splash, onboarding).
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [brandPink, brandCrimson],
  );
}
