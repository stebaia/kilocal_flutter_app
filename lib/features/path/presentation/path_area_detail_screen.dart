import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/di.dart';
import '../../../core/icons/app_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_header.dart';
import '../../../l10n/app_localizations.dart';
import '../../statistics/presentation/statistics_screen.dart';
import '../domain/entities/path_area_detail.dart';
import 'cubit/path_detail_cubit.dart';
import 'widgets/path_area_hero_card.dart';
import 'widgets/path_materials_row.dart';
import 'widgets/path_section_header.dart';
import 'widgets/path_timeframe_row.dart';

/// Maps an area key to its localized title, illustration asset and header icon.
class _AreaPresentation {
  const _AreaPresentation({
    required this.title,
    required this.assetName,
    required this.icon,
  });

  final String title;
  final String assetName;
  final IconData icon;

  static _AreaPresentation of(String area, AppLocalizations l10n) {
    return switch (area) {
      'allenamento' => _AreaPresentation(
        title: l10n.areaTraining,
        assetName: 'assets/training.png',
        icon: Icons.fitness_center,
      ),
      'alimentazione' => _AreaPresentation(
        title: l10n.areaNutrition,
        assetName: 'assets/alimentation.png',
        icon: Icons.restaurant,
      ),
      'benessere' => _AreaPresentation(
        title: l10n.areaWellbeing,
        assetName: 'assets/wellness.png',
        icon: Icons.spa,
      ),
      'integrazione' => _AreaPresentation(
        title: l10n.areaIntegration,
        assetName: 'assets/name_logo.png',
        icon: Icons.medication,
      ),
      _ => _AreaPresentation(
        title: area,
        assetName: 'assets/training.png',
        icon: Icons.fitness_center,
      ),
    };
  }
}

class PathAreaDetailScreen extends StatelessWidget {
  const PathAreaDetailScreen({super.key, required this.area});

  final String area;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocProvider(
      create: (_) => getIt<PathDetailCubit>()..load(area: area, l10n: l10n),
      child: _PathAreaDetailView(area: area),
    );
  }
}

class _PathAreaDetailView extends StatelessWidget {
  const _PathAreaDetailView({required this.area});

  final String area;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final presentation = _AreaPresentation.of(area, l10n);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppHeader(
            title: presentation.title,
            showBack: true,
            trailing: GestureDetector(
              onTap: () => context.push(StatisticsScreen.route),
              child: const AppIcon(
                AppIcons.chart,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<PathDetailCubit, PathDetailState>(
              builder: (context, state) {
                switch (state.status) {
                  case PathDetailStatus.loading:
                  case PathDetailStatus.initial:
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.accent),
                    );
                  case PathDetailStatus.error:
                    return Center(
                      child: Text(
                        l10n.errorGeneric,
                        style: AppTypography.textTheme.bodyMedium,
                      ),
                    );
                  case PathDetailStatus.loaded:
                    final data = state.data;
                    if (data == null) return const SizedBox.shrink();
                    return _PathAreaDetailContent(
                      data: data,
                      presentation: presentation,
                    );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PathAreaDetailContent extends StatelessWidget {
  const _PathAreaDetailContent({
    required this.data,
    required this.presentation,
  });

  final PathAreaDetail data;
  final _AreaPresentation presentation;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final groups = data.timeframeGroups;

    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenGutter,
        vertical: AppSpacing.spaceMd,
      ),
      children: [
        PathAreaHeroCard(
          title: presentation.title,
          assetName: presentation.assetName,
          completed: data.completed,
          total: data.total,
          icon: presentation.icon,
        ),
        const SizedBox(height: AppSpacing.spaceLg),
        PathSectionHeader(
          title: l10n.pathAreaProgressLabel,
          trailing: l10n.pathCompletedPercent(data.percent),
        ),
        const SizedBox(height: AppSpacing.spaceSm),
        if (data.isLocked) ...[
          _AreaLockedBanner(message: l10n.pathAreaLocked),
          const SizedBox(height: AppSpacing.spaceSm),
        ],
        for (var i = 0; i < groups.length; i++)
          PathTimeframeRow(
            group: groups[i],
            subtitle: _timeframeSubtitle(l10n, groups[i]),
            showConnectorTop: i > 0,
            showConnectorBottom: i < groups.length - 1,
            onTap: groups[i].isLocked
                ? null
                : () => _openTimeframe(context, groups[i]),
          ),
        if (data.hasMaterials) ...[
          const SizedBox(height: AppSpacing.spaceSm),
          const Divider(height: 1, color: AppColors.dividerStrong),
          const SizedBox(height: AppSpacing.spaceSm),
          PathMaterialsRow(
            title: l10n.pathMaterialsTitle,
            subtitle: l10n.pathMaterialsSubtitle,
            onTap: () {},
          ),
        ],
        const SizedBox(height: AppSpacing.spaceXl),
      ],
    );
  }

  String _timeframeSubtitle(AppLocalizations l10n, PathTimeframeGroup group) {
    if (group.isLocked) return l10n.pathTimeframeLocked;
    if (group.isCurrent) return l10n.pathTimeframeCurrent;
    return l10n.pathTimeframeStepsCount(group.total);
  }

  void _openTimeframe(BuildContext context, PathTimeframeGroup group) {
    context.push(
      '/path/${data.area}/timeframe/${group.timeframeId}',
      extra: group,
    );
  }
}

/// Banner shown at the top of the area detail when the whole area is locked
/// (`access.percorso_locked`).
class _AreaLockedBanner extends StatelessWidget {
  const _AreaLockedBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.borderCard),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.spaceSm),
          Expanded(
            child: Text(
              message,
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
