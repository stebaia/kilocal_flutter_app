import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/path_area_detail.dart';

/// A single timeframe row (e.g. "Primo mese") in the area detail list.
///
/// Renders a square percentage badge on the left, the title and subtitle in the
/// middle and a chevron on the right. A vertical timeline connector is drawn
/// between consecutive badges via [showConnectorTop]/[showConnectorBottom]; the
/// connectors stretch to fill the row height so the line is continuous.
class PathTimeframeRow extends StatelessWidget {
  const PathTimeframeRow({
    super.key,
    required this.group,
    required this.subtitle,
    required this.onTap,
    this.showConnectorTop = false,
    this.showConnectorBottom = false,
  });

  final PathTimeframeGroup group;
  final String subtitle;

  /// Tap handler; pass `null` (e.g. for a locked month) to disable the row.
  final VoidCallback? onTap;
  final bool showConnectorTop;
  final bool showConnectorBottom;

  static const double _badgeSize = 52;

  @override
  Widget build(BuildContext context) {
    final isLocked = group.isLocked;

    return InkWell(
      onTap: isLocked ? null : onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Opacity(
        opacity: isLocked ? 0.5 : 1.0,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _BadgeWithConnector(
                group: group,
                showConnectorTop: showConnectorTop,
                showConnectorBottom: showConnectorBottom,
              ),
              const SizedBox(width: AppSpacing.spaceMd),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.spaceMd,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.title,
                        style: AppTypography.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: group.isCurrent ? AppColors.accent : null,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: AppTypography.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Icon(
                isLocked ? Icons.lock : Icons.chevron_right,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BadgeWithConnector extends StatelessWidget {
  const _BadgeWithConnector({
    required this.group,
    required this.showConnectorTop,
    required this.showConnectorBottom,
  });

  final PathTimeframeGroup group;
  final bool showConnectorTop;
  final bool showConnectorBottom;

  @override
  Widget build(BuildContext context) {
    final isLocked = group.isLocked;
    final isCurrent = group.isCurrent;

    return SizedBox(
      width: PathTimeframeRow._badgeSize,
      child: Column(
        children: [
          Expanded(child: _Connector(visible: showConnectorTop)),
          Container(
            width: PathTimeframeRow._badgeSize,
            height: PathTimeframeRow._badgeSize,
            decoration: BoxDecoration(
              color: isLocked ? AppColors.background : AppColors.accentSoft,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: isLocked ? AppColors.borderCard : AppColors.accent,
                width: isCurrent ? 2 : 1,
              ),
            ),
            alignment: Alignment.center,
            child: isLocked
                ? const Icon(
                    Icons.lock,
                    size: 20,
                    color: AppColors.textSecondary,
                  )
                : Text(
                    '${group.percent}%',
                    style: AppTypography.textTheme.labelMedium?.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
          Expanded(child: _Connector(visible: showConnectorBottom)),
        ],
      ),
    );
  }
}

class _Connector extends StatelessWidget {
  const _Connector({required this.visible});

  final bool visible;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    return Center(child: Container(width: 2, color: AppColors.dividerStrong));
  }
}
