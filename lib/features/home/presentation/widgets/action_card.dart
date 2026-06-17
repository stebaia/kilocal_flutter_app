import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/icons/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/home_data.dart';
import 'action_card_illustration.dart';

class ActionCard extends StatelessWidget {
  const ActionCard({super.key, required this.card});

  final HomeActionCard card;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(card.route),
      child: Container(
        height: 165,
        width: 159,
        decoration: BoxDecoration(
          gradient: AppColors.brandGradientVertical,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: AppShadows.card,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Stack(
            children: [
              // Top-center illustration.
              Positioned(
                top: AppSpacing.spaceMd,
                left: 0,
                right: 0,
                child: Center(
                  child: ActionCardIllustration(
                    imageUrl: card.imageUrl,
                    assetName: card.assetName,
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
              // Bottom-right play icon.
              Positioned(
                bottom: AppSpacing.spaceMd,
                right: AppSpacing.spaceMd,
                child: AppIcon(AppIcons.play, size: AppSpacing.spaceMd),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
