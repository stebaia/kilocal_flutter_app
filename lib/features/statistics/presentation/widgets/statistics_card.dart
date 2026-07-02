import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_colors.dart';
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
                Row(
                  children: [
                    SvgPicture.asset(stat.assetName, width: 22, height: 22),
                    const SizedBox(width: AppSpacing.spaceXs),
                    Expanded(
                      child: Text(
                        stat.area,
                        style: AppTypography.textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.spaceSm),
                Text(stat.month, style: AppTypography.textTheme.labelMedium),
                const SizedBox(height: AppSpacing.space2xs),
                Text(
                  activitiesCount,
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: AppColors.brandPink,
                    fontWeight: FontWeight.w700,
                  ),
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
