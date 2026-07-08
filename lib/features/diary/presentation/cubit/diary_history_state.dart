part of 'diary_history_cubit.dart';

enum DiaryHistoryStatus { initial, loading, loaded, error }

class DiaryHistoryState extends Equatable {
  const DiaryHistoryState({
    this.status = DiaryHistoryStatus.initial,
    this.activities = const [],
  });

  final DiaryHistoryStatus status;
  final List<DiaryActivity> activities;

  DiaryHistoryState copyWith({
    DiaryHistoryStatus? status,
    List<DiaryActivity>? activities,
  }) {
    return DiaryHistoryState(
      status: status ?? this.status,
      activities: activities ?? this.activities,
    );
  }

  @override
  List<Object?> get props => [status, activities];
}
