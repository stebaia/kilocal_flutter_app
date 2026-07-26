import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_localizations.dart';

/// Bottom sheet opened when a biotype body-map dot is tapped. Shows the tapped
/// point's [title] and [body] (from the silhouette texts). Falls back to a
/// neutral placeholder when a point has no text yet.
Future<void> showBiotypePointSheet(
  BuildContext context, {
  required String? title,
  required String? body,
  required Color accentColor,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surface,
    showDragHandle: true,
    isScrollControlled: true,
    constraints: BoxConstraints(
      maxHeight: MediaQuery.sizeOf(context).height * 0.9,
    ),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
    ),
    builder: (context) =>
        _BiotypePointSheet(title: title, body: body, accentColor: accentColor),
  );
}

class _BiotypePointSheet extends StatelessWidget {
  const _BiotypePointSheet({
    required this.title,
    required this.body,
    required this.accentColor,
  });

  final String? title;
  final String? body;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasContent =
        (title != null && title!.isNotEmpty) ||
        (body != null && body!.isNotEmpty);

    return SafeArea(
      child: SizedBox(
        // Full width so the min-size Column doesn't shrink the sheet.
        width: double.infinity,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenGutter,
            AppSpacing.spaceSm,
            AppSpacing.screenGutter,
            AppSpacing.spaceLg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentColor.withValues(alpha: 0.15),
                ),
                alignment: Alignment.center,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accentColor,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.spaceMd),
              Text(
                hasContent && title != null && title!.isNotEmpty
                    ? title!
                    : l10n.profileTypePointTitleFallback,
                style: AppTypography.textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.spaceSm),
              Text(
                hasContent && body != null && body!.isNotEmpty
                    ? body!
                    : l10n.profileTypePointBodyFallback,
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
