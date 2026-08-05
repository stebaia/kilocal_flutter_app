import 'package:flutter/material.dart';
import 'package:kilocal_flutter_app/l10n/app_localizations.dart';

import '../../../../core/icons/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../home/presentation/widgets/action_card_illustration.dart';

/// Square gradient card for a path area (training, nutrition, wellbeing,
/// integration) shown on the path screen.
///
/// When [isRestricted] is true the card renders the locked variant: the
/// illustration is dimmed, the counter is replaced by a "Bloccato" label and
/// the play button becomes a dark lock badge. Tapping still fires [onTap] (the
/// caller opens the unlock bottom sheet).
class PathAreaTile extends StatelessWidget {
  const PathAreaTile({
    super.key,
    required this.title,
    required this.assetName,
    required this.completed,
    required this.total,
    this.isRestricted = false,
    this.onTap,
  });

  final String title;
  final String assetName;
  final int completed;
  final int total;
  final bool isRestricted;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: AppColors.brandGradientVertical,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: AppShadows.card,
        ),
        child: Column(
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                style: AppTypography.textTheme.titleMedium?.copyWith(
                  color: AppColors.neutralWhite,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  height: 1.15,
                ),
              ),
            ),
            const SizedBox(height: 13),
            // Expanded + FittedBox instead of a hardcoded 100x100: the circle
            // fills whatever vertical space is left after the title/counter,
            // so it shrinks gracefully on narrower devices or with a larger
            // system font instead of overflowing the fixed-aspect-ratio grid
            // cell (see the "4 blocchi non responsive" report).
            Expanded(
              child: FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: Opacity(
                    // Dim the illustration to signal the locked state.
                    opacity: isRestricted ? 0.45 : 1,
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: AppColors.kilokalPink,
                          ),
                        ),
                        OverflowBox(
                          maxWidth: 130,
                          maxHeight: 90,
                          child: PathActionCardImage(
                            imageUrl: '',
                            assetName: assetName,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    isRestricted
                        ? l10n.pathTimeframeLocked
                        : '$completed/$total',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: AppColors.neutralWhite,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.spaceSm),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isRestricted
                        ? AppColors.ink
                        : AppColors.neutralWhite,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isRestricted
                        ? const AppIcon(
                            AppIcons.lock,
                            size: 16,
                            color: AppColors.neutralWhite,
                          )
                        : const AppIcon(
                            AppIcons.playSmall,
                            size: 10,
                            color: AppColors.accent,
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/*ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Stack(
            children: [
              // Top-left title.
              Positioned(
                top: AppSpacing.spaceMd,
                left: AppSpacing.spaceMd,
                child: Text(
                  title,
                  style: AppTypography.textTheme.titleMedium?.copyWith(
                    color: AppColors.neutralWhite,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // Center illustration.
              Positioned(
                top: AppSpacing.spaceMd + 24,
                left: 0,
                right: 0,
                child: Center(
                  child: ActionCardIllustration(
                    imageUrl: '',
                    assetName: assetName,
                  ),
                ),
              ),
              // Bottom-left activity counter.
              Positioned(
                bottom: AppSpacing.spaceMd,
                left: AppSpacing.spaceMd,
                child: Text(
                  l10n.activitiesCount(completed, total),
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: AppColors.neutralWhite,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // Bottom-right play button.
              Positioned(
                bottom: AppSpacing.spaceMd,
                right: AppSpacing.spaceMd,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: AppColors.neutralWhite,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: AppIcon(
                      AppIcons.play,
                      size: 12,
                      color: AppColors.accent,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }*/
