import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/icons/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/home_data.dart';

class ContinuePathCard extends StatelessWidget {
  const ContinuePathCard({super.key, required this.item});

  final ContinuePathItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    const cardRadius = 16.0;
    const imageOverflow = 20.0;
    const imageSize = 157.0;
    const minGap = AppSpacing.spaceSm;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => context.go('/path'),
      child: SizedBox(
        height: 220,
        child: Stack(
          children: [
            // Red card.
            Positioned(
              top: imageOverflow,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppColors.brandGradient,
                  borderRadius: BorderRadius.circular(cardRadius),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(cardRadius),
                  child: Stack(
                    children: [
                      // Decorative ribbon at the bottom-left.
                      Positioned(
                        bottom: -1,
                        left: -10,
                        child: Transform.rotate(
                          angle: -0.1,
                          child: SvgPicture.asset(
                            'assets/icons/line.svg',
                            width: 150,
                            height: 80,
                          ),
                        ),
                      ),
                      // White text box on the left. Right-constrained (rather
                      // than a fixed width) so it never crowds the image on
                      // narrow screens.
                      Positioned(
                        top: AppSpacing.spaceLg,
                        left: AppSpacing.spaceLg,
                        right: AppSpacing.spaceLg + imageSize + minGap,
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.spaceMd),
                          decoration: BoxDecoration(
                            color: AppColors.neutralWhite,
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                          ),
                          child: Text(
                            item.title,
                            style: AppTypography.textTheme.bodyMedium,
                          ),
                        ),
                      ),
                      // Bottom-right CTA.
                      Positioned(
                        bottom: AppSpacing.spaceMid,
                        right: AppSpacing.spaceLg,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              item.hasStarted
                                  ? l10n.homeContinuePath
                                  : l10n.homeStartPath,
                              style: AppTypography.textTheme.bodyMedium
                                  ?.copyWith(
                                    color: AppColors.neutralWhite,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(width: AppSpacing.spaceSm),
                            AppIcon(AppIcons.play, size: 24),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Hero image overflowing the top of the red card, on the right.
            Positioned(
              top: 0,
              right: AppSpacing.spaceLg,
              child: Container(
                width: imageSize,
                height: imageSize,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: AppColors.neutralWhite,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  child: _buildImage(item.imageUrl),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String imageUrl) {
    if (imageUrl.startsWith('assets/')) {
      return Image.asset(imageUrl, fit: BoxFit.cover);
    }
    return Image.network(imageUrl, fit: BoxFit.cover);
  }
}
