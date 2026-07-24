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
    } on ApiException catch (e) {
      emit(state.copyWith(status: PathMaterialDetailStatus.error, error: e));
    }
  }

  /// Marks the material completed via the explicit "Segna come completato"
  /// CTA — completion is no longer implicit on open, so this is the only way
  /// a material moves from "Da vedere" to "Visti".
  Future<void> markCompleted() async {
    final detail = state.data;
    final userId = _userCubit.myId;
    if (detail == null || userId == null || detail.isCompleted) return;

    try {
      await _materialsRepository.markMaterialCompleted(
        materialId: detail.id,
        userId: userId,
      );
      emit(state.copyWith(data: detail.copyWith(isCompleted: true)));
    } on ApiException catch (e) {
      emit(state.copyWith(error: e));
    }
  }
}
