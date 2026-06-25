part of 'path_detail_cubit.dart';

enum PathDetailStatus { initial, loading, loaded, error }

class PathDetailState extends Equatable {
  const PathDetailState({
    this.status = PathDetailStatus.initial,
    this.data,
    this.error,
  });

  final PathDetailStatus status;
  final PathAreaDetail? data;
  final ApiException? error;

  PathDetailState copyWith({
    PathDetailStatus? status,
    PathAreaDetail? data,
    ApiException? error,
  }) {
    return PathDetailState(
      status: status ?? this.status,
      data: data ?? this.data,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, data, error];
}
