import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../l10n/app_localizations.dart';
import '../domain/entities/gallery_photo.dart';
import 'cubit/gallery_cubit.dart';
import 'split_image_screen.dart';
import 'widgets/gallery_delete_sheet.dart';
import 'widgets/gallery_photo_grid.dart';
import 'widgets/gallery_upload_sheet.dart';

/// Strumenti > Foto Gallery: the user's photo grid, with upload, delete, and
/// a two-photo selection that opens the split comparison.
class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<GalleryCubit>()..load(),
      child: const _GalleryView(),
    );
  }
}

class _GalleryView extends StatelessWidget {
  const _GalleryView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<GalleryCubit, GalleryState>(
      builder: (context, state) {
        final selecting = state.mode == GalleryMode.selecting;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            top: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppHeader(
                  title: state.content.title ?? l10n.strumentiGallery,
                  showBack: true,
                ),
                Expanded(child: _body(context, state)),
              ],
            ),
          ),
          // The split CTA only makes sense with photos to compare.
          floatingActionButton: _fab(context, state),
          floatingActionButtonLocation: selecting
              ? FloatingActionButtonLocation.centerFloat
              : FloatingActionButtonLocation.endFloat,
        );
      },
    );
  }

  Widget _body(BuildContext context, GalleryState state) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<GalleryCubit>();

    if (state.status == GalleryStatus.loading ||
        state.status == GalleryStatus.initial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == GalleryStatus.error) {
      return _Message(
        text: l10n.galleryLoadError,
        action: TextButton(onPressed: cubit.load, child: Text(l10n.retry)),
      );
    }

    // The CMS can switch the whole tool off.
    if (state.content.isToolBlocked) {
      return _Message(text: l10n.galleryToolBlocked);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenGutter,
            AppSpacing.spaceLg,
            AppSpacing.screenGutter,
            AppSpacing.spaceXs,
          ),
          child: Text(
            state.content.photosTitle ?? l10n.galleryPhotosTitle,
            style: AppTypography.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenGutter),
          child: Divider(height: 1, color: AppColors.divider),
        ),
        Expanded(
          child: Stack(
            children: [
              GalleryPhotoGrid(
                photos: state.photos,
                selected: state.selected,
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenGutter,
                  AppSpacing.spaceMd,
                  AppSpacing.screenGutter,
                  // Room for the floating CTA.
                  96,
                ),
                onAdd: () => _onAdd(context),
                onTapPhoto: (photo) => _onTapPhoto(context, state, photo),
                onLongPressPhoto: (photo) => _onDelete(context, photo),
              ),
              if (state.isUploading)
                const Positioned.fill(
                  child: ColoredBox(
                    color: Color(0x66FFFFFF),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// Browse mode: a round button that starts the split selection.
  /// Selecting mode: a close button plus the CMS-driven progress CTA.
  Widget? _fab(BuildContext context, GalleryState state) {
    if (state.status != GalleryStatus.loaded ||
        state.content.isToolBlocked ||
        state.photos.length < GalleryState.maxSelection) {
      return null;
    }

    final cubit = context.read<GalleryCubit>();

    if (state.mode == GalleryMode.browse) {
      return FloatingActionButton(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.accent,
        shape: const CircleBorder(side: BorderSide(color: AppColors.borderCard)),
        elevation: 2,
        onPressed: cubit.startSelecting,
        child: const Icon(Icons.compare_outlined),
      );
    }

    final label = state.selectionCta();
    final ready = state.hasBothSelected;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenGutter),
      child: Row(
        children: [
          FloatingActionButton.small(
            heroTag: 'gallery-cancel',
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.textPrimary,
            shape: const CircleBorder(
              side: BorderSide(color: AppColors.borderCard),
            ),
            onPressed: cubit.cancelSelecting,
            child: const Icon(Icons.close),
          ),
          const SizedBox(width: AppSpacing.spaceSm),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ready ? AppColors.ink : AppColors.surface,
                foregroundColor: ready
                    ? AppColors.neutralWhite
                    : AppColors.textPrimary,
                side: ready
                    ? null
                    : const BorderSide(color: AppColors.borderCard),
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.spaceMd,
                ),
              ),
              onPressed: ready ? () => _openSplit(context, state) : null,
              child: Text(label ?? ''),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onAdd(BuildContext context) async {
    final cubit = context.read<GalleryCubit>();
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);

    final file = await showGalleryUploadSheet(context, cubit.state.content);
    if (file == null) return;

    final ok = await cubit.upload(file);
    if (!ok) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.galleryUploadError)));
    }
  }

  void _onTapPhoto(
    BuildContext context,
    GalleryState state,
    GalleryPhoto photo,
  ) {
    if (state.mode == GalleryMode.selecting) {
      context.read<GalleryCubit>().toggleSelection(photo);
    }
  }

  Future<void> _onDelete(BuildContext context, GalleryPhoto photo) async {
    final cubit = context.read<GalleryCubit>();
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showGalleryDeleteSheet(context, cubit.state.content);
    if (confirmed != true) return;

    final ok = await cubit.delete(photo);
    if (!ok) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.galleryDeleteError)));
    }
  }

  void _openSplit(BuildContext context, GalleryState state) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SplitImageScreen(
          before: state.selected.first,
          after: state.selected.last,
          content: state.content,
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.text, this.action});

  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenGutter),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              textAlign: TextAlign.center,
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            if (action != null) ...[
              const SizedBox(height: AppSpacing.spaceMd),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
