import 'package:flutter/material.dart';

import '../../../../core/icons/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/path_material.dart';

/// Card for a single "Materiali extra" item: a hero image with a leading
/// media-type badge (play for video, document otherwise), with the title
/// underneath.
///
/// Materials flagged [PathMaterial.hidesImage] ("Consigli utili" and "Schede")
/// are text-only: the badge moves next to the title and no cover is shown.
class PathMaterialCard extends StatelessWidget {
  const PathMaterialCard({super.key, required this.material, this.onTap});

  final PathMaterial material;
  final VoidCallback? onTap;

  /// Covers are 16:9 (the Vimeo poster for videos, the CMS/category hero
  /// otherwise), so the card image honours that ratio instead of cropping to a
  /// fixed height.
  static const double _imageAspectRatio = 16 / 9;

  @override
  Widget build(BuildContext context) {
    if (material.hidesImage) {
      return _TextOnlyCard(material: material, onTap: onTap);
    }

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.spaceSm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Stack(
              children: [
                AspectRatio(
                  aspectRatio: _imageAspectRatio,
                  child: _MaterialImage(url: material.imageUrl),
                ),
                Positioned(
                  top: AppSpacing.spaceSm,
                  left: AppSpacing.spaceSm,
                  child: _MediaTypeBadge(isVideo: material.isVideo),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.spaceSm),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.space2xs,
            ),
            child: Text(
              material.title,
              style: AppTypography.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.space2xs),
        ],
      ),
    );
  }
}

/// Image-less variant used by the "Consigli utili": the media-type badge leads
/// the row and the title fills it.
class _TextOnlyCard extends StatelessWidget {
  const _TextOnlyCard({required this.material, this.onTap});

  final PathMaterial material;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          _MediaTypeBadge(isVideo: material.isVideo),
          const SizedBox(width: AppSpacing.spaceSm),
          Expanded(
            child: Text(
              material.title,
              style: AppTypography.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MaterialImage extends StatelessWidget {
  const _MaterialImage({this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    if (url == null) return const _ImagePlaceholder();
    return Image.network(
      url!,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => const _ImagePlaceholder(),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_outlined,
        color: AppColors.textSecondary,
        size: 32,
      ),
    );
  }
}

/// Circular accent badge with the media-type icon (play vs document).
class _MediaTypeBadge extends StatelessWidget {
  const _MediaTypeBadge({required this.isVideo});

  final bool isVideo;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: const BoxDecoration(
        color: AppColors.accent,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: AppIcon(
        isVideo ? AppIcons.playSmall : AppIcons.archive,
        size: 18,
        color: AppColors.neutralWhite,
      ),
    );
  }
}
