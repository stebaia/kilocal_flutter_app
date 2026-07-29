import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kilocal_flutter_app/l10n/app_localizations.dart';

import '../../../app/di.dart';
import '../../../core/icons/app_icons.dart';
import '../../../core/theme/app_spacing.dart';
import 'cubit/statistics_cubit.dart';
import 'widgets/statistics_card.dart';
import 'widgets/statistics_timeframe_sheet.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  static const String route = '/statistics';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocProvider(
      create: (_) => getIt<StatisticsCubit>()..load(l10n),
      child: const _StatisticsView(),
    );
  }
}

class _StatisticsView extends StatelessWidget {
  const _StatisticsView();

  Future<void> _openTimeframeFilter(BuildContext context) async {
    final cubit = context.read<StatisticsCubit>();
    final l10n = AppLocalizations.of(context)!;
    final timeframes = await cubit.fetchTimeframes(
      l10n,
      referenceArea: StatisticsCubit.referenceArea,
    );
    if (!context.mounted) return;
    final selected = await showStatisticsTimeframeSheet(
      context,
      timeframes: timeframes,
      selectedTimeframeId: cubit.state.selectedTimeframe?.id,
    );
    if (selected == null) return;
    if (!context.mounted) return;
    await cubit.selectTimeframe(l10n, selected);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.statisticsTitle),
        actions: [
          IconButton(
            icon: const AppIcon(AppIcons.calendarFilter, size: 24),
            tooltip: l10n.statisticsTimeframeSheetTitle,
            onPressed: () => _openTimeframeFilter(context),
          ),
        ],
      ),
      // top: false — the AppBar insets the status bar; SafeArea guards only the
      // bottom against the Android system navigation bar.
      body: SafeArea(
        top: false,
        child: BlocBuilder<StatisticsCubit, StatisticsState>(
          builder: (context, state) {
            if (state.status == StatisticsStatus.loading ||
                state.status == StatisticsStatus.initial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == StatisticsStatus.error && state.stats.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.screenGutter),
                  child: Text(l10n.errorGeneric, textAlign: TextAlign.center),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenGutter,
                vertical: AppSpacing.spaceMd,
              ),
              itemCount: state.stats.length,
              itemBuilder: (context, index) {
                final stat = state.stats[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.spaceSm),
                  child: StatisticsCard(
                    stat: stat,
                    activitiesCount: l10n.activitiesCount(
                      stat.completed,
                      stat.total,
                    ),
                    // `integrazione` is phase-based and keeps its lifetime
                    // figures under the month filter, so it also keeps its
                    // own "Fase 1" label instead of the month title.
                    monthLabelOverride: stat.id == 'integrazione'
                        ? null
                        : state.selectedTimeframe?.title,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
