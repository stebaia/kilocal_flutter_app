import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/diary_activity.dart';
import 'diary_area_style.dart';

/// "Dettagli Attività" bottom-sheet opened by tapping a Cronologia card.
///
/// Shows the step title, its path category and the planned/to-complete date.
/// For a started-but-not-completed step it offers the "Completa attività"
/// button; the caller (diary screen) performs the completion and reloads.
///
/// Returns `true` when the user tapped "Completa attività", otherwise `null`.
Future<bool?> showDiaryActivitySheet(
  BuildContext context, {
  required DiaryActivity activity,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
    ),
    builder: (context) => _DiaryActivitySheet(activity: activity),
  );
}

class _DiaryActivitySheet extends StatelessWidget {
  const _DiaryActivitySheet({required this.activity});

  final DiaryActivity activity;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final style = DiaryAreaStyle.of(activity.area, l10n);
    // Show the completion date on a done step, otherwise the started date.
    final date = activity.completedOn ?? activity.startedOn;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.spaceLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.diaryActivityDetailTitle,
              style: AppTypography.textTheme.titleMedium?.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Divider(height: AppSpacing.spaceLg),
            if (activity.title != null && activity.title!.isNotEmpty)
              Text(activity.title!, style: AppTypography.textTheme.bodyMedium),
            const SizedBox(height: AppSpacing.spaceMd),
            Text(
              l10n.diaryActivityCategory(style.label),
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            if (date != null) ...[
              const SizedBox(height: AppSpacing.spaceMd),
              Text(
                activity.isCompleted
                    ? l10n.diaryActivityPlannedOn(_formatDate(date))
                    : l10n.diaryActivityToComplete(_formatDate(date)),
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: activity.isCompleted
                      ? AppColors.textPrimary
                      : AppColors.accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            if (activity.canComplete) ...[
              const SizedBox(height: AppSpacing.spaceLg),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.borderCard),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.spaceMd,
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l10n.pathStepComplete,
                        style: AppTypography.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.spaceXs),
                      const Icon(Icons.check, size: 18),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _formatDate(DateTime date) {
    final local = date.toLocal();
    final d = local.day.toString().padLeft(2, '0');
    final m = local.month.toString().padLeft(2, '0');
    final y = (local.year % 100).toString().padLeft(2, '0');
    final h = local.hour.toString().padLeft(2, '0');
    final min = local.minute.toString().padLeft(2, '0');
    return '$d/$m/$y - $h:$min';
  }
}
