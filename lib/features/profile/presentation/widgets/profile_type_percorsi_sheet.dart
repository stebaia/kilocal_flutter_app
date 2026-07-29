import 'package:flutter/material.dart';

import '../../../../core/icons/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_localizations.dart';

/// Bottom sheet opened when a path-category icon (Allenamento/Alimentazione/
/// Benessere/Integrazione) is tapped on the biotype characteristics screen.
/// Shows the per-area silhouette text; falls back to a placeholder when absent.
Future<void> showProfileTypePercorsiSheet(
  BuildContext context, {
  required String area,
  required String title,
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
    builder: (context) => _PercorsiSheet(
      area: area,
      title: title,
      body: body,
      accentColor: accentColor,
    ),
  );
}

class _PercorsiSheet extends StatelessWidget {
  const _PercorsiSheet({
    required this.area,
    required this.title,
    required this.body,
    required this.accentColor,
  });

  final String area;
  final String title;
  final String? body;
  final Color accentColor;

  static const _iconByArea = <String, String>{
    'allenamento': AppIcons.training,
    'alimentazione': AppIcons.food,
    'benessere': AppIcons.wellness,
    'integrazione': AppIcons.flash,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final text = body?.trim();
    // "[rimando pagina]" is a sheet-less marker in the source (the area links to
    // its own page); show the fallback rather than the raw marker.
    final hasBody =
        text != null && text.isNotEmpty && !text.startsWith('[rimando');

    return SafeArea(
      child: SizedBox(
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
              Text(
                title,
                style: AppTypography.textTheme.headlineSmall?.copyWith(
                  color: accentColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.spaceSm),
              Divider(),
              const SizedBox(height: AppSpacing.spaceSm),
              Text(
                hasBody ? text : l10n.profileTypePointBodyFallback,
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
