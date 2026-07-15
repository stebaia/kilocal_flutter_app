import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Red gradient banner at the top of each diary tab, with an info affordance
/// and a decorative 3D illustration on the right, framed in a pink circle.
class DiaryHeroCard extends StatelessWidget {
  const DiaryHeroCard({
    super.key,
    required this.title,
    required this.assetName,
    this.onInfoTap,
  });

  final String title;
  final String assetName;
  final VoidCallback? onInfoTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 148,
      decoration: BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      padding: const EdgeInsets.all(AppSpacing.spaceMd),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.bottomLeft,
            child: Text(
              title,
              style: AppTypography.textTheme.titleLarge?.copyWith(
                color: AppColors.surface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Stack(
              alignment: AlignmentGeometry.center,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  padding: const EdgeInsets.all(AppSpacing.spaceMd),
                  decoration: const BoxDecoration(
                    color: AppColors.kilokalPink,
                    shape: BoxShape.circle,
                  ),
                ),
                Image.asset(
                  assetName,
                  fit: BoxFit.cover,
                  width: 136,
                  height: 136,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
