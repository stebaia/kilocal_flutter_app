import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// The two diary tabs.
enum DiaryTab { history, goals }

/// Segmented control switching between Cronologia and Traguardi.
class DiaryTabSwitch extends StatelessWidget {
  const DiaryTabSwitch({
    super.key,
    required this.selected,
    required this.onChanged,
    required this.historyLabel,
    required this.goalsLabel,
  });

  final DiaryTab selected;
  final ValueChanged<DiaryTab> onChanged;
  final String historyLabel;
  final String goalsLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _TabButton(
            label: historyLabel,
            icon: Icons.menu_book_outlined,
            isSelected: selected == DiaryTab.history,
            onTap: () => onChanged(DiaryTab.history),
          ),
        ),
        const SizedBox(width: AppSpacing.spaceSm),
        Expanded(
          child: _TabButton(
            label: goalsLabel,
            icon: Icons.landscape_outlined,
            isSelected: selected == DiaryTab.goals,
            onTap: () => onChanged(DiaryTab.goals),
          ),
        ),
      ],
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = isSelected ? AppColors.surface : AppColors.textPrimary;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brandPink : AppColors.surface,
          border: Border.all(
            color: isSelected ? AppColors.brandPink : AppColors.borderCard,
          ),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: foreground),
            const SizedBox(width: AppSpacing.spaceXs),
            Text(
              label,
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: foreground,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
