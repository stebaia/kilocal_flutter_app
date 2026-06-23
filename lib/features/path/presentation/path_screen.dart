import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:kilocal_flutter_app/l10n/app_localizations.dart';

import '../../../app/di.dart';
import '../../../core/icons/app_icons.dart';
import '../domain/entities/path_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_header.dart';
import '../../statistics/presentation/statistics_screen.dart';
import 'cubit/path_cubit.dart';
import 'widgets/path_area_tile.dart';

class PathScreen extends StatelessWidget {
  const PathScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocProvider(
      create: (_) => getIt<PathCubit>()..load(l10n),
      child: const _PathView(),
    );
  }
}

class _PathView extends StatelessWidget {
  const _PathView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // White header (extends behind the status bar).
          AppHeader(
            title: l10n.pathTitle,
            trailing: GestureDetector(
              onTap: () => context.push(StatisticsScreen.route),
              child: const AppIcon(
                AppIcons.chart,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          // Scrollable content with red band behind the progress card.
          Expanded(
            child: BlocBuilder<PathCubit, PathState>(
              builder: (context, state) {
                switch (state.status) {
                  case PathStatus.loading:
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.accent),
                    );
                  case PathStatus.error:
                    return Center(
                      child: Text(
                        l10n.errorGeneric,
                        style: AppTypography.textTheme.bodyMedium,
                      ),
                    );
                  case PathStatus.loaded:
                    final data = state.data;
                    if (data == null) return const SizedBox.shrink();
                    return _PathContent(data: data);
                  case PathStatus.initial:
                    return const SizedBox.shrink();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PathContent extends StatelessWidget {
  const _PathContent({required this.data});

  final PathData data;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Stack(
      children: [
        // Red header shape from Figma SVG.
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SvgPicture.asset(
            data.headerAssetName,
            fit: BoxFit.fitWidth,
            alignment: Alignment.topCenter,
          ),
        ),
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
                      style: AppTypography.textTheme.titleMedium?.copyWith(
                        color: AppColors.accent,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.spaceMd),
                    Row(
                      children: [
                        Icon(Icons.bolt, color: AppColors.accent),
                        const SizedBox(width: AppSpacing.spaceXs),
                        Text(
                          '${data.overallCompleted}/${data.overallTotal}',
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
                      value: data.overallProgress,
                      backgroundColor: AppColors.accentSoft,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.accent,
                      ),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
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
                children: data.areas
                    .map(
                      (area) => PathAreaTile(
                        title: area.title,
                        assetName: area.assetName,
                        completed: area.completed,
                        total: area.total,
                        onTap: () {
                          // TODO: navigate to area detail when the route is added.
                        },
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: AppSpacing.spaceXl),
            ],
          ),
        ),
      ],
    );
  }
}
