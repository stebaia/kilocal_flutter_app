import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/diary_goal.dart';

/// A single Traguardo card: date, Personale/Kilocal badge, text, and a
/// "Raggiunto" chip once completed. Tap opens the "Dettagli Traguardo" sheet
/// (Elimina/Completa) rather than toggling completion directly.
class DiaryGoalCard extends StatelessWidget {
  const DiaryGoalCard({super.key, required this.goal, this.onTap});

  final DiaryGoal goal;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isKilocal = goal.kind == DiaryGoalKind.kilocal;

    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (goal.dueDate != null)
                Text(
                  _formatDate(goal.dueDate!),
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              const Spacer(),
              if (goal.isCompleted)
                _Badge(
                  label: l10n.diaryGoalCompleted,
                  color: const Color(0xFF7AC77A),
                  filled: true,
                )
              else
                _Badge(
                  label: isKilocal
                      ? l10n.diaryGoalKilocal
                      : l10n.diaryGoalPersonal,
                  color: isKilocal ? AppColors.accent : AppColors.textSecondary,
                  filled: isKilocal,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.spaceSm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(Icons.flag_outlined, color: AppColors.accent),
              ),
              const SizedBox(width: AppSpacing.spaceMd),
              Expanded(
                child: Text(
                  goal.content ?? '',
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d/$m';
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.color,
    required this.filled,
  });

  final String label;
  final Color color;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.spaceSm,
        vertical: AppSpacing.space2xs,
      ),
      decoration: BoxDecoration(
        color: filled ? color : AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label,
        style: AppTypography.textTheme.labelMedium?.copyWith(
          color: filled ? AppColors.surface : AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
