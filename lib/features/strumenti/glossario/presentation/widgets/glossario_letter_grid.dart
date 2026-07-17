import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';

/// The A-Z filter grid. The selected letter is a filled brand tile; letters
/// with no terms are dimmed and inert.
class GlossarioLetterGrid extends StatelessWidget {
  const GlossarioLetterGrid({
    super.key,
    required this.selected,
    required this.available,
    required this.onSelected,
  });

  /// Currently filtered letter, or null while a search is active.
  final String? selected;

  /// Letters that have at least one term.
  final Set<String> available;

  final ValueChanged<String> onSelected;

  static const _letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      // Seven per row, as in the design.
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      crossAxisSpacing: AppSpacing.spaceXs,
      mainAxisSpacing: AppSpacing.spaceXs,
      children: [
        for (final letter in _letters.split(''))
          _LetterTile(
            letter: letter,
            isSelected: letter == selected,
            isEnabled: available.contains(letter),
            onTap: () => onSelected(letter),
          ),
      ],
    );
  }
}

class _LetterTile extends StatelessWidget {
  const _LetterTile({
    required this.letter,
    required this.isSelected,
    required this.isEnabled,
    required this.onTap,
  });

  final String letter;
  final bool isSelected;
  final bool isEnabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color background;
    final Color foreground;
    if (isSelected) {
      background = AppColors.accent;
      foreground = AppColors.neutralWhite;
    } else {
      background = AppColors.surface;
      foreground = isEnabled ? AppColors.textPrimary : AppColors.borderCard;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: isEnabled ? onTap : null,
      child: Container(
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: isSelected
              ? null
              : Border.all(color: AppColors.divider),
        ),
        child: Center(
          child: Text(
            letter,
            style: AppTypography.textTheme.titleMedium?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
