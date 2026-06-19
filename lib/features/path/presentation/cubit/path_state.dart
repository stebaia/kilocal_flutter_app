part of 'path_cubit.dart';

enum PathStatus { initial, loading, loaded, error }

class PathState extends Equatable {
  const PathState({this.status = PathStatus.initial, this.data, this.error});

  final PathStatus status;
  final PathData? data;
  final ApiException? error;

  PathState copyWith({
    PathStatus? status,
    PathData? data,
    ApiException? error,
  }) {
    return PathState(
      status: status ?? this.status,
      data: data ?? this.data,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, data, error];
}
