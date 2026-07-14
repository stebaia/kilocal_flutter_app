import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kilocal_flutter_app/l10n/app_localizations.dart';

import '../../../app/di.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_header.dart';
import 'cubit/diary_goals_cubit.dart';
import 'cubit/diary_history_cubit.dart';
import 'widgets/create_goal_sheet.dart';
import 'widgets/diary_filter_sheet.dart';
import 'widgets/diary_goal_card.dart';
import 'widgets/diary_hero_card.dart';
import 'widgets/diary_history_card.dart';
import 'widgets/diary_tab_switch.dart';

class DiaryScreen extends StatelessWidget {
  const DiaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<DiaryHistoryCubit>()..load()),
        BlocProvider(create: (_) => getIt<DiaryGoalsCubit>()..load()),
      ],
      child: const _DiaryView(),
    );
  }
}

class _DiaryView extends StatefulWidget {
  const _DiaryView();

  @override
  State<_DiaryView> createState() => _DiaryViewState();
}

class _DiaryViewState extends State<_DiaryView> {
  DiaryTab _tab = DiaryTab.history;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isGoals = _tab == DiaryTab.goals;

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: isGoals
          ? FloatingActionButton(
              backgroundColor: AppColors.surface,
              foregroundColor: AppColors.accent,
              onPressed: _onCreateGoal,
              child: const Icon(Icons.add),
            )
          : null,
      // top: false — AppHeader insets the status bar; SafeArea guards only the
      // bottom against the Android system navigation bar.
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppHeader(
              title: l10n.diaryTitle,
              trailing: isGoals
                  ? GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _onFilter,
                      child: const Icon(
                        Icons.tune,
                        color: AppColors.textPrimary,
                      ),
                    )
                  : null,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenGutter,
                AppSpacing.spaceMd,
                AppSpacing.screenGutter,
                AppSpacing.spaceSm,
              ),
              child: DiaryTabSwitch(
                selected: _tab,
                onChanged: (t) => setState(() => _tab = t),
                historyLabel: l10n.diaryTabHistory,
                goalsLabel: l10n.diaryTabGoals,
              ),
            ),
            Expanded(
              child: isGoals ? _GoalsTab(l10n: l10n) : _HistoryTab(l10n: l10n),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onFilter() async {
    final cubit = context.read<DiaryGoalsCubit>();
    final picked = await showDiaryFilterSheet(
      context,
      current: cubit.state.filter,
    );
    if (picked != null) cubit.setFilter(picked);
  }

  Future<void> _onCreateGoal() async {
    final cubit = context.read<DiaryGoalsCubit>();
    final input = await showCreateGoalSheet(
      context,
      categories: cubit.state.categories,
    );
    if (input != null) await cubit.createGoal(input);
  }
}

class _HistoryTab extends StatelessWidget {
  const _HistoryTab({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DiaryHistoryCubit, DiaryHistoryState>(
      builder: (context, state) {
        final children = <Widget>[
          DiaryHeroCard(
            title: l10n.diaryTabHistory,
            assetName: 'assets/diary.png',
          ),
          const SizedBox(height: AppSpacing.spaceMd),
        ];

        switch (state.status) {
          case DiaryHistoryStatus.loading:
          case DiaryHistoryStatus.initial:
            children.add(const _Loader());
          case DiaryHistoryStatus.error:
            children.add(_ErrorText(message: l10n.retry));
          case DiaryHistoryStatus.loaded:
            if (state.activities.isEmpty) {
              children.add(_EmptyText(message: l10n.diaryHistoryEmpty));
            } else {
              for (final activity in state.activities) {
                children.add(
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.spaceSm),
                    child: DiaryHistoryCard(activity: activity),
                  ),
                );
              }
            }
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenGutter,
            0,
            AppSpacing.screenGutter,
            AppSpacing.spaceLg,
          ),
          children: children,
        );
      },
    );
  }
}

class _GoalsTab extends StatelessWidget {
  const _GoalsTab({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DiaryGoalsCubit, DiaryGoalsState>(
      builder: (context, state) {
        final cubit = context.read<DiaryGoalsCubit>();
        final children = <Widget>[
          DiaryHeroCard(
            title: l10n.diaryTabGoals,
            assetName: 'assets/goal.png',
          ),
          const SizedBox(height: AppSpacing.spaceMd),
        ];

        switch (state.status) {
          case DiaryGoalsStatus.loading:
          case DiaryGoalsStatus.initial:
            children.add(const _Loader());
          case DiaryGoalsStatus.error:
            children.add(_ErrorText(message: l10n.retry));
          case DiaryGoalsStatus.loaded:
            final goals = state.visibleGoals;
            if (goals.isEmpty) {
              children.add(_EmptyText(message: l10n.diaryGoalsEmpty));
            } else {
              for (final goal in goals) {
                children.add(
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.spaceSm),
                    child: DiaryGoalCard(
                      goal: goal,
                      onToggle: () => cubit.toggleCompleted(goal),
                      onDelete: () => cubit.deleteGoal(goal),
                    ),
                  ),
                );
              }
            }
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenGutter,
            0,
            AppSpacing.screenGutter,
            AppSpacing.spaceXl * 2,
          ),
          children: children,
        );
      },
    );
  }
}

class _Loader extends StatelessWidget {
  const _Loader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: AppSpacing.spaceXl),
      child: Center(child: CircularProgressIndicator(color: AppColors.accent)),
    );
  }
}

class _EmptyText extends StatelessWidget {
  const _EmptyText({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.spaceXl),
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: AppTypography.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _ErrorText extends StatelessWidget {
  const _ErrorText({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.spaceXl),
      child: Center(
        child: Text(
          message,
          style: AppTypography.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
