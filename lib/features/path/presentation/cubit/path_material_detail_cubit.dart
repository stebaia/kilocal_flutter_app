import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/network/api_exception.dart';
import '../../domain/entities/path_material.dart';
import '../../domain/path_materials_repository.dart';

part 'path_material_detail_state.dart';

class PathMaterialDetailCubit extends Cubit<PathMaterialDetailState> {
  PathMaterialDetailCubit({
    required PathMaterialsRepository materialsRepository,
  }) : _materialsRepository = materialsRepository,
       super(const PathMaterialDetailState());

  final PathMaterialsRepository _materialsRepository;

  Future<void> load({required String id}) async {
    emit(state.copyWith(status: PathMaterialDetailStatus.loading, error: null));

    try {
      final detail = await _materialsRepository.fetchMaterialDetail(id: id);
      emit(
        state.copyWith(status: PathMaterialDetailStatus.loaded, data: detail),
      );
    } on ApiException catch (e) {
      emit(state.copyWith(status: PathMaterialDetailStatus.error, error: e));
    }
  }
}
