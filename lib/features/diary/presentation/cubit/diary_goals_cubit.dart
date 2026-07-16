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
      emit(state.copyWith(status: DiaryGoalsStatus.loaded, goals: goals));
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
      emit(state.copyWith(goals: [created, ...state.goals]));
    } catch (_) {
      emit(state.copyWith(status: DiaryGoalsStatus.error));
    }
  }

  Future<void> toggleCompleted(DiaryGoal goal) async {
    final target = !goal.isCompleted;
    // Optimistic update; revert on failure by reloading.
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
    } catch (_) {
      await load();
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

  List<DiaryGoal> _replace(DiaryGoal updated) {
    return [
      for (final g in state.goals)
        if (g.id == updated.id) updated else g,
    ];
  }
}
