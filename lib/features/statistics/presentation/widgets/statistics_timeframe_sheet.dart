import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/area_stat.dart';

/// Bottom sheet listing the reference area's timeframes (months/phases).
/// Tapping one closes the sheet and returns it; the caller re-fetches every
/// area's progress filtered to that timeframe id.
Future<AreaTimeframe?> showStatisticsTimeframeSheet(
  BuildContext context, {
  required List<AreaTimeframe> timeframes,
  int? selectedTimeframeId,
}) {
  return showModalBottomSheet<AreaTimeframe>(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
    ),
    builder: (_) => _StatisticsTimeframeSheet(
      timeframes: timeframes,
      selectedTimeframeId: selectedTimeframeId,
    ),
  );
}

class _StatisticsTimeframeSheet extends StatelessWidget {
  const _StatisticsTimeframeSheet({
    required this.timeframes,
    this.selectedTimeframeId,
  });

  final List<AreaTimeframe> timeframes;
  final int? selectedTimeframeId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.only(top: AppSpacing.spaceSm),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderCard,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
            const SizedBox(height: AppSpacing.spaceLg),
            if (timeframes.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenGutter,
                  vertical: AppSpacing.spaceLg,
                ),
                child: Text(l10n.errorGeneric),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenGutter,
                ),
                child: Column(
                  children: [
                    for (final timeframe in timeframes)
                      _TimeframeRow(
                        timeframe: timeframe,
                        isSelected: timeframe.id == selectedTimeframeId,
                        onTap: () => Navigator.of(context).pop(timeframe),
                      ),
                  ],
                ),
              ),
            const SizedBox(height: AppSpacing.spaceSm),
          ],
        ),
      ),
    );
  }
}

class _TimeframeRow extends StatelessWidget {
  const _TimeframeRow({
    required this.timeframe,
    required this.isSelected,
    required this.onTap,
  });

  final AreaTimeframe timeframe;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.spaceMd),
        child: Row(
          children: [
            Expanded(
              child: Text(
                timeframe.title,
                style: AppTypography.textTheme.bodyLarge?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check, color: AppColors.accent, size: 22),
          ],
        ),
      ),
    );
  }
}
