import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kilocal_flutter_app/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/circular_progress.dart';
import '../../domain/entities/home_data.dart';

class MonthStatsCard extends StatelessWidget {
  const MonthStatsCard({super.key, required this.stats});

  final MonthStats stats;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppCard(
      padding: EdgeInsetsGeometry.all(AppSpacing.spaceLg),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stats.monthLabel,
                  style: AppTypography.textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.spaceXs),
                Text(
                  stats.description,
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.spaceLg),
                GestureDetector(
                  onTap: () => context.push('/statistics'),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.homeSeeStatistics,
                        style: AppTypography.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.spaceXs),
                      const Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: AppColors.textPrimary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: AppSpacing.spaceLg,),
          CircularProgress(value: stats.progress, size: 116, strokeWidth: 12),
        ],
      ),
    );
  }
}
