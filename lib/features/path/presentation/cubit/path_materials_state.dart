part of 'path_materials_cubit.dart';

enum PathMaterialsStatus { initial, loading, loaded, error }

/// Watched-status filter applied on top of the category tab selection.
enum PathMaterialFilter { toWatch, watched }

class PathMaterialsState extends Equatable {
  const PathMaterialsState({
    this.status = PathMaterialsStatus.initial,
    this.data,
    this.selectedCategoryId,
    this.filter = PathMaterialFilter.toWatch,
    this.error,
  });

  final PathMaterialsStatus status;
  final PathMaterialsData? data;

  /// Currently-selected category tab; `null` when there are no categories.
  final String? selectedCategoryId;

  /// Active watched-status filter (from the filter bottom sheet).
  final PathMaterialFilter filter;
  final ApiException? error;

  /// Materials belonging to the selected category and matching the active
  /// watched-status filter. When no category is selected, all categories are
  /// included. Unpublished materials (`isAvailable == false`) never show up:
  /// there is no filter to reveal them, so they're excluded outright.
  List<PathMaterial> get visibleMaterials {
    final all = data?.materials ?? const [];
    final categoryId = selectedCategoryId;
    return all
        .where((m) {
          final inCategory =
              categoryId == null || m.categoryIds.contains(categoryId);
          return inCategory && m.isAvailable && _matchesFilter(m);
        })
        .toList(growable: false);
  }

  bool _matchesFilter(PathMaterial material) {
    switch (filter) {
      case PathMaterialFilter.toWatch:
        return !material.isCompleted;
      case PathMaterialFilter.watched:
        return material.isCompleted;
    }
  }

  PathMaterialsState copyWith({
    PathMaterialsStatus? status,
    PathMaterialsData? data,
    String? selectedCategoryId,
    PathMaterialFilter? filter,
    ApiException? error,
  }) {
    return PathMaterialsState(
      status: status ?? this.status,
      data: data ?? this.data,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      filter: filter ?? this.filter,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, data, selectedCategoryId, filter, error];
}
