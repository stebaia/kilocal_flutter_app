import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/path_area_detail.dart';

/// Tile for a single step inside a timeframe expansion.
class PathStepTile extends StatelessWidget {
  const PathStepTile({
    super.key,
    required this.step,
    required this.area,
    this.onTap,
  });

  final PathStepItem step;
  final String area;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isInteractive = !step.isLocked;

    return InkWell(
      onTap: isInteractive ? onTap : null,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Opacity(
        opacity: isInteractive ? 1.0 : 0.5,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.spaceMd,
            vertical: AppSpacing.spaceSm,
          ),
          child: Row(
            children: [
              _StatusIcon(step: step),
              const SizedBox(width: AppSpacing.spaceSm),
              Expanded(
                child: Text(
                  step.title,
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: step.isCurrent
                        ? AppColors.accent
                        : AppColors.textPrimary,
                    fontWeight: step.isCurrent
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),
              if (isInteractive)
                const Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  const _StatusIcon({required this.step});

  final PathStepItem step;

  @override
  Widget build(BuildContext context) {
    if (step.isCompleted) {
      return const Icon(Icons.check_circle, size: 20, color: AppColors.accent);
    }

    if (step.isLocked) {
      return const Icon(Icons.lock, size: 20, color: AppColors.textSecondary);
    }

    if (step.isCurrent) {
      return const Icon(
        Icons.play_circle_fill,
        size: 20,
        color: AppColors.accent,
      );
    }

    return const Icon(
      Icons.radio_button_unchecked,
      size: 20,
      color: AppColors.textSecondary,
    );
  }
}
