import 'package:flutter/material.dart';

import '../../../core/icons/app_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_header.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/entities/strumento.dart';

/// Placeholder destination for a launched tool. Each [StrumentoId] currently
/// lands here with a "coming soon" message; individual tools will replace this
/// with their own screen as they are implemented.
class StrumentoDetailScreen extends StatelessWidget {
  const StrumentoDetailScreen({super.key, required this.id});

  final StrumentoId id;

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
            AppHeader(title: _title(l10n), showBack: true),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.screenGutter),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppIcon(
                        AppIcons.strumenti,
                        size: 48,
                        color: AppColors.accent,
                      ),
                      const SizedBox(height: AppSpacing.spaceMd),
                      Text(
                        l10n.strumentiComingSoon,
                        textAlign: TextAlign.center,
                        style: AppTypography.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _title(AppLocalizations l10n) => switch (id) {
    StrumentoId.promemoria => l10n.strumentiPromemoria,
    StrumentoId.timer => l10n.strumentiTimer,
    StrumentoId.glossario => l10n.strumentiGlossario,
    StrumentoId.gallery => l10n.strumentiGallery,
  };
}
