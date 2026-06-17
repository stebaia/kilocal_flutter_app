import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/icons/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/home_data.dart';

class ActionCard extends StatelessWidget {
  const ActionCard({super.key, required this.card});

  final HomeActionCard card;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(card.route),
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          gradient: AppColors.brandGradient,
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
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    child: Image.network(
                      card.imageUrl,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
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
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // Bottom-right play icon.
              Positioned(
                bottom: AppSpacing.spaceMd,
                right: AppSpacing.spaceMd,
                child: AppIcon(AppIcons.play, size: 24),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
