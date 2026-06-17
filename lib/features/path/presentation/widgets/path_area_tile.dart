import 'package:flutter/material.dart';

import '../../../../core/icons/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../home/presentation/widgets/action_card_illustration.dart';
import '../../../../l10n/app_localizations.dart';

/// Square gradient card for a path area (training, nutrition, wellbeing,
/// integration) shown on the path screen.
class PathAreaTile extends StatelessWidget {
  const PathAreaTile({
    super.key,
    required this.title,
    required this.assetName,
    required this.completed,
    required this.total,
    this.onTap,
  });

  final String title;
  final String assetName;
  final int completed;
  final int total;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 165,
        decoration: BoxDecoration(
          gradient: AppColors.brandGradientVertical,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: AppShadows.card,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Stack(
            children: [
              // Top-left title.
              Positioned(
                top: AppSpacing.spaceMd,
                left: AppSpacing.spaceMd,
                child: Text(
                  title,
                  style: AppTypography.textTheme.titleMedium?.copyWith(
                    color: AppColors.neutralWhite,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // Center illustration.
              Positioned(
                top: AppSpacing.spaceMd + 24,
                left: 0,
                right: 0,
                child: Center(
                  child: ActionCardIllustration(
                    imageUrl: '',
                    assetName: assetName,
                  ),
                ),
              ),
              // Bottom-left activity counter.
              Positioned(
                bottom: AppSpacing.spaceMd,
                left: AppSpacing.spaceMd,
                child: Text(
                  l10n.activitiesCount(completed, total),
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: AppColors.neutralWhite,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // Bottom-right play button.
              Positioned(
                bottom: AppSpacing.spaceMd,
                right: AppSpacing.spaceMd,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: AppColors.neutralWhite,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: AppIcon(
                      AppIcons.play,
                      size: 12,
                      color: AppColors.accent,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
