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
  /// [officialCategories], when the caller has them, are the group's authoritative
  /// categories — the very list the tab strip renders (see
  /// [PathMaterialsRouteArgs]). The default tab must be picked from that same
  /// list: the repository derives its own categories in first-seen-across-the-
  /// materials order, which does not match the official order, so defaulting to
  /// the derived first category used to land the user on the *second* visible tab
  /// ("Consigli utili" instead of "Scopri").
  ///
  /// An already-selected category survives a reload, so coming back from a
  /// material detail (which reloads to refresh completion state) keeps the user
  /// on the tab they were browsing instead of snapping back to the first one.
  Future<void> load({
    required String groupId,
    List<PathMaterialCategory>? officialCategories,
  }) async {
    emit(state.copyWith(status: PathMaterialsStatus.loading, error: null));

    try {
      final data = await _materialsRepository.fetchMaterials(groupId: groupId);
      final categories = officialCategories ?? data.categories;
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

  /// Switches the active category tab.
  void selectCategory(String categoryId) {
    emit(state.copyWith(selectedCategoryId: categoryId));
  }

  /// Applies the availability filter from the filter bottom sheet.
  void setFilter(PathMaterialFilter filter) {
    emit(state.copyWith(filter: filter));
  }
}
