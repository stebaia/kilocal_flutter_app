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
}
