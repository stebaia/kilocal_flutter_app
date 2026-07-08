import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/diary_activity.dart';

/// Client-side label + icon + colour for each of the four fixed path areas.
///
/// The category shown on a history card ("Alimentazione", …) is the path root
/// (`root.internal_name`), not a dynamic `goal_categories` value — so this
/// mapping is intentionally hardcoded (see docs/diario-api-analisi).
class DiaryAreaStyle {
  const DiaryAreaStyle({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;

  static DiaryAreaStyle of(DiaryArea area, AppLocalizations l10n) {
    switch (area) {
      case DiaryArea.allenamento:
        return DiaryAreaStyle(
          label: l10n.areaTraining,
          icon: Icons.fitness_center,
          color: AppColors.accent,
        );
      case DiaryArea.alimentazione:
        return DiaryAreaStyle(
          label: l10n.areaNutrition,
          icon: Icons.restaurant,
          color: AppColors.accent,
        );
      case DiaryArea.benessere:
        return DiaryAreaStyle(
          label: l10n.areaWellbeing,
          icon: Icons.spa_outlined,
          color: AppColors.accent,
        );
      case DiaryArea.integrazione:
        return DiaryAreaStyle(
          label: l10n.areaIntegration,
          icon: Icons.medication_outlined,
          color: AppColors.accent,
        );
      case DiaryArea.unknown:
        return DiaryAreaStyle(
          label: l10n.tabDiary,
          icon: Icons.circle_outlined,
          color: AppColors.textSecondary,
        );
    }
  }
}
