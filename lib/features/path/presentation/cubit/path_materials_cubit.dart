import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/network/api_exception.dart';
import '../../domain/entities/path_material.dart';
import '../../domain/path_materials_repository.dart';

part 'path_materials_state.dart';

class PathMaterialsCubit extends Cubit<PathMaterialsState> {
  PathMaterialsCubit({required PathMaterialsRepository materialsRepository})
    : _materialsRepository = materialsRepository,
      super(const PathMaterialsState());

  final PathMaterialsRepository _materialsRepository;

  /// Loads the group's materials.
  ///
  /// [officialCategories], when the caller has them, are the group's preferred
  /// category order — the list the backend exposes on the group itself (see
  /// [PathMaterialsRouteArgs]). Material-derived categories are appended when
  /// missing from that official list: this keeps the backend-confirmed tab order
  /// while still surfacing CMS materials tagged with a category the group list
  /// has not been updated with yet (e.g. Benessere / Stili di vita PDFs under
  /// `schede`). The default tab must still be picked from this merged list:
  /// deriving it only from the materials order used to land the user on the
  /// *second* visible tab ("Consigli utili" instead of "Scopri").
  ///
  /// [area] is the clean area key from the route; the materials endpoint is
  /// scoped by area as well as by group. Without it the repository falls back
  /// to the GraphQL collection — see [PathMaterialsRepository.fetchMaterials].
  ///
  /// An already-selected category survives a reload, so coming back from a
  /// material detail (which reloads to refresh completion state) keeps the user
  /// on the tab they were browsing instead of snapping back to the first one.
  Future<void> load({
    required String groupId,
    String? area,
    List<PathMaterialCategory>? officialCategories,
  }) async {
    emit(state.copyWith(status: PathMaterialsStatus.loading, error: null));

    try {
      final fetchedData = await _materialsRepository.fetchMaterials(
        groupId: groupId,
        area: area,
      );
      final categories = _mergeCategories(
        officialCategories,
        fetchedData.categories,
      );
      final data = PathMaterialsData(
        categories: categories,
        materials: fetchedData.materials,
      );
      final previous = state.selectedCategoryId;
      final keepsPrevious =
          previous != null && categories.any((c) => c.id == previous);

      emit(
        state.copyWith(
          status: PathMaterialsStatus.loaded,
          data: data,
          selectedCategoryId: keepsPrevious
              ? previous
              : (categories.isNotEmpty ? categories.first.id : null),
          // A group with no categories at all must clear a stale selection,
          // which `copyWith`'s `??` fallback cannot express.
          clearSelectedCategory: !keepsPrevious && categories.isEmpty,
        ),
      );
    } on ApiException catch (e) {
      emit(state.copyWith(status: PathMaterialsStatus.error, error: e));
    }
  }

  List<PathMaterialCategory> _mergeCategories(
    List<PathMaterialCategory>? officialCategories,
    List<PathMaterialCategory> derivedCategories,
  ) {
    if (officialCategories == null) return derivedCategories;

    final merged = [...officialCategories];
    final seen = officialCategories.map((c) => c.id).toSet();
    for (final category in derivedCategories) {
      if (seen.add(category.id)) merged.add(category);
    }
    return merged;
  }

  /// Switches the active category tab.
  void selectCategory(String categoryId) {
    emit(state.copyWith(selectedCategoryId: categoryId));
  }

  /// Applies the availability filter from the filter bottom sheet.
  void setFilter(PathMaterialFilter filter) {
    emit(state.copyWith(filter: filter));
  }
}
