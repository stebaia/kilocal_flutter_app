import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubit/avatar_upload_cubit.dart';

/// Shows the camera/gallery picker sheet and hands the chosen image to
/// [AvatarUploadCubit.pickAndUpload]. Shared by [[ProfileAvatarEditor]] (the
/// "My account" screen) and the profile header avatar so both trigger the same
/// upload flow instead of duplicating the sheet.
Future<void> showAvatarPicker(BuildContext context) async {
  final l10n = AppLocalizations.of(context)!;
  final cubit = context.read<AvatarUploadCubit>();
  final source = await showModalBottomSheet<ImageSource>(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: Text(l10n.profileAvatarFromCamera),
              onTap: () => Navigator.of(sheetContext).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l10n.profileAvatarFromGallery),
              onTap: () => Navigator.of(sheetContext).pop(ImageSource.gallery),
            ),
          ],
        ),
      );
    },
  );
  if (source != null) {
    await cubit.pickAndUpload(source);
  }
}

/// Shows the success/error snackbar for an [AvatarUploadState] change and
/// resets the cubit back to idle. Shared listener body for every
/// [AvatarUploadCubit] consumer.
void handleAvatarUploadFeedback(BuildContext context, AvatarUploadState state) {
  final l10n = AppLocalizations.of(context)!;
  final messenger = ScaffoldMessenger.of(context);
  if (state.status == AvatarUploadStatus.success) {
    messenger.showSnackBar(SnackBar(content: Text(l10n.profileAvatarUpdated)));
    context.read<AvatarUploadCubit>().reset();
  } else if (state.status == AvatarUploadStatus.error) {
    messenger.showSnackBar(SnackBar(content: Text(l10n.profileAvatarError)));
    context.read<AvatarUploadCubit>().reset();
  }
}
