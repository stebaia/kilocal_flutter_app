import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Full-bleed brand gradient background used by splash, onboarding, and other
/// branded screens. Optionally overlays a soft radial glow near the top.
class BrandGradientBackground extends StatelessWidget {
  const BrandGradientBackground({
    super.key,
    this.child,
    this.showTopGlow = false,
    this.gradient = AppColors.brandGradient,
  });

  final Widget? child;
  final bool showTopGlow;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: gradient),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (showTopGlow)
            Positioned(
              top: -200,
              left: 0,
              right: 0,
              child: Container(
                height: 500,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.8,
                    colors: [
                      AppColors.brandPink.withValues(alpha: 0.4),
                      AppColors.brandPink.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          // ignore: use_null_aware_elements
          if (child != null) child!,
        ],
      ),
    );
  }
}
