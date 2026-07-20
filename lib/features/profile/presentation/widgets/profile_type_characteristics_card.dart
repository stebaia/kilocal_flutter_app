import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Large pink "Le tue caratteristiche" card: the biotype silhouette on the
/// right, a title top-left and a "Scopri di più" call-to-action bottom-left.
///
/// Mirrors [[profiles-biotype-schema]] — [silhouetteAssetName] is the local
/// person illustration chosen by gender + biotype color, and [gradientColors]
/// come from `main_color` / `secondary_color` when available.
class ProfileTypeCharacteristicsCard extends StatelessWidget {
  const ProfileTypeCharacteristicsCard({
    super.key,
    required this.title,
    required this.ctaLabel,
    this.silhouetteAssetName,
    this.gradientColors,
    this.onTap,
  });

  final String title;
  final String ctaLabel;
  final String? silhouetteAssetName;
  final List<Color>? gradientColors;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final gradient = gradientColors != null && gradientColors!.length >= 2
        ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors!,
          )
        : AppColors.brandGradientVertical;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 320,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: AppShadows.card,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned(
              bottom: -1,
              left: -70,
              child: Opacity(
                opacity: 0.7,
                child: SvgPicture.asset(
                  'assets/icons/line.svg',
                  width: 300,
                  height: 300,
                ),
              ),
            ),
            // Silhouette illustration anchored bottom-right.
            Positioned(
              right: 0,
              bottom: 0,
              top: AppSpacing.spaceLg,
              child: _Silhouette(assetName: silhouetteAssetName),
            ),
            // Title top-left.
            Positioned(
              top: AppSpacing.spaceLg,
              left: AppSpacing.spaceLg,
              right: AppSpacing.spaceLg,
              child: Text(
                title,
                style: AppTypography.textTheme.headlineSmall?.copyWith(
                  fontSize: 16,
                  color: AppColors.neutralWhite,
                  fontWeight: FontWeight.w700,
                  height: 1.15,
                ),
              ),
            ),
            // "Scopri di più" bottom-left, as a white rounded pill so the CTA
            // stands out against the gradient instead of blending into it.
            Positioned(
              bottom: AppSpacing.spaceLg,
              left: AppSpacing.spaceLg,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.spaceMd,
                  vertical: AppSpacing.spaceXs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.neutralWhite,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  boxShadow: AppShadows.card,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      ctaLabel,
                      style: AppTypography.textTheme.bodyMedium?.copyWith(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space2xs),
                    const Icon(
                      Icons.chevron_right,
                      color: AppColors.accent,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Renders the biotype silhouette from a local asset with a graceful fallback
/// (empty space) when the asset is missing or fails to load.
class _Silhouette extends StatelessWidget {
  const _Silhouette({this.assetName});

  final String? assetName;

  @override
  Widget build(BuildContext context) {
    if (assetName == null || assetName!.isEmpty) {
      return const SizedBox(width: 200);
    }

    return Image.asset(
      assetName!,
      fit: BoxFit.contain,
      alignment: Alignment.bottomCenter,
      errorBuilder: (context, error, stackTrace) => const SizedBox(width: 200),
    );
  }
}
