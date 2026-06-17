import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:kilocal_flutter_app/l10n/app_localizations.dart';

import '../../../core/icons/app_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';
import 'widgets/path_area_tile.dart';

class PathScreen extends StatelessWidget {
  const PathScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final statusBarHeight = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // White header (extends behind the status bar).
          Container(
            color: AppColors.surface,
            padding: EdgeInsets.only(
              top: statusBarHeight,
              left: AppSpacing.screenGutter,
              right: AppSpacing.screenGutter,
              bottom: AppSpacing.spaceMd,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.pathTitle,
                  style: AppTypography.textTheme.headlineLarge,
                ),
                GestureDetector(
                  onTap: () => context.push('/statistics'),
                  child: const AppIcon(
                    AppIcons.chart,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          // Scrollable content with red band behind the progress card.
          Expanded(
            child: Stack(
              children: [
                // Red header shape from Figma SVG.
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SvgPicture.asset(
                    'assets/path_header_ellipse.svg',
                    fit: BoxFit.fitWidth,
                    alignment: Alignment.topCenter,
                  ),
                ),
                // Scrollable content.
                SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenGutter,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppSpacing.spaceLg),
                      // Overall progress card.
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.pathOverallProgress,
                              style: AppTypography.textTheme.titleMedium
                                  ?.copyWith(color: AppColors.accent),
                            ),
                            const SizedBox(height: AppSpacing.spaceMd),
                            Row(
                              children: [
                                Icon(Icons.bolt, color: AppColors.accent),
                                const SizedBox(width: AppSpacing.spaceXs),
                                Text(
                                  '23/132',
                                  style: AppTypography.numericAccent,
                                ),
                                const Spacer(),
                                Text(
                                  l10n.pathActivitiesCompleted,
                                  style: AppTypography.textTheme.labelMedium,
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.spaceMd),
                            LinearProgressIndicator(
                              value: 23 / 132,
                              backgroundColor: AppColors.accentSoft,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.accent,
                              ),
                              minHeight: 8,
                              borderRadius: BorderRadius.circular(
                                AppRadius.pill,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.spaceLg),
                      // Area cards grid.
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: AppSpacing.spaceMd,
                        crossAxisSpacing: AppSpacing.spaceMd,
                        childAspectRatio: 0.95,
                        children: [
                          PathAreaTile(
                            title: l10n.areaTraining,
                            assetName: 'assets/training.png',
                            completed: 3,
                            total: 34,
                          ),
                          PathAreaTile(
                            title: l10n.areaNutrition,
                            assetName: 'assets/alimentation.png',
                            completed: 1,
                            total: 28,
                          ),
                          PathAreaTile(
                            title: l10n.areaWellbeing,
                            assetName: 'assets/wellness.png',
                            completed: 1,
                            total: 27,
                          ),
                          PathAreaTile(
                            title: l10n.areaIntegration,
                            assetName: 'assets/name_logo.png',
                            completed: 5,
                            total: 26,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.spaceXl),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
