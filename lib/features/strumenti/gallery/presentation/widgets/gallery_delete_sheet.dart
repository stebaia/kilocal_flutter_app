import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../domain/entities/gallery_photo.dart';

/// Confirmation sheet for deleting a photo. Returns `true` when confirmed.
///
/// Copy comes from the `photo_gallery` singleton (`delete_modal_*`).
Future<bool?> showGalleryDeleteSheet(
  BuildContext context,
  GalleryContent content,
) {
  final l10n = AppLocalizations.of(context)!;
  return showAppBrandBottomSheet<bool>(
    context,
    title: content.deleteModalTitle ?? l10n.galleryDelete,
    child: _DeleteSheetContent(content: content),
  );
}

class _DeleteSheetContent extends StatelessWidget {
  const _DeleteSheetContent({required this.content});

  final GalleryContent content;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenGutter,
        AppSpacing.spaceLg,
        AppSpacing.screenGutter,
        AppSpacing.spaceLg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (content.deleteModalContent != null)
            Html(
              data: content.deleteModalContent!,
              style: {
                'body': Style(
                  margin: Margins.zero,
                  padding: HtmlPaddings.zero,
                  textAlign: TextAlign.center,
                  color: AppColors.textSecondary,
                  fontSize: FontSize(
                    AppTypography.textTheme.bodyMedium?.fontSize ?? 14,
                  ),
                  lineHeight: const LineHeight(1.5),
                ),
              },
            ),
          const SizedBox(height: AppSpacing.spaceLg),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                content.uploadModalCtaCancel ?? l10n.galleryCancel,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.spaceSm),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.neutralWhite,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                content.deleteModalCtaConfirm ?? l10n.galleryDelete,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
