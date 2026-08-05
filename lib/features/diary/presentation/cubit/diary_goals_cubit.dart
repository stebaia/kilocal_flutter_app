import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../survey/domain/survey_repository.dart';
import '../../domain/diary_repository.dart';
import '../../domain/entities/diary_goal.dart';
import '../../domain/entities/goal_category.dart';

part 'diary_goals_state.dart';

/// Loads and mutates diary **goals** (Traguardi), plus the client-side filter.
class DiaryGoalsCubit extends Cubit<DiaryGoalsState> {
  DiaryGoalsCubit({
    required DiaryRepository repository,
    required SurveyRepository surveyRepository,
  }) : _repository = repository,
       _surveyRepository = surveyRepository,
       super(const DiaryGoalsState());

  final DiaryRepository _repository;
  final SurveyRepository _surveyRepository;

  Future<void> load() async {
    emit(state.copyWith(status: DiaryGoalsStatus.loading));
    // The predefined Kilocal goals (`traguardo_mese_N`) are materialised by the
    // backend as a side-effect of the month-end check, so it must run *before*
    // fetchGoals or they'd be missing until the next visit. A failure here only
    // costs this month's Kilocal goal, so it must not block the list.
    try {
      await _surveyRepository.fetchMonthEndStatus();
    } catch (_) {}
    try {
      final goals = await _repository.fetchGoals();
      emit(
        state.copyWith(
          status: DiaryGoalsStatus.loaded,
          goals: _sortByDueDate(goals),
        ),
      );
    } catch (_) {
      emit(state.copyWith(status: DiaryGoalsStatus.error));
    }
    // Categories back the create picker; failure here shouldn't block the list.
    if (state.categories.isEmpty) {
      try {
        final categories = await _repository.fetchCategories();
        emit(state.copyWith(categories: categories));
      } catch (_) {}
    }
  }

  void setFilter(GoalFilter filter) => emit(state.copyWith(filter: filter));

  Future<void> createGoal(DiaryGoalInput input) async {
    try {
      final created = await _repository.createGoal(input);
      emit(state.copyWith(goals: _sortByDueDate([created, ...state.goals])));
    } catch (_) {
      emit(state.copyWith(status: DiaryGoalsStatus.error));
    }
  }

  Future<void> updateGoal(DiaryGoal goal, DiaryGoalInput input) async {
    try {
      final updated = await _repository.updateGoal(goal.id, input);
      emit(state.copyWith(goals: _sortByDueDate(_replace(updated))));
    } catch (_) {
      emit(state.copyWith(status: DiaryGoalsStatus.error));
    }
  }

  /// Returns `true` on success, `false` if the write failed (so the caller
  /// can surface a transient error without hiding the list).
  Future<bool> toggleCompleted(DiaryGoal goal) async {
    final target = !goal.isCompleted;
    final previous = state.goals;
    // Optimistic update; on failure, revert to the pre-toggle list rather than
    // reloading from the server. A reload re-runs fetchMonthEndStatus(), which
    // only re-materialises a Kilocal goal while its survey is still "pending" —
    // once it isn't, a failed PATCH followed by a reload could drop the goal
    // from state.goals entirely, vanishing it from every filter (including
    // "Tutti"). Reverting locally keeps the goal in place regardless, and
    // keeps `status` at `loaded` so the list stays visible.
    emit(
      state.copyWith(
        goals: _replace(
          goal.copyWith(
            completedAt: target ? DateTime.now() : null,
            clearCompletedAt: !target,
          ),
        ),
      ),
    );
    try {
      await _repository.updateGoalCompletion(id: goal.id, completed: target);
      return true;
    } catch (_) {
      emit(state.copyWith(goals: previous));
      return false;
    }
  }

  Future<void> deleteGoal(DiaryGoal goal) async {
    final previous = state.goals;
    emit(
      state.copyWith(goals: previous.where((g) => g.id != goal.id).toList()),
    );
    try {
      await _repository.deleteGoal(goal.id);
    } catch (_) {
      emit(state.copyWith(goals: previous, status: DiaryGoalsStatus.error));
    }
  }

  /// Chronological order: nearest due date first, furthest last. Goals without
  /// a due date have no place on the timeline, so they sink to the bottom.
  List<DiaryGoal> _sortByDueDate(List<DiaryGoal> goals) {
    return [...goals]..sort((a, b) {
      final aDate = a.dueDate;
      final bDate = b.dueDate;
      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1;
      if (bDate == null) return -1;
      return aDate.compareTo(bDate);
    });
  }

  List<DiaryGoal> _replace(DiaryGoal updated) {
    return [
      for (final g in state.goals)
        if (g.id == updated.id) updated else g,
    ];
  }
}
