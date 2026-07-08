import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class OnboardingSlideData {
  const OnboardingSlideData({required this.title, required this.body});

  final String title;
  final String body;
}

/// The text block (title + body) of an onboarding slide.
///
/// Rendered under the shared red header on the non-final steps (dark text) and
/// over the full-red background on the final step ([onRed] = true, white text).
class OnboardingSlideText extends StatelessWidget {
  const OnboardingSlideText({
    super.key,
    required this.data,
    this.onRed = false,
  });

  final OnboardingSlideData data;
  final bool onRed;

  @override
  Widget build(BuildContext context) {
    final titleColor = onRed ? AppColors.neutralWhite : AppColors.textPrimary;
    final bodyColor = onRed
        ? AppColors.neutralWhite.withValues(alpha: 0.92)
        : AppColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spaceLg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: AppTypography.textTheme.headlineSmall?.copyWith(
              color: titleColor,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.spaceSm),
          Text(
            data.body,
            textAlign: TextAlign.center,
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: bodyColor,
              fontSize: 15,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

/// Clips the white lower panel so its TOP edge dips downward in the middle
/// (concave from the panel's side), letting the red header bulge down as a dome
/// over the illustration. The panel then fills everything below to the bottom.
class OnboardingDomeClipper extends CustomClipper<Path> {
  const OnboardingDomeClipper();

  @override
  Path getClip(Size size) {
    const dip = 110.0;
    final path = Path()
      // Top-left corner, then curve DOWN in the middle so the red header bulges
      // into the white as a downward dome, then back up to the top-right corner.
      ..moveTo(0, 0)
      ..quadraticBezierTo(size.width / 2, dip, size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant OnboardingDomeClipper oldClipper) => false;
}
