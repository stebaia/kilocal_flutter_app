import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kilocal_flutter_app/l10n/app_localizations.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/mock_data_factory.dart';
import '../../../core/widgets/localized_bloc_loader.dart';
import 'cubit/statistics_cubit.dart';
import 'widgets/statistics_card.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => StatisticsCubit(),
      child: LocalizedBlocLoader<StatisticsCubit, StatisticsState>(
        load: (context, cubit) {
          final l10n = AppLocalizations.of(context)!;
          cubit.loadWithData(MockDataFactory.statistics(l10n));
        },
        child: const _StatisticsView(),
      ),
    );
  }
}

class _StatisticsView extends StatelessWidget {
  const _StatisticsView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.statisticsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: BlocBuilder<StatisticsCubit, StatisticsState>(
        builder: (context, state) {
          if (state.status == StatisticsStatus.loading) {
            return const Center(child: CircularProgressIndicator());
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
                ),
              );
            },
          );
        },
      ),
    );
  }
}
