import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/profile_kit.dart';

/// The soft-pink content card used on both the "Il mio Kit" and "Integrazione e
/// prodotti" screens: a centered product image, an accent-colored title, an
/// HTML body ("Come agisce…") and an optional pill "Acquista" button.
///
/// A single card layout drives both screens; the plan card and the product card
/// differ only in the data ([ProfileKit] vs [ProfileKitProduct]).
class ProfileKitContentCard extends StatelessWidget {
  const ProfileKitContentCard({
    super.key,
    required this.title,
    this.description,
    this.imageUrl,
    this.cta,
    this.ctaLabel,
    this.onCtaTap,
  });

  final String title;
  final String? description;
  final String? imageUrl;

  /// The CMS CTA; when present and active it drives the pill button.
  final ProfileKitCta? cta;

  /// Overrides the button label (e.g. "Acquista"); falls back to [cta.label].
  final String? ctaLabel;

  /// Invoked when the CTA is tapped. Disabled when null.
  final VoidCallback? onCtaTap;

  @override
  Widget build(BuildContext context) {
    final label = ctaLabel ?? cta?.label;
    final showCta = label != null && onCtaTap != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.spaceLg),
      decoration: BoxDecoration(
        color: AppColors.accentSoft,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.textTheme.titleMedium?.copyWith(
              color: AppColors.accent,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.spaceMd),
          if (imageUrl != null) ...[
            Container(
              height: 120,
              width: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              padding: const EdgeInsets.all(AppSpacing.spaceSm),
              child: Image.network(
                imageUrl!,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
            const SizedBox(height: AppSpacing.spaceMd),
          ],
          if (description != null && description!.isNotEmpty)
            Html(
              data: description,
              style: {
                'body': Style(
                  margin: Margins.zero,
                  padding: HtmlPaddings.zero,
                  color: AppColors.textSecondary,
                  fontSize: FontSize(
                    AppTypography.textTheme.bodyMedium?.fontSize ?? 14,
                  ),
                  lineHeight: const LineHeight(1.5),
                ),
              },
            ),
          if (showCta) ...[
            const SizedBox(height: AppSpacing.spaceMd),
            _CtaButton(label: label, onTap: onCtaTap!),
          ],
        ],
      ),
    );
  }
}

class _CtaButton extends StatelessWidget {
  const _CtaButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.accent,
          side: const BorderSide(color: AppColors.accent),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.spaceMd),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
        ),
        child: Text(
          label,
          style: AppTypography.textTheme.titleSmall?.copyWith(
            color: AppColors.accent,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
