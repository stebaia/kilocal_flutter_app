import 'package:flutter/material.dart';

/// Brand and surface colors for the app.
///
/// Derived from `wiki/design-system.md` (Figma KILOCAL-PROGRAM). Hex values are
/// sampled from rendered Figma nodes / flow screenshots and are **approximate** —
/// confirm against a proper Figma variables export before treating as final.
abstract final class AppColors {
  AppColors._();

  // --- Brand (gradient theme: splash / onboarding) ---
  static const Color brandPink = Color(0xFFC7153B);
  static const Color brandCrimson = Color(0xFFFF3D66);
  static const Color coral = Color(0xFFFF5A5A);

  // --- Neutrals ---
  static const Color neutralWhite = Color(0xFFFFFFFF);
  static const Color ink = Color(0xFF383838);

  // --- Light surface palette (in-app screens) ---
  static const Color background = Color(0xFFF4F4F6);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color accent = Color(0xFFE51E4D);
  static const Color accentSoft = Color(0xFFFCE7EC);
  static const Color borderCard = Color(0xFFC2C2C2);
  static const Color textPrimary = ink;
  static const Color textSecondary = Color(0xFF6B6B72);
  static const Color divider = Color(0xFFEDEDED);
  static const Color unreadBackground = Color(0xFFFFF9FA);

  /// Signature vertical brand gradient (top -> bottom), used full-bleed behind
  /// illustration screens (splash, onboarding).
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [brandPink, brandCrimson],
  );

  /// Vertical variant of the brand gradient, used on home action cards.
  static const LinearGradient brandGradientVertical = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [brandPink, brandCrimson],
  );
}
