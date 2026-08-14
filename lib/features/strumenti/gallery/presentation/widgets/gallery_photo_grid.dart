import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../domain/entities/gallery_photo.dart';
import '../../../../../../core/widgets/cms_image.dart';

/// The 2-column photo grid. The first cell is the "add photo" tile; the rest
/// are the user's photos, newest first.
///
/// In selecting mode the picked photos get a brand outline.
class GalleryPhotoGrid extends StatelessWidget {
  const GalleryPhotoGrid({
    super.key,
    required this.photos,
    required this.onAdd,
    required this.onTapPhoto,
    required this.onLongPressPhoto,
    this.selected = const [],
    this.padding,
  });

  final List<GalleryPhoto> photos;
  final VoidCallback onAdd;
  final ValueChanged<GalleryPhoto> onTapPhoto;
  final ValueChanged<GalleryPhoto> onLongPressPhoto;
  final List<GalleryPhoto> selected;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: padding ?? const EdgeInsets.all(AppSpacing.screenGutter),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.spaceMd,
        mainAxisSpacing: AppSpacing.spaceMd,
        childAspectRatio: 3 / 4,
      ),
      // +1 for the leading "add" tile.
      itemCount: photos.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) return _AddTile(onTap: onAdd);

        final photo = photos[index - 1];
        return _PhotoTile(
          photo: photo,
          isSelected: selected.contains(photo),
          onTap: () => onTapPhoto(photo),
          onLongPress: () => onLongPressPhoto(photo),
        );
      },
    );
  }
}

class _AddTile extends StatelessWidget {
  const _AddTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.borderCard),
        ),
        child: const Center(
          child: Icon(Icons.add, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({
    required this.photo,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
  });

  final GalleryPhoto photo;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.divider,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: isSelected
              ? Border.all(color: AppColors.accent, width: 2)
              : null,
        ),
        child: CmsImage(
          photo.imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_) => const Icon(
            Icons.broken_image_outlined,
            color: AppColors.textSecondary,
          ),
          placeholder: (_) => const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
      ),
    );
  }
}
