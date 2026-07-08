import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../user/presentation/cubit/user_cubit.dart';
import '../../domain/entities/path_data.dart';
import '../../domain/path_repository.dart';

part 'path_state.dart';

/// Cubit that loads and exposes the data for the path screen.
class PathCubit extends Cubit<PathState> {
  PathCubit({required PathRepository pathRepository, required UserCubit userCubit})
    : _pathRepository = pathRepository,
      _userCubit = userCubit,
      super(const PathState());

  final PathRepository _pathRepository;
  final UserCubit _userCubit;

  /// Path areas gated for restricted users. `integrazione` is product-based and
  /// never restricted (it comes through with its own 0/N figure), so only the
  /// three progressive areas are locked. See [[restricted-access-path-gating]].
  static const _restrictedAreas = {'allenamento', 'alimentazione', 'benessere'};

  Future<void> load(AppLocalizations l10n) async {
    emit(state.copyWith(status: PathStatus.loading, error: null));

    try {
      final data = await _pathRepository.fetchPath(l10n);
      emit(
        state.copyWith(
          status: PathStatus.loaded,
          data: _applyRestriction(data),
          error: null,
        ),
      );
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

  /// Marks the progressive path areas as restricted when the current user has
  /// `profile_status = active_restricted_access`. The progress endpoint carries
  /// no per-area restriction flag, so we derive it from the cached profile
  /// status; the area detail then confirms it via `access.restricted`.
  PathData _applyRestriction(PathData data) {
    if (!_userCubit.state.isToolBlocked) return data;
    return PathData(
      overallCompleted: data.overallCompleted,
      overallTotal: data.overallTotal,
      headerAssetName: data.headerAssetName,
      areas: [
        for (final area in data.areas)
          area.copyWith(isRestricted: _restrictedAreas.contains(area.id)),
      ],
    );
  }
}
