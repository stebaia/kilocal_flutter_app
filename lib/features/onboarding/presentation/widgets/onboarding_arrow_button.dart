import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Small circular arrow button used for onboarding back/forward navigation.
///
/// Always a solid brand-red circle with a white glyph. A `null` [onPressed]
/// dims it slightly and disables taps (used for the back control on the first
/// step). Set [light] on the final red step so the circle becomes translucent
/// white to stay visible over the red background.
class OnboardingArrowButton extends StatelessWidget {
  const OnboardingArrowButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.light = false,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final bool light;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final background = light
        ? AppColors.neutralWhite.withValues(alpha: 0.2)
        : AppColors.accent;

    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: Material(
        color: background,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox(
            width: 36,
            height: 36,
            child: Icon(icon, color: AppColors.neutralWhite, size: 14),
          ),
        ),
      ),
    );
  }
}
