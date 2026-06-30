import 'package:flutter/material.dart';
import 'package:kilocal_flutter_app/core/icons/app_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../home/presentation/widgets/action_card_illustration.dart';

/// Large red hero card at the top of an area detail: the area icon and title,
/// the `completed/total` figure and the area illustration inside a soft circle.
class PathAreaHeroCard extends StatelessWidget {
  const PathAreaHeroCard({
    super.key,
    required this.title,
    required this.assetName,
    required this.completed,
    required this.total,
    this.iconName,
  });

  final String title;
  final String assetName;
  final int completed;
  final int total;
  final String? iconName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24),
      height: 180,
      decoration: BoxDecoration(
        gradient: AppColors.brandGradientVertical,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (iconName != null) ...[
                    AppIcon(iconName!, color: AppColors.neutralWhite, size: 22),
                    const SizedBox(width: AppSpacing.spaceSm),
                  ],
                  Text(
                    title,
                    style: AppTypography.textTheme.titleMedium?.copyWith(
                      color: AppColors.neutralWhite,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Spacer(),
              Row(
                children: [
                  const AppIcon(
                    AppIcons.flash,
                    color: AppColors.neutralWhite,
                    size: 24,
                  ),
                  const SizedBox(width: AppSpacing.spaceXs),
                  Text(
                    '$completed/$total',
                    style: AppTypography.textTheme.headlineSmall?.copyWith(
                      color: AppColors.neutralWhite,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Stack(
            children: [
              Container(
                width: 132,
                height: 132,
                decoration: BoxDecoration(
                  color: AppColors.kilokalPink,
                  shape: BoxShape.circle,
                ),
                child: ActionCardIllustration(
                  imageUrl: '',
                  assetName: assetName,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    /* ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Stack(
          children: [
            // Illustration inside a soft circle on the right.
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: Center(
                child: Container(
                  width: 132,
                  height: 132,
                  decoration: BoxDecoration(
                    color: AppColors.kilokalPink,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: ActionCardIllustration(
                    imageUrl: '',
                    assetName: assetName,
                  ),
                ),
              ),
            ),
            // Title + icon top-left.
            Positioned(
              top: AppSpacing.spaceLg,
              left: AppSpacing.spaceLg,
              child: Row(
                children: [
                  if (iconName != null) ...[
                    AppIcon(
                      iconName!,
                      color: AppColors.neutralWhite,
                      size: 22,
                    ),
                    const SizedBox(width: AppSpacing.spaceSm),
                  ],
                  Text(
                    title,
                    style: AppTypography.textTheme.titleMedium?.copyWith(
                      color: AppColors.neutralWhite,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            // Completed/total bottom-left.
            Positioned(
              bottom: AppSpacing.spaceLg,
              left: AppSpacing.spaceLg,
              child: Row(
                children: [
                  const AppIcon(
                    AppIcons.flash,
                    color: AppColors.neutralWhite,
                    size: 24,
                  ),
                  const SizedBox(width: AppSpacing.spaceXs),
                  Text(
                    '$completed/$total',
                    style: AppTypography.textTheme.headlineSmall?.copyWith(
                      color: AppColors.neutralWhite,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );*/
  }
}
