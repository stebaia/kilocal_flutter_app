import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../home/presentation/widgets/action_card_illustration.dart';

/// Large red hero card at the top of an area detail: the area icon and title,
/// the `completed/total` figure and the area illustration inside a soft circle.
class PathAreaHeroCard extends StatelessWidget {
  const PathAreaHeroCard({
    super.key,
    required this.title,
    required this.assetName,
    required this.completed,
    required this.total,
    this.icon,
  });

  final String title;
  final String assetName;
  final int completed;
  final int total;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        gradient: AppColors.brandGradientVertical,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.card,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Stack(
          children: [
            // Illustration inside a soft circle on the right.
            Positioned(
              right: -20,
              top: 0,
              bottom: 0,
              child: Center(
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: AppColors.neutralWhite.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: ActionCardIllustration(
                    imageUrl: '',
                    assetName: assetName,
                  ),
                ),
              ),
            ),
            // Title + icon top-left.
            Positioned(
              top: AppSpacing.spaceLg,
              left: AppSpacing.spaceLg,
              child: Row(
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: AppColors.neutralWhite, size: 22),
                    const SizedBox(width: AppSpacing.spaceSm),
                  ],
                  Text(
                    title,
                    style: AppTypography.textTheme.titleMedium?.copyWith(
                      color: AppColors.neutralWhite,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            // Completed/total bottom-left.
            Positioned(
              bottom: AppSpacing.spaceLg,
              left: AppSpacing.spaceLg,
              child: Row(
                children: [
                  const Icon(
                    Icons.bolt,
                    color: AppColors.neutralWhite,
                    size: 22,
                  ),
                  const SizedBox(width: AppSpacing.spaceXs),
                  Text(
                    '$completed/$total',
                    style: AppTypography.textTheme.headlineSmall?.copyWith(
                      color: AppColors.neutralWhite,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
