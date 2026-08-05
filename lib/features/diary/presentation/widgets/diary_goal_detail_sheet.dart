import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/diary_goal.dart';

/// Outcome of [showDiaryGoalDetailSheet].
enum DiaryGoalDetailAction { edit, toggleCompleted, delete }

/// "Dettagli Traguardo" bottom sheet opened by tapping a Traguardo card.
///
/// Shows the goal text and offers "Modifica traguardo" (personal goals
/// only — Kilocal predefined goals have no editable content), "Elimina
/// traguardo" (personal goals only — Kilocal ones can't be deleted, only
/// completed/uncompleted) and "Completa traguardo" / "Segna come non
/// raggiunto" (depending on current state).
///
/// Returns the chosen [DiaryGoalDetailAction], or `null` if dismissed.
Future<DiaryGoalDetailAction?> showDiaryGoalDetailSheet(
  BuildContext context, {
  required DiaryGoal goal,
}) {
  return showModalBottomSheet<DiaryGoalDetailAction>(
    context: context,
    backgroundColor: AppColors.surface,
    showDragHandle: true,
    isScrollControlled: true,
    constraints: BoxConstraints(
      maxHeight: MediaQuery.sizeOf(context).height * 0.9,
    ),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
    ),
    builder: (context) => _DiaryGoalDetailSheet(goal: goal),
  );
}

class _DiaryGoalDetailSheet extends StatelessWidget {
  const _DiaryGoalDetailSheet({required this.goal});

  final DiaryGoal goal;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.spaceLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              goal.content ?? '',
              style: AppTypography.textTheme.titleMedium?.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Divider(height: AppSpacing.spaceLg),
            if (goal.kind == DiaryGoalKind.personal) ...[
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
                  onPressed: () =>
                      Navigator.of(context).pop(DiaryGoalDetailAction.edit),
                  child: Text(
                    l10n.diaryGoalEditTitle,
                    style: AppTypography.textTheme.labelLarge?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.spaceSm),
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
                  onPressed: () =>
                      Navigator.of(context).pop(DiaryGoalDetailAction.delete),
                  child: Text(
                    l10n.diaryGoalDelete,
                    style: AppTypography.textTheme.labelLarge?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.spaceSm),
            ],
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
                onPressed: () => Navigator.of(
                  context,
                ).pop(DiaryGoalDetailAction.toggleCompleted),
                child: Text(
                  goal.isCompleted
                      ? l10n.diaryGoalMarkIncomplete
                      : l10n.diaryGoalComplete,
                  style: AppTypography.textTheme.labelLarge?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
