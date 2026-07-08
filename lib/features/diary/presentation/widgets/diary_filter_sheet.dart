import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/diary_goal.dart';

/// Bottom-sheet with the four goal filters. Returns the picked [GoalFilter],
/// or `null` if dismissed.
Future<GoalFilter?> showDiaryFilterSheet(
  BuildContext context, {
  required GoalFilter current,
}) {
  return showModalBottomSheet<GoalFilter>(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
    ),
    builder: (context) => _DiaryFilterSheet(current: current),
  );
}

class _DiaryFilterSheet extends StatelessWidget {
  const _DiaryFilterSheet({required this.current});

  final GoalFilter current;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final options = <(GoalFilter, String)>[
      (GoalFilter.all, l10n.diaryFilterAll),
      (GoalFilter.personal, l10n.diaryFilterPersonal),
      (GoalFilter.kilocal, l10n.diaryFilterKilocal),
      (GoalFilter.completed, l10n.diaryFilterCompleted),
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.spaceMd),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppSpacing.spaceMd),
              decoration: BoxDecoration(
                color: AppColors.borderCard,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
            for (final (filter, label) in options)
              ListTile(
                title: Text(label, style: AppTypography.textTheme.bodyMedium),
                trailing: filter == current
                    ? const Icon(Icons.check, color: AppColors.accent)
                    : null,
                onTap: () => Navigator.of(context).pop(filter),
              ),
          ],
        ),
      ),
    );
  }
}
