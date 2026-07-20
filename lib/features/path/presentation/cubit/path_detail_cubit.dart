import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/monitoring/analytics_events.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/path_area_detail.dart';
import '../../domain/path_materials_repository.dart';
import '../../domain/path_repository.dart';

part 'path_detail_state.dart';

/// Cubit that loads and exposes the detail of a single path area.
class PathDetailCubit extends Cubit<PathDetailState> {
  PathDetailCubit({
    required PathRepository pathRepository,
    required PathMaterialsRepository materialsRepository,
    required AnalyticsEvents analytics,
  }) : _pathRepository = pathRepository,
       _materialsRepository = materialsRepository,
       _analytics = analytics,
       super(const PathDetailState());

  final PathRepository _pathRepository;
  final PathMaterialsRepository _materialsRepository;
  final AnalyticsEvents _analytics;

  Future<void> load({
    required String area,
    required AppLocalizations l10n,
  }) async {
    emit(state.copyWith(status: PathDetailStatus.loading, error: null));

    try {
      final data = await _pathRepository.fetchAreaSteps(area: area, l10n: l10n);
      final enriched = await _withGroupProgress(data);
      emit(state.copyWith(status: PathDetailStatus.loaded, data: enriched));
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

  /// Fills in the completed/total badge for the area's content groups (the
  /// Benessere sub-sections). Their materials — and thus counts — live in
  /// GraphQL, not in the REST `/steps` payload where `steps` is empty, so the
  /// REST-derived groups always come through as 0/0. We recompute them here.
  ///
  /// Best-effort: if the count query fails we keep the original groups rather
  /// than failing the whole screen.
  Future<PathAreaDetail> _withGroupProgress(PathAreaDetail data) async {
    if (data.groups.isEmpty) return data;
    try {
      final progress = await _materialsRepository.fetchGroupProgress(
        groupIds: data.groups.map((g) => g.id).toList(),
      );
      if (progress.isEmpty) return data;
      return data.copyWith(
        groups: [
          for (final group in data.groups)
            if (progress[group.id] case final p?)
              group.copyWith(completed: p.completed, total: p.total)
            else
              group,
        ],
      );
    } on ApiException {
      return data;
    }
  }

  Future<void> startStep({
    required String stepId,
    required String area,
    required AppLocalizations l10n,
  }) async {
    // Registering the "started" activity is best-effort: a failed POST must not
    // block the user from reading the step, so we always fall through to load.
    try {
      await _pathRepository.startStep(stepId);
      await _analytics.pathStepOpened(pathId: area, stepId: stepId);
    } on ApiException {
      // Swallow: the area still loads below and the read stays usable.
    }
    await load(area: area, l10n: l10n);
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
