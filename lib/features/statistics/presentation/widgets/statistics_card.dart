import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/circular_progress.dart';
import '../../domain/entities/area_stat.dart';

class StatisticsCard extends StatelessWidget {
  const StatisticsCard({
    super.key,
    required this.stat,
    required this.activitiesCount,
  });

  final AreaStat stat;
  final String activitiesCount;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(stat.area, style: AppTypography.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.space2xs),
                Text(
                  '${stat.month} — $activitiesCount',
                  style: AppTypography.textTheme.labelMedium,
                ),
              ],
            ),
          ),
          CircularProgress(value: stat.percent),
        ],
      ),
    );
  }
}
