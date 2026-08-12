import 'package:dio/dio.dart';

import '../../../core/network/api_exception.dart';
import '../../../l10n/app_localizations.dart';
import '../../path/data/dto/path_area_steps_dto.dart';
import '../../path/data/dto/path_progress_dto.dart';
import '../domain/entities/area_stat.dart';
import '../domain/statistics_repository.dart';

/// Dio-backed implementation of [StatisticsRepository].
///
/// Every figure comes from `GET /path/me/progress` — the same endpoint (and
/// DTO) that powers the path screen — with the month filter passed through as
/// `timeframe_id`. Nothing is recomputed client-side: the backend is the single
/// source of truth for both the lifetime and the per-month view, including
/// `integrazione` (reported in content steps, like every other area).
///
/// `benessere` is filtered out on purpose (product decision); it is still
/// returned by the backend but not surfaced here.
class StatisticsRepositoryImpl implements StatisticsRepository {
  const StatisticsRepositoryImpl({required Dio dio}) : _dio = dio;

  final Dio _dio;

  @override
  Future<List<AreaStat>> fetchStatistics(
    AppLocalizations l10n, {
    AreaTimeframe? timeframe,
  }) async {
    try {
      final progress = await _fetchProgress(timeframeId: timeframe?.id);
      return _areaMeta(l10n)
          .map((meta) => _mapArea(meta, progress.areas[meta.internalName]))
          .toList();
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  @override
  Future<List<AreaTimeframe>> fetchAreaTimeframes({
    required String area,
    required AppLocalizations l10n,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/path/me/areas/$area/steps',
      );
      final dto = PathAreaStepsResponseDto.fromJson(response.data ?? const {});
      final timeframes =
          (dto.data.timeframes ?? const <PathTimeframeDto>[]).toList()
            ..sort((a, b) => a.sort.compareTo(b.sort));
      // `timeframes[].is_current` is not always reliable, so the current
      // timeframe is derived from `active_timeframe.sort` (backend-confirmed
      // source of truth) when present, falling back to the flag otherwise.
      final activeSort = dto.data.activeTimeframe?.sort;
      // Every timeframe is selectable in the filter sheet regardless of the
      // path's own lock state — filtering statistics by a future month is
      // harmless (product decision).
      return timeframes
          .map(
            (tf) => AreaTimeframe(
              id: tf.id,
              title: tf.translations.titleFor(l10n.localeName) ?? '',
              sort: tf.sort,
              isCurrent: activeSort != null
                  ? tf.sort == activeSort
                  : tf.isCurrent ?? false,
            ),
          )
          .toList();
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// Progress from `GET /path/me/progress`, lifetime when [timeframeId] is
  /// null and scoped to that month otherwise.
  Future<PathProgressDto> _fetchProgress({required int? timeframeId}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/path/me/progress',
      queryParameters: {
        'timeframe_id': ?timeframeId,
        // The server caches this endpoint keyed by exact URL; a monotonic
        // throwaway param forces a fresh read after step completions.
        '_': DateTime.now().millisecondsSinceEpoch,
      },
    );
    return PathProgressResponseDto.fromJson(response.data ?? const {}).data;
  }

  AreaStat _mapArea(_AreaMeta meta, AreaProgressDto? progress) {
    return AreaStat(
      id: meta.internalName,
      area: meta.title,
      assetName: meta.assetName,
      month: meta.timeframeLabel,
      completed: progress?.completed ?? 0,
      total: progress?.total ?? 0,
    );
  }

  /// Client-side metadata for the areas surfaced on the statistics screen, in
  /// display order. `benessere` is intentionally omitted. The `internalName`
  /// must match `root.internal_name` returned by the backend.
  ///
  /// The `timeframeLabel` ("Mese 1" / "Fase 1") is a placeholder shown in the
  /// lifetime view; under the month filter the screen overrides it with the
  /// selected timeframe title (except `integrazione`, which stays phase-based).
  static List<_AreaMeta> _areaMeta(AppLocalizations l10n) => [
    _AreaMeta(
      internalName: 'allenamento',
      title: l10n.areaTraining,
      assetName: 'assets/icons/stat_training.svg',
      timeframeLabel: l10n.month1,
    ),
    _AreaMeta(
      internalName: 'alimentazione',
      title: l10n.areaNutrition,
      assetName: 'assets/icons/stat_nutrition.svg',
      timeframeLabel: l10n.month1,
    ),
    _AreaMeta(
      internalName: 'integrazione',
      title: l10n.areaIntegration,
      assetName: 'assets/icons/stat_supplement.svg',
      timeframeLabel: l10n.phase1,
    ),
  ];
}

class _AreaMeta {
  const _AreaMeta({
    required this.internalName,
    required this.title,
    required this.assetName,
    required this.timeframeLabel,
  });

  final String internalName;
  final String title;
  final String assetName;
  final String timeframeLabel;
}
