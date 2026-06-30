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

  Future<void> load({required String groupId}) async {
    emit(state.copyWith(status: PathMaterialsStatus.loading, error: null));

    try {
      final data = await _materialsRepository.fetchMaterials(groupId: groupId);
      emit(
        state.copyWith(
          status: PathMaterialsStatus.loaded,
          data: data,
          selectedCategoryId: data.categories.isNotEmpty
              ? data.categories.first.id
              : null,
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
