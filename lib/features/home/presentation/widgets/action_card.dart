import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/icons/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/home_data.dart';
import 'action_card_illustration.dart';

class ActionCard extends StatelessWidget {
  const ActionCard({super.key, required this.card});

  final HomeActionCard card;

  void _handleTap(BuildContext context) {
    if (card.isLocked) {
      final l10n = AppLocalizations.of(context)!;
      showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(l10n.homeComingSoonTitle),
          content: Text(l10n.homeComingSoonBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }
    context.push(card.route);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _handleTap(context),
      child: Container(
        height: 165,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: AppColors.brandGradientVertical,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: AppShadows.card,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Stack(
            children: [
              // Darkening overlay for the locked ("coming soon") state.
              if (card.isLocked)
                Positioned.fill(
                  child: Container(color: Colors.black.withValues(alpha: 0.35)),
                ),
              // Top-center illustration.
              Positioned(
                top: AppSpacing.spaceMd,
                left: 0,
                right: 0,
                child: Center(
                  child: ActionCardIllustration(
                    imageUrl: card.imageUrl,
                    assetName: card.assetName,
                    isLocked: card.isLocked,
                  ),
                ),
              ),
              // Bottom-left title.
              Positioned(
                bottom: AppSpacing.spaceMd,
                left: AppSpacing.spaceMd,
                child: Text(
                  card.title,
                  style: AppTypography.textTheme.titleMedium?.copyWith(
                    color: AppColors.neutralWhite,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // Bottom-right play/lock icon.
              Positioned(
                bottom: AppSpacing.spaceMd,
                right: AppSpacing.spaceMd,
                child: card.isLocked
                    ? AppIcon(
                        AppIcons.lock,
                        size: AppSpacing.spaceMd,
                        color: AppColors.neutralWhite,
                      )
                    : AppIcon(AppIcons.play, size: AppSpacing.spaceMd),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
