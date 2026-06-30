import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/path_material.dart';

/// Horizontal, scrollable category selector for the materials hub. The selected
/// tab is filled with the accent color; the others are outlined chips.
class PathMaterialCategoryTabs extends StatelessWidget {
  const PathMaterialCategoryTabs({
    super.key,
    required this.categories,
    required this.selectedId,
    required this.onSelected,
  });

  final List<PathMaterialCategory> categories;
  final String? selectedId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final category in categories) ...[
            _CategoryChip(
              label: category.title,
              selected: category.id == selectedId,
              onTap: () => onSelected(category.id),
            ),
            if (category != categories.last)
              const SizedBox(width: AppSpacing.spaceSm),
          ],
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
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
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.spaceLg,
          vertical: AppSpacing.spaceSm,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: selected ? AppColors.accent : AppColors.borderCard,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.textTheme.titleMedium?.copyWith(
            color: selected ? AppColors.neutralWhite : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
