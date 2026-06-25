import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/path_area_detail.dart';
import '../../domain/path_repository.dart';

part 'path_detail_state.dart';

/// Cubit that loads and exposes the detail of a single path area.
class PathDetailCubit extends Cubit<PathDetailState> {
  PathDetailCubit({required PathRepository pathRepository})
    : _pathRepository = pathRepository,
      super(const PathDetailState());

  final PathRepository _pathRepository;

  Future<void> load({
    required String area,
    required AppLocalizations l10n,
  }) async {
    emit(state.copyWith(status: PathDetailStatus.loading, error: null));

    try {
      final data = await _pathRepository.fetchAreaSteps(area: area, l10n: l10n);
      emit(state.copyWith(status: PathDetailStatus.loaded, data: data));
    } on ApiException catch (e) {
      emit(state.copyWith(status: PathDetailStatus.error, error: e));
    } catch (_) {
      emit(
        state.copyWith(
          status: PathDetailStatus.error,
          error: const ApiException(
            type: ApiErrorType.unknown,
            statusCode: 200,
            message: 'Unknown path detail error',
          ),
        ),
      );
    }
  }

  Future<void> startStep({
    required String stepId,
    required String area,
    required AppLocalizations l10n,
  }) async {
    try {
      await _pathRepository.startStep(stepId);
      await load(area: area, l10n: l10n);
    } on ApiException catch (e) {
      emit(state.copyWith(status: PathDetailStatus.error, error: e));
    }
  }

  Future<void> completeStep({
    required String stepId,
    required String area,
    required AppLocalizations l10n,
  }) async {
    try {
      await _pathRepository.completeStep(stepId: stepId, area: area);
      await load(area: area, l10n: l10n);
    } on ApiException catch (e) {
      emit(state.copyWith(status: PathDetailStatus.error, error: e));
    }
  }
}
