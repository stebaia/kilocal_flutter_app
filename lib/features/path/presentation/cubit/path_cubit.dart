import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../user/presentation/cubit/user_cubit.dart';
import '../../domain/entities/path_data.dart';
import '../../domain/path_materials_repository.dart';
import '../../domain/path_repository.dart';

part 'path_state.dart';

/// Cubit that loads and exposes the data for the path screen.
class PathCubit extends Cubit<PathState> {
  PathCubit({
    required PathRepository pathRepository,
    required PathMaterialsRepository materialsRepository,
    required UserCubit userCubit,
  }) : _pathRepository = pathRepository,
       _materialsRepository = materialsRepository,
       _userCubit = userCubit,
       super(const PathState());

  final PathRepository _pathRepository;
  final PathMaterialsRepository _materialsRepository;
  final UserCubit _userCubit;

  /// Area whose card total is computed from materials, not steps (see
  /// [_withBenessereProgress]).
  static const _benessereArea = 'benessere';

  /// Path areas gated for restricted users. `integrazione` is product-based and
  /// never restricted (it comes through with its own 0/N figure), so only the
  /// three progressive areas are locked. See [[restricted-access-path-gating]].
  static const _restrictedAreas = {'allenamento', 'alimentazione', 'benessere'};

  Future<void> load(AppLocalizations l10n) async {
    emit(state.copyWith(status: PathStatus.loading, error: null));

    try {
      final data = await _pathRepository.fetchPath(l10n);
      final enriched = await _withBenessereProgress(data, l10n);
      emit(
        state.copyWith(
          status: PathStatus.loaded,
          data: _applyRestriction(enriched),
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

  /// Fills in the Benessere card's completed/total, which `/path/me/progress`
  /// reports as 0/0 because that area has no steps — its content is materials.
  /// We fetch the area's group ids from `/steps`, count their materials and the
  /// user's completed ones (via [PathMaterialsRepository.fetchGroupProgress]),
  /// and sum them into the card figure — the same numbers the detail cards show.
  ///
  /// Best-effort: on any API error the original (0/0) card is kept rather than
  /// failing the whole path screen. Skipped when the area is restricted/locked,
  /// since the user cannot see its content yet.
  Future<PathData> _withBenessereProgress(
    PathData data,
    AppLocalizations l10n,
  ) async {
    final index = data.areas.indexWhere((a) => a.id == _benessereArea);
    if (index < 0) return data;

    try {
      final detail = await _pathRepository.fetchAreaSteps(
        area: _benessereArea,
        l10n: l10n,
      );
      if (detail.isLocked || detail.isRestricted || detail.groups.isEmpty) {
        return data;
      }

      final progress = await _materialsRepository.fetchGroupProgress(
        groupIds: detail.groups.map((g) => g.id).toList(),
      );
      if (progress.isEmpty) return data;

      var completed = 0;
      var total = 0;
      for (final p in progress.values) {
        completed += p.completed;
        total += p.total;
      }

      final areas = [...data.areas];
      areas[index] = areas[index].copyWith(completed: completed, total: total);
      return data.copyWith(areas: areas);
    } on ApiException {
      return data;
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
