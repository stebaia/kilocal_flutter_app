import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/path_data.dart';
import '../../domain/path_repository.dart';

part 'path_state.dart';

/// Cubit that loads and exposes the data for the path screen.
class PathCubit extends Cubit<PathState> {
  PathCubit({required PathRepository pathRepository})
    : _pathRepository = pathRepository,
      super(const PathState());

  final PathRepository _pathRepository;

  Future<void> load(AppLocalizations l10n) async {
    emit(state.copyWith(status: PathStatus.loading, error: null));

    try {
      final data = await _pathRepository.fetchPath(l10n);
      emit(state.copyWith(status: PathStatus.loaded, data: data, error: null));
    } on ApiException catch (e) {
      emit(state.copyWith(status: PathStatus.error, error: e));
    } catch (_) {
      emit(
        state.copyWith(
          status: PathStatus.error,
          error: const ApiException(
            type: ApiErrorType.unknown,
            statusCode: 200,
            message: 'Unknown path error',
          ),
        ),
      );
    }
  }
}
