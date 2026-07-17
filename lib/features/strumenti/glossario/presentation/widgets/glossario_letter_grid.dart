import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';

/// The A-Z filter grid. The selected letter is a filled brand tile; letters
/// with no terms are dimmed and inert.
///
/// Laid out as plain Rows rather than a shrink-wrapped GridView: a nested
/// scrollable inside the screen's CustomScrollView trips a semantics
/// assertion (`!semantics.parentDataDirty`) on every frame, and 26 fixed
/// tiles never needed to scroll in the first place.
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

  /// Seven per row, as in the design.
  static const _perRow = 7;

  @override
  Widget build(BuildContext context) {
    final letters = _letters.split('');

    return Column(
      children: [
        for (var row = 0; row * _perRow < letters.length; row++) ...[
          if (row > 0) const SizedBox(height: AppSpacing.spaceXs),
          Row(
            children: [
              for (var col = 0; col < _perRow; col++) ...[
                if (col > 0) const SizedBox(width: AppSpacing.spaceXs),
                Expanded(
                  child: row * _perRow + col < letters.length
                      ? _LetterTile(
                          letter: letters[row * _perRow + col],
                          isSelected: letters[row * _perRow + col] == selected,
                          isEnabled:
                              available.contains(letters[row * _perRow + col]),
                          onTap: () => onSelected(letters[row * _perRow + col]),
                        )
                      // Blank filler so the last row's tiles keep the same
                      // width as the full rows.
                      : const SizedBox.shrink(),
                ),
              ],
            ],
          ),
        ],
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

    // Square tile: the Row gives it a width, the aspect ratio sets the height
    // (the GridView cell used to do this).
    return AspectRatio(
      aspectRatio: 1,
      child: GestureDetector(
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
      ),
    );
  }
}
