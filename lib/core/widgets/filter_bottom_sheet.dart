import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// A generic filter option shown inside [FilterBottomSheet].
class FilterOption<T> {
  const FilterOption({required this.value, required this.label});

  final T value;
  final String label;
}

/// Reusable bottom sheet that lets the user pick one option from a list.
///
/// Returns the selected value or `null` if the sheet is dismissed without
/// making a selection.
class FilterBottomSheet {
  FilterBottomSheet._();

  static Future<T?> show<T>({
    required BuildContext context,
    required List<FilterOption<T>> options,
    required T selected,
  }) async {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (context) =>
          _FilterBottomSheetBody<T>(options: options, selected: selected),
    );
  }
}

class _FilterBottomSheetBody<T> extends StatelessWidget {
  const _FilterBottomSheetBody({required this.options, required this.selected});

  final List<FilterOption<T>> options;
  final T selected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.only(bottom: AppSpacing.spaceMd),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AppSpacing.spaceSm),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.spaceMd),
          ...options.map((option) {
            final isSelected = option.value == selected;
            return InkWell(
              onTap: () => Navigator.of(context).pop(option.value),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenGutter,
                  vertical: AppSpacing.spaceXs,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        option.label,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (isSelected)
                      Icon(Icons.check, color: AppColors.accent, size: 20),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: AppSpacing.spaceMd),
        ],
      ),
    );
  }
}
