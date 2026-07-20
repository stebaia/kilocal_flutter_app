import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../domain/entities/glossary_entry.dart';

/// One glossary term as an accordion: a letter badge and the term, expanding
/// to reveal the definition. Expanded, the card takes a brand outline and its
/// title turns brand red.
class GlossarioEntryCard extends StatelessWidget {
  const GlossarioEntryCard({
    super.key,
    required this.entry,
    required this.isExpanded,
    required this.onTap,
  });

  final GlossaryEntry entry;
  final bool isExpanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: isExpanded ? AppColors.accent : AppColors.divider,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.spaceMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _LetterBadge(letter: entry.initial),
                    const SizedBox(width: AppSpacing.spaceSm),
                    Expanded(
                      child: Text(
                        entry.title,
                        style: AppTypography.textTheme.titleMedium?.copyWith(
                          color: isExpanded
                              ? AppColors.accent
                              : AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: AppColors.accent,
                    ),
                  ],
                ),
                if (isExpanded && entry.content.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.spaceSm),
                  Html(
                    data: entry.content,
                    style: {
                      'body': Style(
                        margin: Margins.zero,
                        padding: HtmlPaddings.zero,
                        color: AppColors.textPrimary,
                        fontSize: FontSize(
                          AppTypography.textTheme.bodyMedium?.fontSize ?? 14,
                        ),
                        lineHeight: const LineHeight(1.5),
                      ),
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LetterBadge extends StatelessWidget {
  const _LetterBadge({required this.letter});

  final String letter;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Center(
        child: Text(
          letter,
          style: AppTypography.textTheme.labelLarge?.copyWith(
            color: AppColors.neutralWhite,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
