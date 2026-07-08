part of 'diary_goals_cubit.dart';

enum DiaryGoalsStatus { initial, loading, loaded, error }

class DiaryGoalsState extends Equatable {
  const DiaryGoalsState({
    this.status = DiaryGoalsStatus.initial,
    this.goals = const [],
    this.filter = GoalFilter.all,
    this.categories = const [],
  });

  final DiaryGoalsStatus status;
  final List<DiaryGoal> goals;
  final GoalFilter filter;
  final List<GoalCategory> categories;

  /// Goals after applying the current [filter] — all derived client-side.
  List<DiaryGoal> get visibleGoals {
    switch (filter) {
      case GoalFilter.all:
        return goals;
      case GoalFilter.personal:
        return goals.where((g) => g.kind == DiaryGoalKind.personal).toList();
      case GoalFilter.kilocal:
        return goals.where((g) => g.kind == DiaryGoalKind.kilocal).toList();
      case GoalFilter.completed:
        return goals.where((g) => g.isCompleted).toList();
    }
  }

  DiaryGoalsState copyWith({
    DiaryGoalsStatus? status,
    List<DiaryGoal>? goals,
    GoalFilter? filter,
    List<GoalCategory>? categories,
  }) {
    return DiaryGoalsState(
      status: status ?? this.status,
      goals: goals ?? this.goals,
      filter: filter ?? this.filter,
      categories: categories ?? this.categories,
    );
  }

  @override
  List<Object?> get props => [status, goals, filter, categories];
}
