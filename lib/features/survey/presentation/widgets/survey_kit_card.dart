import 'package:flutter/material.dart';

import '../../../../core/config/env.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/hex_color.dart';
import '../../../../core/widgets/cms_svg_icon.dart';
import '../../domain/entities/survey_outcome.dart';
import '../../../../../core/widgets/cms_image.dart';

/// The kit card on the biotype result screen: the recommended Starter Kit
/// image on a gradient tinted with the biotype's own CMS color (falling back
/// to the brand pink when the outcome carries no color), with the biotype
/// icon badge top-right.
///
/// Both images come from `outcome.profile` (see [SurveyOutcome]); the card
/// hides itself when the outcome carries no kit image, rather than rendering an
/// empty pink box.
class SurveyKitCard extends StatelessWidget {
  const SurveyKitCard({super.key, required this.outcome});

  final SurveyOutcome? outcome;

  @override
  Widget build(BuildContext context) {
    final kitImage = _assetUrl(outcome?.kitImageId);
    if (kitImage == null) return const SizedBox.shrink();

    final mainColor =
        colorFromHex(outcome?.mainColor) ?? AppColors.typeHighlight;
    final secondaryColor =
        colorFromHex(outcome?.secondaryColor) ?? AppColors.brandPink;

    return AspectRatio(
      aspectRatio: 328 / 220,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [mainColor, secondaryColor],
          ),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.spaceMd),
              child: CmsImage(
                kitImage,
                fit: BoxFit.contain,
                errorBuilder: (_) => const SizedBox.shrink(),
              ),
            ),
            Positioned(
              top: AppSpacing.spaceSm,
              right: AppSpacing.spaceSm,
              child: _SilhouetteBadge(
                imageUrl: _assetUrl(outcome?.iconId),
                color: mainColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Resolves a Directus asset id/path to an absolute URL.
  String? _assetUrl(String? idOrUrl) {
    if (idOrUrl == null || idOrUrl.isEmpty) return null;
    if (idOrUrl.startsWith('http')) return idOrUrl;
    return '${Env.baseUrl}/assets/$idOrUrl';
  }
}

class _SilhouetteBadge extends StatelessWidget {
  const _SilhouetteBadge({this.imageUrl, required this.color});

  final String? imageUrl;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 40,
      decoration: const BoxDecoration(
        color: AppColors.neutralWhite,
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.all(6),
      // `profiles.icon` is an SVG, so it needs SvgPicture rather than
      // Image.network (which cannot decode it).
      child: CmsSvgIcon(
        url: imageUrl,
        size: 20,
        color: color,
        fallback: Icon(Icons.spa, color: color, size: 20),
      ),
    );
  }
}
