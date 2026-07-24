import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/di.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_header.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/entities/path_material.dart';
import 'cubit/path_material_detail_cubit.dart';
import 'widgets/path_material_video.dart';

/// Detail of a single "Materiali extra" item.
///
/// Video materials reuse the path-step video layout (Vimeo player with a
/// floating back button over the media); text materials show a hero image, the
/// title and the HTML body, with a standard [AppHeader] carrying the category
/// title.
class PathMaterialDetailScreen extends StatelessWidget {
  const PathMaterialDetailScreen({
    super.key,
    required this.materialId,
    this.categoryTitle,
  });

  final String materialId;

  /// Category title shown in the header (the originating tab). Optional.
  final String? categoryTitle;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PathMaterialDetailCubit>()..load(id: materialId),
      child: _PathMaterialDetailView(categoryTitle: categoryTitle),
    );
  }
}

class _PathMaterialDetailView extends StatelessWidget {
  const _PathMaterialDetailView({this.categoryTitle});

  final String? categoryTitle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<PathMaterialDetailCubit, PathMaterialDetailState>(
      builder: (context, state) {
        switch (state.status) {
          case PathMaterialDetailStatus.initial:
          case PathMaterialDetailStatus.loading:
            return const Scaffold(
              backgroundColor: AppColors.surface,
              body: Center(
                child: CircularProgressIndicator(color: AppColors.accent),
              ),
            );
          case PathMaterialDetailStatus.error:
            return Scaffold(
              backgroundColor: AppColors.surface,
              body: Center(
                child: Text(
                  l10n.errorGeneric,
                  style: AppTypography.textTheme.bodyMedium,
                ),
              ),
            );
          case PathMaterialDetailStatus.loaded:
            final data = state.data;
            if (data == null) {
              return Scaffold(
                backgroundColor: AppColors.surface,
                body: Center(
                  child: Text(
                    l10n.errorGeneric,
                    style: AppTypography.textTheme.bodyMedium,
                  ),
                ),
              );
            }
            return data.isVideo
                ? _VideoDetail(material: data)
                : _TextDetail(material: data, categoryTitle: categoryTitle);
        }
      },
    );
  }
}

/// Video material: full-bleed Vimeo player (path-step style) + title and body.
class _VideoDetail extends StatelessWidget {
  const _VideoDetail({required this.material});

  final PathMaterialDetail material;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      // The player floats under the status bar, so the body reaches the top.
      // top: false keeps that full-bleed top while still guarding the bottom
      // against the Android system navigation bar.
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: AppSpacing.spaceXl),
          children: [
            PathMaterialVideo(
              key: ValueKey(material.id),
              embedUrl: material.vimeoEmbedUrl,
              vimeoUrl: material.vimeoUrl,
              posterUrl: material.imageUrl,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenGutter,
                AppSpacing.spaceLg,
                AppSpacing.screenGutter,
                0,
              ),
              child: _TitleAndBody(material: material),
            ),
          ],
        ),
      ),
    );
  }
}

/// Text / image material matching the design: header + hero image + body. The
/// "Consigli utili" ([PathMaterialDetail.hidesImage]) drop the hero and open
/// straight on the title.
class _TextDetail extends StatelessWidget {
  const _TextDetail({required this.material, this.categoryTitle});

  final PathMaterialDetail material;
  final String? categoryTitle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      // top: false — AppHeader insets the status bar; SafeArea guards only the
      // bottom against the Android system navigation bar.
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppHeader(title: categoryTitle ?? '', showBack: true),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  if (material.imageUrl != null && !material.hidesImage)
                    AspectRatio(
                      aspectRatio: 1.1,
                      child: Image.network(
                        material.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) =>
                            const ColoredBox(color: AppColors.background),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenGutter,
                      AppSpacing.spaceLg,
                      AppSpacing.screenGutter,
                      AppSpacing.spaceXl,
                    ),
                    child: _TitleAndBody(material: material),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shared title + HTML body block for both detail variants.
class _TitleAndBody extends StatelessWidget {
  const _TitleAndBody({required this.material});

  final PathMaterialDetail material;

  @override
  Widget build(BuildContext context) {
    final content = material.content;
    final subtitle = material.subtitle;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          material.title,
          style: AppTypography.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        if (subtitle != null && subtitle.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.spaceXs),
          Text(
            subtitle,
            style: AppTypography.textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
        if (content != null && content.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.spaceMd),
          Html(
            data: content,
            style: {
              'body': Style(
                margin: Margins.zero,
                padding: HtmlPaddings.zero,
                color: AppColors.textSecondary,
                fontSize: FontSize(
                  AppTypography.textTheme.bodyMedium?.fontSize ?? 14,
                ),
                lineHeight: const LineHeight(1.5),
              ),
            },
          ),
        ],
        for (final attachment in material.attachments) ...[
          const SizedBox(height: AppSpacing.spaceMd),
          _AttachmentButton(attachment: attachment),
        ],
      ],
    );
  }
}

/// Download CTA for a material's attached file (the PDF of a "Scheda").
///
/// The asset is served unauthenticated, so the file is handed to the system
/// browser, which downloads it or opens it in the native PDF viewer.
class _AttachmentButton extends StatelessWidget {
  const _AttachmentButton({required this.attachment});

  final PathMaterialAttachment attachment;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _download(context, l10n),
        icon: const Icon(Icons.download_outlined, size: 20),
        label: Text(attachment.label),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.surface,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.spaceMd),
          textStyle: AppTypography.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Future<void> _download(BuildContext context, AppLocalizations l10n) async {
    final messenger = ScaffoldMessenger.of(context);
    final uri = Uri.tryParse(attachment.url);
    final opened =
        uri != null &&
        await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.pathMaterialDownloadError)),
      );
    }
  }
}
