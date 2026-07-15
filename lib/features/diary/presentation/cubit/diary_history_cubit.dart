import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/diary_repository.dart';
import '../../domain/entities/diary_activity.dart';

part 'diary_history_state.dart';

/// Loads the diary **history** (Cronologia) — read-only `user_activities`.
class DiaryHistoryCubit extends Cubit<DiaryHistoryState> {
  DiaryHistoryCubit({required DiaryRepository repository})
    : _repository = repository,
      super(const DiaryHistoryState());

  final DiaryRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(status: DiaryHistoryStatus.loading));
    try {
      final activities = await _repository.fetchActivities();
      emit(
        DiaryHistoryState(
          status: DiaryHistoryStatus.loaded,
          activities: activities,
        ),
      );
    } catch (_) {
      emit(state.copyWith(status: DiaryHistoryStatus.error));
    }
  }

  /// Completes a started step from the detail sheet, then reloads the history so
  /// the card flips to its completed (green-check) state. Returns whether the
  /// completion succeeded so the caller can surface an error.
  Future<bool> completeActivity(DiaryActivity activity) async {
    final stepId = activity.stepId;
    if (stepId == null) return false;
    try {
      await _repository.completeActivity(stepId: stepId, area: activity.area);
      await load();
      return true;
    } catch (_) {
      return false;
    }
  }
}
