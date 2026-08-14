import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../l10n/app_localizations.dart';
import '../domain/entities/gallery_photo.dart';
import 'widgets/split_image_view.dart';

/// The split comparison: two photos revealed by a draggable cursor.
///
/// Save/share are not wired yet — the app has neither a share nor a
/// gallery-save package, and adding them pulls in platform permissions. See
/// [[photo-gallery-schema]].
class SplitImageScreen extends StatelessWidget {
  const SplitImageScreen({
    super.key,
    required this.before,
    required this.after,
    required this.content,
  });

  final GalleryPhoto before;
  final GalleryPhoto after;
  final GalleryContent content;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppHeader(
              title: content.title ?? l10n.gallerySplitTitle,
              showBack: true,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.screenGutter),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (content.splitViewTitle != null)
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppSpacing.spaceMd,
                        ),
                        child: Html(
                          data: content.splitViewTitle!,
                          style: {
                            'body': Style(
                              margin: Margins.zero,
                              padding: HtmlPaddings.zero,
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: FontSize(
                                AppTypography.textTheme.titleMedium?.fontSize ??
                                    16,
                              ),
                              lineHeight: const LineHeight(1.4),
                            ),
                          },
                        ),
                      ),
                    const Divider(height: 1, color: AppColors.divider),
                    const SizedBox(height: AppSpacing.spaceLg),
                    SplitImageView(
                      beforeUrl: before.fullImageUrl,
                      afterUrl: after.fullImageUrl,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
