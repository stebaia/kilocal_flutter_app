import 'package:flutter/material.dart';

import '../../../../core/config/env.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// The magenta kit card on the biotype result screen: the recommended Starter
/// Kit image on a pink gradient, with the biotype silhouette badge top-right.
///
/// The kit image and silhouette come from the submit `outcome`. Its exact keys
/// are not yet confirmed by backend (see wiki/survey.md), so we read a set of
/// likely keys defensively and degrade gracefully when absent.
class SurveyKitCard extends StatelessWidget {
  const SurveyKitCard({super.key, required this.outcome});

  final Map<String, dynamic>? outcome;

  @override
  Widget build(BuildContext context) {
    final kitImage = _assetUrl(
      _firstString(outcome, const [
        'kit_image',
        'kit_asset',
        'starter_kit_image',
        'image',
      ]),
    );
    final silhouette = _assetUrl(
      _firstString(outcome, const ['silhouette', 'type_asset', 'icon']),
    );

    return AspectRatio(
      aspectRatio: 328 / 220,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.typeHighlight, AppColors.brandPink],
          ),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (kitImage != null)
              Padding(
                padding: const EdgeInsets.all(AppSpacing.spaceMd),
                child: Image.network(
                  kitImage,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              ),
            Positioned(
              top: AppSpacing.spaceSm,
              right: AppSpacing.spaceSm,
              child: _SilhouetteBadge(imageUrl: silhouette),
            ),
          ],
        ),
      ),
    );
  }

  String? _firstString(Map<String, dynamic>? map, List<String> keys) {
    if (map == null) return null;
    for (final k in keys) {
      final v = map[k];
      if (v is String && v.isNotEmpty) return v;
    }
    return null;
  }

  /// Resolves a Directus asset id/path to an absolute URL.
  String? _assetUrl(String? idOrUrl) {
    if (idOrUrl == null || idOrUrl.isEmpty) return null;
    if (idOrUrl.startsWith('http')) return idOrUrl;
    return '${Env.baseUrl}/assets/$idOrUrl';
  }
}

class _SilhouetteBadge extends StatelessWidget {
  const _SilhouetteBadge({this.imageUrl});

  final String? imageUrl;

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
      child: imageUrl != null
          ? Image.network(
              imageUrl!,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => const Icon(
                Icons.spa,
                color: AppColors.typeHighlight,
                size: 20,
              ),
            )
          : const Icon(Icons.spa, color: AppColors.typeHighlight, size: 20),
    );
  }
}
