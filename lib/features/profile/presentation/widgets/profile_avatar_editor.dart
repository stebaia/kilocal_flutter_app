import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/di.dart';
import '../../../../core/network/token_store.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../user/presentation/cubit/user_cubit.dart';
import '../cubit/avatar_upload_cubit.dart';

/// Large, tappable profile avatar shown at the top of the "My account" screen.
///
/// Tapping opens a bottom sheet to pick a photo (camera or gallery); the chosen
/// image is uploaded and set as `directus_users.avatar`, then the session is
/// refreshed so the new photo appears here and in the profile header.
class ProfileAvatarEditor extends StatelessWidget {
  const ProfileAvatarEditor({super.key});

  static const double _size = 96;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<AvatarUploadCubit, AvatarUploadState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        final messenger = ScaffoldMessenger.of(context);
        if (state.status == AvatarUploadStatus.success) {
          messenger.showSnackBar(
            SnackBar(content: Text(l10n.profileAvatarUpdated)),
          );
          context.read<AvatarUploadCubit>().reset();
        } else if (state.status == AvatarUploadStatus.error) {
          messenger.showSnackBar(
            SnackBar(content: Text(l10n.profileAvatarError)),
          );
          context.read<AvatarUploadCubit>().reset();
        }
      },
      child: BlocBuilder<AvatarUploadCubit, AvatarUploadState>(
        builder: (context, uploadState) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.spaceLg),
              child: GestureDetector(
                onTap: uploadState.isUploading
                    ? null
                    : () => _showPicker(context),
                child: SizedBox(
                  width: _size,
                  height: _size,
                  child: Stack(
                    children: [
                      _AvatarCircle(uploading: uploadState.isUploading),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: _CameraBadge(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _showPicker(BuildContext context) async {
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
}

/// The circular avatar itself: current photo, person placeholder, or a spinner
/// while an upload is in flight.
class _AvatarCircle extends StatelessWidget {
  const _AvatarCircle({required this.uploading});

  final bool uploading;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ProfileAvatarEditor._size,
      height: ProfileAvatarEditor._size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.accentSoft,
      ),
      clipBehavior: Clip.antiAlias,
      child: uploading
          ? const Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
            )
          : BlocBuilder<UserCubit, UserState>(
              bloc: getIt<UserCubit>(),
              builder: (context, state) {
                final avatarUrl = state.user?.avatarUrl;
                if (avatarUrl == null) return const _Placeholder();
                return _AvatarImage(url: avatarUrl);
              },
            ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder();

  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.person, color: AppColors.accent, size: 56);
  }
}

/// Loads the avatar image from the CMS with the Bearer token, mirroring the
/// header avatar in `profile_screen.dart`.
class _AvatarImage extends StatelessWidget {
  const _AvatarImage({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: getIt<TokenStore>().accessToken,
      builder: (context, snapshot) {
        final token = snapshot.data;
        if (token == null) return const _Placeholder();
        return Image.network(
          url,
          width: ProfileAvatarEditor._size,
          height: ProfileAvatarEditor._size,
          fit: BoxFit.cover,
          headers: {'Authorization': 'Bearer $token'},
          errorBuilder: (context, error, stackTrace) => const _Placeholder(),
          loadingBuilder: (context, child, progress) =>
              progress == null ? child : const _Placeholder(),
        );
      },
    );
  }
}

class _CameraBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.accent,
        border: Border.all(color: AppColors.surface, width: 2),
      ),
      child: const Icon(Icons.camera_alt, color: Colors.white, size: 15),
    );
  }
}
