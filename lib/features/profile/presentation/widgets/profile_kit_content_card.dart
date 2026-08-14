import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/readable_color.dart';
import '../../domain/entities/profile_kit.dart';
import '../../../../../core/widgets/cms_image.dart';

/// The soft-tinted content card used on both the "Il mio Kit" and "Integrazione
/// e prodotti" screens: a centered product image, an accent-colored title, an
/// HTML body ("Come agisce…") and an optional pill "Acquista" button.
///
/// A single card layout drives both screens; the plan card and the product card
/// differ only in the data ([ProfileKit] vs [ProfileKitProduct]). The tint
/// follows the biotype's own `main_color` (see [[profiles-biotype-schema]]),
/// matching the rest of the "Il mio Tipo" screens; brand pink when unset.
class ProfileKitContentCard extends StatelessWidget {
  const ProfileKitContentCard({
    super.key,
    required this.title,
    this.description,
    this.imageUrl,
    this.cta,
    this.ctaLabel,
    this.onCtaTap,
    this.accentColor,
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

  /// The biotype's `main_color`; falls back to [AppColors.accent] when null.
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final label = ctaLabel ?? cta?.label;
    final showCta = label != null && onCtaTap != null;
    final rawAccent = accentColor ?? AppColors.accent;
    final background = _softBackground(rawAccent);
    // Some CMS biotype colors (cyan, orange, light blue…) are too light to
    // read as text; darken towards a WCAG-AA-safe shade, same as the
    // characteristics card CTA.
    final accent = readableOnWhite(rawAccent);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.spaceLg),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.textTheme.titleMedium?.copyWith(
              color: accent,
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
              child: CmsImage(
                imageUrl!,
                fit: BoxFit.contain,
                errorBuilder: (_) => const SizedBox.shrink(),
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
            _CtaButton(label: label, onTap: onCtaTap!, color: accent),
          ],
        ],
      ),
    );
  }

  /// Lightens [color] towards white so it reads as a soft tinted background,
  /// the same way [AppColors.accentSoft] relates to [AppColors.accent].
  Color _softBackground(Color color) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness + 0.38).clamp(0.0, 0.95))
        .withSaturation((hsl.saturation - 0.15).clamp(0.0, 1.0))
        .toColor();
  }
}

class _CtaButton extends StatelessWidget {
  const _CtaButton({
    required this.label,
    required this.onTap,
    required this.color,
  });

  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.surface,
          foregroundColor: color,
          side: BorderSide(color: color),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.spaceMd),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
        ),
        child: Text(
          label,
          style: AppTypography.textTheme.titleSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
