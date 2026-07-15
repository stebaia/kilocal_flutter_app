import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/diary_activity.dart';
import 'diary_area_style.dart';

/// A single Cronologia entry: completion checkbox, coloured category label with
/// icon, time, and the activity text.
///
/// [onTap] opens the "Dettagli Attività" sheet; passed only for entries that can
/// still be acted on (started-but-not-completed steps).
class DiaryHistoryCard extends StatelessWidget {
  const DiaryHistoryCard({super.key, required this.activity, this.onTap});

  final DiaryActivity activity;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final style = DiaryAreaStyle.of(activity.area, l10n);
    final time = _formatTime(activity.completedOn ?? activity.startedOn);

    return AppCard(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CheckBox(isChecked: activity.isCompleted),
          const SizedBox(width: AppSpacing.spaceSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(style.icon, size: 16, color: style.color),
                    const SizedBox(width: AppSpacing.space2xs),
                    Expanded(
                      child: Text(
                        style.label,
                        style: AppTypography.textTheme.labelMedium?.copyWith(
                          color: style.color,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (time != null)
                      Text(
                        time,
                        style: AppTypography.textTheme.labelMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
                if (activity.title != null && activity.title!.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.space2xs),
                  Text(
                    activity.title!,
                    style: AppTypography.textTheme.bodyMedium,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String? _formatTime(DateTime? date) {
    if (date == null) return null;
    final local = date.toLocal();
    final h = local.hour.toString().padLeft(2, '0');
    final m = local.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class _CheckBox extends StatelessWidget {
  const _CheckBox({required this.isChecked});

  final bool isChecked;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isChecked ? const Color(0xFF7AC77A) : AppColors.surface,
        border: Border.all(
          color: isChecked ? const Color(0xFF7AC77A) : AppColors.borderCard,
        ),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Icon(
        Icons.check,
        size: 20,
        color: isChecked ? AppColors.surface : AppColors.borderCard,
      ),
    );
  }
}
