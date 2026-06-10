import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

/// Tappable card used for preset-answer survey steps (single or multi choice).
/// Highlights in brand accent when [selected] is true.
class SurveyChoiceCard extends StatelessWidget {
  const SurveyChoiceCard({
    super.key,
    required this.label,
    this.selected = false,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.spaceMd,
          vertical: AppSpacing.spaceSm,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.accentSoft : Colors.white,
          border: Border.all(
            color: selected ? AppColors.accent : AppColors.divider,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle, color: AppColors.accent)
            else
              const Icon(Icons.circle_outlined, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}