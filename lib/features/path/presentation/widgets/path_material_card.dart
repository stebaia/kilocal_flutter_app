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
///
/// Under [PathMaterialFilter.all] (both statuses listed together), a
/// completed material's card fills solid brand-red with a white badge/text —
/// the inverse of the default white-card/red-badge treatment — so "visti" and
/// "da vedere" read apart at a glance without needing to check the section
/// header. Outside `all`, every card in the list already shares one status,
/// so the plain (not-completed) styling is used regardless of [PathMaterial.
/// isCompleted].
class PathMaterialCard extends StatelessWidget {
  const PathMaterialCard({
    super.key,
    required this.material,
    this.onTap,
    this.highlightCompleted = false,
  });

  final PathMaterial material;
  final VoidCallback? onTap;

  /// Whether to apply the inverted "completed" styling when
  /// [PathMaterial.isCompleted] is true (see class doc).
  final bool highlightCompleted;

  /// Covers are 16:9 (the Vimeo poster for videos, the CMS/category hero
  /// otherwise), so the card image honours that ratio instead of cropping to a
  /// fixed height.
  static const double _imageAspectRatio = 16 / 9;

  bool get _completed => highlightCompleted && material.isCompleted;

  @override
  Widget build(BuildContext context) {
    if (material.hidesImage) {
      return _TextOnlyCard(
        material: material,
        onTap: onTap,
        completed: _completed,
      );
    }

    return AppCard(
      onTap: onTap,
      color: _completed ? AppColors.brandPink : AppColors.surface,
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
                  child: _MediaTypeBadge(
                    isVideo: material.isVideo,
                    completed: _completed,
                  ),
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
                color: _completed ? AppColors.neutralWhite : null,
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
  const _TextOnlyCard({
    required this.material,
    this.onTap,
    this.completed = false,
  });

  final PathMaterial material;
  final VoidCallback? onTap;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      color: completed ? AppColors.brandPink : AppColors.surface,
      child: Row(
        children: [
          _MediaTypeBadge(isVideo: material.isVideo, completed: completed),
          const SizedBox(width: AppSpacing.spaceSm),
          Expanded(
            child: Text(
              material.title,
              style: AppTypography.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: completed ? AppColors.neutralWhite : null,
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
///
/// [completed] inverts it — white circle, red icon — to match the red card
/// background used for completed materials under [PathMaterialFilter.all].
class _MediaTypeBadge extends StatelessWidget {
  const _MediaTypeBadge({required this.isVideo, this.completed = false});

  final bool isVideo;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: completed ? AppColors.neutralWhite : AppColors.accent,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: AppIcon(
        isVideo ? AppIcons.materialVideo : AppIcons.materialText,
        size: 16,
        color: completed ? AppColors.accent : AppColors.neutralWhite,
      ),
    );
  }
}
