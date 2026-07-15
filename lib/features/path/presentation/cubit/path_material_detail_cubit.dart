import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/network/api_exception.dart';
import '../../../user/presentation/cubit/user_cubit.dart';
import '../../domain/entities/path_material.dart';
import '../../domain/path_materials_repository.dart';

part 'path_material_detail_state.dart';

class PathMaterialDetailCubit extends Cubit<PathMaterialDetailState> {
  PathMaterialDetailCubit({
    required PathMaterialsRepository materialsRepository,
    required UserCubit userCubit,
  }) : _materialsRepository = materialsRepository,
       _userCubit = userCubit,
       super(const PathMaterialDetailState());

  final PathMaterialsRepository _materialsRepository;
  final UserCubit _userCubit;

  Future<void> load({required String id}) async {
    emit(state.copyWith(status: PathMaterialDetailStatus.loading, error: null));

    try {
      final detail = await _materialsRepository.fetchMaterialDetail(id: id);
      emit(
        state.copyWith(status: PathMaterialDetailStatus.loaded, data: detail),
      );
      // Opening a material counts as completing it in the diary. Best-effort:
      // a failed write must not surface as a load error over usable content.
      await _registerCompletion(id);
    } on ApiException catch (e) {
      emit(state.copyWith(status: PathMaterialDetailStatus.error, error: e));
    }
  }

  Future<void> _registerCompletion(String id) async {
    final userId = _userCubit.myId;
    if (userId == null) return;
    try {
      await _materialsRepository.markMaterialCompleted(
        materialId: id,
        userId: userId,
      );
    } on ApiException {
      // Swallow: the material stays readable even if the diary write fails.
    }
  }
}
