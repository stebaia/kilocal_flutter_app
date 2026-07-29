part of 'path_materials_cubit.dart';

enum PathMaterialsStatus { initial, loading, loaded, error }

/// Watched-status filter applied on top of the category tab selection.
///
/// [all] is the default: both statuses show, grouped into a "da
/// completare/leggere" section followed by a "completata/letta" one (see
/// [PathMaterialsState.visibleMaterials]), so completed items sink to the
/// bottom instead of disappearing.
enum PathMaterialFilter { all, toWatch, watched }

class PathMaterialsState extends Equatable {
  const PathMaterialsState({
    this.status = PathMaterialsStatus.initial,
    this.data,
    this.selectedCategoryId,
    this.filter = PathMaterialFilter.all,
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
  /// watched-status filter, sorted with not-yet-completed materials first.
  /// When no category is selected, all categories are included. Unpublished
  /// materials (`isAvailable == false`) never show up: there is no filter to
  /// reveal them, so they're excluded outright.
  ///
  /// Under [PathMaterialFilter.all], both statuses are included, but the
  /// completed-first ordering above is what actually gives the two visual
  /// sections in the list (see `_MaterialsList`), completed items always
  /// sinking to the bottom.
  List<PathMaterial> get visibleMaterials {
    final all = data?.materials ?? const [];
    final categoryId = selectedCategoryId;
    final filtered = all
        .where((m) {
          final inCategory =
              categoryId == null || m.categoryIds.contains(categoryId);
          return inCategory && m.isAvailable && _matchesFilter(m);
        })
        .toList(growable: false);
    // Stable partition (not List.sort, which isn't guaranteed stable) so
    // materials keep their relative order within each status group.
    final toWatch = filtered.where((m) => !m.isCompleted);
    final watched = filtered.where((m) => m.isCompleted);
    return [...toWatch, ...watched];
  }

  bool _matchesFilter(PathMaterial material) {
    switch (filter) {
      case PathMaterialFilter.all:
        return true;
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
