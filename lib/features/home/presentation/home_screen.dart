import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:kilocal_flutter_app/l10n/app_localizations.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/mock_data_factory.dart';
import '../../../core/widgets/localized_bloc_loader.dart';
import 'cubit/home_cubit.dart';
import 'widgets/action_cards_grid.dart';
import 'widgets/continue_path_card.dart';
import 'widgets/home_header.dart';
import 'widgets/month_stats_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeCubit(),
      child: LocalizedBlocLoader<HomeCubit, HomeState>(
        load: (context, cubit) {
          final l10n = AppLocalizations.of(context)!;
          cubit.loadWithData(MockDataFactory.homeData(l10n));
        },
        child: const _HomeView(),
      ),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.paddingOf(context).top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.surface,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            // White filler behind the status bar.
            Container(color: AppColors.surface, height: statusBarHeight),
            Expanded(
              child: SafeArea(
                top: false,
                child: BlocBuilder<HomeCubit, HomeState>(
                  builder: (context, state) {
                    if (state.status == HomeStatus.loading ||
                        state.data == null) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final data = state.data!;
                    final dateLabel = DateFormat(
                      'EEEE d MMMM',
                      Localizations.localeOf(context).languageCode,
                    ).format(data.currentDate);

                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.screenGutter,
                              vertical: AppSpacing.spaceMd,
                            ),
                            color: AppColors.surface,
                            child: HomeHeader(
                              dateLabel: dateLabel,
                              userName: data.userName,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.screenGutter,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: AppSpacing.spaceLg),
                                ContinuePathCard(item: data.continuePath),
                                const SizedBox(height: AppSpacing.spaceLg),
                                MonthStatsCard(stats: data.monthStats),
                                const SizedBox(height: AppSpacing.spaceLg),
                                ActionCardsGrid(cards: data.actionCards),
                                const SizedBox(height: AppSpacing.spaceXl),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
