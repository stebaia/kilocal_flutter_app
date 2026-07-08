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
import 'widgets/wellbeing_group_style.dart';

/// Maps an area key to its localized title, illustration asset and header icon.
class _AreaPresentation {
  const _AreaPresentation({
    required this.title,
    required this.assetName,
    required this.iconName,
  });

  final String title;
  final String assetName;
  final String iconName;

  static _AreaPresentation of(String area, AppLocalizations l10n) {
    return switch (area) {
      'allenamento' => _AreaPresentation(
        title: l10n.areaTraining,
        assetName: 'assets/training.png',
        iconName: AppIcons.training,
      ),
      'alimentazione' => _AreaPresentation(
        title: l10n.areaNutrition,
        assetName: 'assets/alimentation.png',
        iconName: AppIcons.food,
      ),
      'benessere' => _AreaPresentation(
        title: l10n.areaWellbeing,
        assetName: 'assets/wellness.png',
        iconName: AppIcons.wellness,
      ),
      'integrazione' => _AreaPresentation(
        title: l10n.areaIntegration,
        assetName: 'assets/name_logo.png',
        iconName: AppIcons.flash,
      ),
      _ => _AreaPresentation(
        title: area,
        assetName: 'assets/training.png',
        iconName: AppIcons.training,
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

    // Benessere is presented as a list of its sub-section cards (Mindfulness,
    // Self care, Stili di vita) rather than the timeframe layout.
    if (data.area == 'benessere' && data.groups.isNotEmpty) {
      return _WellbeingGroupsList(groups: data.groups);
    }

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
          iconName: presentation.iconName,
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
            onTap: data.materialsGroupId == null
                ? null
                : () => _openMaterials(context, data.materialsGroupId!),
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

  void _openMaterials(BuildContext context, String groupId) {
    context.push('/path/${data.area}/materials/$groupId');
  }
}

/// Wellbeing layout: a vertical list of hero cards, one per sub-section group
/// (Mindfulness, Self care, Stili di vita), each showing its own progress.
class _WellbeingGroupsList extends StatelessWidget {
  const _WellbeingGroupsList({required this.groups});

  final List<PathAreaGroup> groups;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenGutter,
        vertical: AppSpacing.spaceMd,
      ),
      itemCount: groups.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.spaceMd),
      itemBuilder: (context, index) {
        final group = groups[index];
        final style = WellbeingGroupStyle.of(group.title, index);
        // Benessere sub-sections show a completed/total badge, where total is the
        // number of steps/materials in the group and completed the user's
        // finished `user_activities` (backend-confirmed, e.g. 7/21). Tapping
        // opens the group's materials hub (categories: Scopri / Consigli utili).
        return PathAreaHeroCard(
          title: group.title,
          assetName: style.assetName,
          iconName: style.iconName,
          completed: group.completed,
          total: group.total,
          onTap: () => context.push(
            '/path/benessere/materials/${group.id}',
            extra: group.title,
          ),
        );
      },
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
          const AppIcon(AppIcons.lock, size: 20),
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
