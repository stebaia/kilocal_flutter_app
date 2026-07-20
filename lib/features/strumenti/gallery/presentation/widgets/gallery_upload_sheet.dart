import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../domain/entities/gallery_photo.dart';

/// Opens the "Carica immagine" sheet. Returns the picked file when the user
/// confirms, or `null` if they cancel.
///
/// Uses the brand sheet (red header) the designs call for — the same one the
/// Promemoria create sheet uses.
Future<File?> showGalleryUploadSheet(
  BuildContext context,
  GalleryContent content,
) {
  final l10n = AppLocalizations.of(context)!;
  return showAppBrandBottomSheet<File>(
    context,
    title: content.uploadModalTitle ?? l10n.galleryUploadTitle,
    child: _UploadSheetContent(content: content),
  );
}

class _UploadSheetContent extends StatefulWidget {
  const _UploadSheetContent({required this.content});

  final GalleryContent content;

  @override
  State<_UploadSheetContent> createState() => _UploadSheetContentState();
}

class _UploadSheetContentState extends State<_UploadSheetContent> {
  final _picker = ImagePicker();
  File? _picked;

  Future<void> _pick(ImageSource source) async {
    final file = await _picker.pickImage(source: source, imageQuality: 90);
    if (file == null) return;
    setState(() => _picked = File(file.path));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final content = widget.content;
    final hasPhoto = _picked != null;

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
          // Preview slot: the CMS instructions until a photo is picked, then
          // the photo itself.
          AspectRatio(
            aspectRatio: 1,
            child: hasPhoto
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    child: Image.file(
                      _picked!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  )
                : Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    padding: const EdgeInsets.all(AppSpacing.spaceLg),
                    child: Center(
                      child: SingleChildScrollView(
                        child: Html(
                          data: content.uploadModalInfo ?? l10n.galleryUploadInfo,
                          style: {
                            'body': Style(
                              margin: Margins.zero,
                              padding: HtmlPaddings.zero,
                              textAlign: TextAlign.center,
                              color: AppColors.textPrimary,
                              fontSize: FontSize(
                                AppTypography.textTheme.bodyMedium?.fontSize ??
                                    14,
                              ),
                              lineHeight: const LineHeight(1.5),
                            ),
                          },
                        ),
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: AppSpacing.spaceLg),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: AppSpacing.spaceLg),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _pick(ImageSource.camera),
              iconAlignment: IconAlignment.end,
              icon: const Icon(Icons.photo_camera_outlined, size: 18),
              // No CMS string for the camera CTA (only upload/cancel exist),
              // so this label lives in ARB. See [[photo-gallery-schema]].
              label: Text(
                hasPhoto ? l10n.galleryRetakePhoto : l10n.galleryTakePhoto,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.spaceSm),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: hasPhoto
                  ? () => Navigator.of(context).pop(_picked)
                  : () => _pick(ImageSource.gallery),
              iconAlignment: IconAlignment.end,
              icon: Icon(
                hasPhoto ? Icons.check : Icons.file_upload_outlined,
                size: 18,
              ),
              label: Text(
                hasPhoto
                    ? l10n.galleryConfirmUpload
                    : (content.uploadModalCtaUpload ?? l10n.galleryUpload),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
