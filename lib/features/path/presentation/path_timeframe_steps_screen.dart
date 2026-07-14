import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/di.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_header.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/entities/path_area_detail.dart';
import 'cubit/path_detail_cubit.dart';
import 'widgets/path_step_tile.dart';

/// Lists the steps of a single timeframe (e.g. "1° mese") of an area.
class PathTimeframeStepsScreen extends StatelessWidget {
  const PathTimeframeStepsScreen({
    super.key,
    required this.area,
    required this.timeframeId,
    this.group,
  });

  final String area;
  final int timeframeId;
  final PathTimeframeGroup? group;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocProvider(
      create: (_) => getIt<PathDetailCubit>()..load(area: area, l10n: l10n),
      child: _PathTimeframeStepsView(
        area: area,
        timeframeId: timeframeId,
        initialGroup: group,
      ),
    );
  }
}

class _PathTimeframeStepsView extends StatelessWidget {
  const _PathTimeframeStepsView({
    required this.area,
    required this.timeframeId,
    this.initialGroup,
  });

  final String area;
  final int timeframeId;
  final PathTimeframeGroup? initialGroup;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.surface,
      // top: false — AppHeader insets the status bar; SafeArea guards only the
      // bottom against the Android system navigation bar.
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppHeader(title: initialGroup?.title ?? '', showBack: true),
            Expanded(
              child: BlocBuilder<PathDetailCubit, PathDetailState>(
                builder: (context, state) {
                  final group = _resolveGroup(state);

                  if (group == null &&
                      state.status == PathDetailStatus.loading) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.accent),
                    );
                  }

                  if (group == null) {
                    return Center(
                      child: Text(
                        l10n.errorGeneric,
                        style: AppTypography.textTheme.bodyMedium,
                      ),
                    );
                  }

                  return _TimeframeStepsList(group: group, area: area);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  PathTimeframeGroup? _resolveGroup(PathDetailState state) {
    if (initialGroup != null && state.status != PathDetailStatus.loaded) {
      return initialGroup;
    }
    final data = state.data;
    if (data == null) return initialGroup;
    for (final group in data.timeframeGroups) {
      if (group.timeframeId == timeframeId) return group;
    }
    return initialGroup;
  }
}

class _TimeframeStepsList extends StatelessWidget {
  const _TimeframeStepsList({required this.group, required this.area});

  final PathTimeframeGroup group;
  final String area;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenGutter,
        vertical: AppSpacing.spaceMd,
      ),
      itemCount: group.steps.length,
      separatorBuilder: (_, _) =>
          const Divider(height: 1, color: AppColors.divider),
      itemBuilder: (context, index) {
        final step = group.steps[index];
        return PathStepTile(
          step: step,
          area: area,
          onTap: () => _openStep(context, step),
        );
      },
    );
  }

  Future<void> _openStep(BuildContext context, PathStepItem step) async {
    final result = await context.push(
      '/path/$area/step/${step.id}',
      extra: step,
    );
    if (result == true && context.mounted) {
      context.read<PathDetailCubit>().load(
        area: area,
        l10n: AppLocalizations.of(context)!,
      );
    }
  }
}
