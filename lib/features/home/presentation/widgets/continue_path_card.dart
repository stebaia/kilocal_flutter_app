import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/icons/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/home_data.dart';
import '../../../../../core/widgets/cms_image.dart';

class ContinuePathCard extends StatelessWidget {
  const ContinuePathCard({super.key, required this.item});

  final ContinuePathItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    const cardRadius = 16.0;
    const imageOverflow = 20.0;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        final area = item.area;
        final stepId = item.stepId;
        if (area != null && stepId != null) {
          context.push('/path/$area/step/$stepId');
        } else {
          context.push('/path');
        }
      },
      child: SizedBox(
        width: double.infinity,
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
                      // Bottom-right CTA.
                      Positioned(
                        bottom: AppSpacing.spaceMid,
                        left: 25,
                        right: 25,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
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
                            AppIcon(AppIcons.play, size: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Hero image overflowing the top of the red card, on the right.
            // Capped at its design width (293) but shrinks on narrow screens
            // (e.g. iPhone SE) so it never overflows the card's left edge.
            Positioned(
              top: 0,
              left: AppSpacing.spaceLg,
              right: AppSpacing.spaceLg,
              child: Align(
                alignment: Alignment.centerRight,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 293),
                  child: Container(
                    height: 161,
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
              ),
            ),

            Positioned(
              top: 14,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.neutralWhite,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: Text(
                    item.title,
                    style: AppTypography.textTheme.bodySmall?.copyWith(
                      fontSize: 12,
                    ),
                  ),
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
    return CmsImage(imageUrl, fit: BoxFit.cover);
  }
}
