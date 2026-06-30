part of 'path_material_detail_cubit.dart';

enum PathMaterialDetailStatus { initial, loading, loaded, error }

class PathMaterialDetailState extends Equatable {
  const PathMaterialDetailState({
    this.status = PathMaterialDetailStatus.initial,
    this.data,
    this.error,
  });

  final PathMaterialDetailStatus status;
  final PathMaterialDetail? data;
  final ApiException? error;

  PathMaterialDetailState copyWith({
    PathMaterialDetailStatus? status,
    PathMaterialDetail? data,
    ApiException? error,
  }) {
    return PathMaterialDetailState(
      status: status ?? this.status,
      data: data ?? this.data,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, data, error];
}
