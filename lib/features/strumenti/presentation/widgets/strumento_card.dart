import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/strumento.dart';

/// Full-width red gradient card for a single tool: title top-left, an
/// "Avvia strumento >" CTA bottom-left, and the illustration on the right.
class StrumentoCard extends StatelessWidget {
  const StrumentoCard({
    super.key,
    required this.strumento,
    required this.onTap,
  });

  final Strumento strumento;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 130,
        decoration: BoxDecoration(
          gradient: AppColors.brandGradientVertical,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: AppShadows.card,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Stack(
            children: [
              // Illustration anchored flush to the bottom-right edges of the
              // card (no padding — unlike the title/CTA). The PNGs are trimmed
              // to their content, so a Column keeps the ground shadow centered
              // directly under the image regardless of its aspect ratio.
              Positioned(
                right: 0,
                bottom: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      strumento.assetName,
                      height: 86,
                      fit: BoxFit.contain,
                    ),
                    const _GroundShadow(),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.spaceLg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      strumento.title,
                      style: AppTypography.textTheme.headlineLarge?.copyWith(
                        color: AppColors.neutralWhite,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.strumentiLaunch,
                          style: AppTypography.textTheme.bodyMedium?.copyWith(
                            color: AppColors.neutralWhite,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.space2xs),
                        const Icon(
                          Icons.chevron_right,
                          color: AppColors.neutralWhite,
                          size: 20,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Soft elliptical ground shadow beneath a tool illustration.
///
/// The ellipse geometry (cx 60, cy 14, rx 51, ry 5 at 20% opacity in a 120×28
/// viewBox) comes straight from the Figma export; the Gaussian blur is applied
/// here via [ImageFiltered] because flutter_svg 2.x does not render the SVG's
/// `feGaussianBlur` filter. `sigmaX/Y: 4.5` matches the export's stdDeviation.
class _GroundShadow extends StatelessWidget {
  const _GroundShadow();

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ui.ImageFilter.blur(sigmaX: 4.5, sigmaY: 4.5),
      child: SvgPicture.asset(
        'assets/strumenti/ground_shadow.svg',
        width: 120,
        height: 28,
      ),
    );
  }
}
