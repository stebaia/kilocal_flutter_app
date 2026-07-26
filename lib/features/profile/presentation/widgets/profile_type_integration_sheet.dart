import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_localizations.dart';

/// Intermediate sheet shown when the "Integrazione" path-category tile is
/// tapped on the biotype characteristics screen, before entering the
/// phase-based Integrazione area. Matches the Figma intermediate step: a
/// title, a short pitch and a "Vedi sezione dedicata" CTA that navigates to
/// `/path/integrazione`.
Future<void> showProfileTypeIntegrationSheet(
  BuildContext context, {
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
    builder: (context) => _IntegrationSheet(accentColor: accentColor),
  );
}

class _IntegrationSheet extends StatelessWidget {
  const _IntegrationSheet({required this.accentColor});

  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
                l10n.profileTypeIntegrationSheetTitle,
                style: AppTypography.textTheme.headlineSmall?.copyWith(
                  color: accentColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.spaceSm),
              const Divider(),
              const SizedBox(height: AppSpacing.spaceSm),
              Text(
                l10n.profileTypeIntegrationSheetHeadline,
                style: AppTypography.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.spaceSm),
              Text(
                l10n.profileTypeIntegrationSheetBody,
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppSpacing.spaceLg),
              _OutlinedCtaButton(
                label: l10n.profileTypeIntegrationSheetCta,
                color: accentColor,
                onPressed: () {
                  Navigator.of(context).pop();
                  context.push('/path/integrazione');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// White pill with a colored border and centered label, matching the Figma
/// "Vedi sezione dedicata" secondary CTA.
class _OutlinedCtaButton extends StatelessWidget {
  const _OutlinedCtaButton({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.pill);
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: AppColors.neutralWhite,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: color),
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: radius,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.spaceMd),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
