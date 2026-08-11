import 'package:dio/dio.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/graphql_client.dart';
import '../../../l10n/app_localizations.dart';
import '../../integrazione/domain/entities/integrazione_data.dart';
import '../../integrazione/domain/integrazione_repository.dart';
import '../../path/data/dto/path_area_steps_dto.dart';
import '../../path/data/dto/path_progress_dto.dart';
import '../domain/entities/area_stat.dart';
import '../domain/statistics_repository.dart';

/// Dio/GraphQL-backed implementation of [StatisticsRepository].
///
/// Lifetime stats reuse the already-computed progress from
/// `GET /path/me/progress` — the same endpoint (and DTO) that powers the path
/// screen. The month filter cannot use that endpoint (it is lifetime-only and
/// accepts no timeframe parameter — backend-confirmed), so per-month stats are
/// recomputed from GraphQL exactly like the web app does: completed
/// `user_activities` plus `percorsi_content` filtered on `timeframe.sort`
/// (same pattern as `HomeRepositoryImpl._fetchMonthProgress`).
///
/// `benessere` is filtered out on purpose (product decision); it is still
/// returned by the backend but not surfaced here.
///
/// `integrazione` has no `percorsi_content` (it is phase-based, backed by
/// `kit_products` + `user_integratori`), so it is resolved separately: under a
/// month filter it maps month N to the kit phase with `sort == N` and reports
/// that phase's own intake progress — `0/0` while the phase is still locked,
/// which is what the user expects for a month they have not unlocked yet.
class StatisticsRepositoryImpl implements StatisticsRepository {
  const StatisticsRepositoryImpl({
    required Dio dio,
    required GraphqlClient graphqlClient,
    required IntegrazioneRepository integrazioneRepository,
  }) : _dio = dio,
       _graphqlClient = graphqlClient,
       _integrazioneRepository = integrazioneRepository;

  final Dio _dio;
  final GraphqlClient _graphqlClient;
  final IntegrazioneRepository _integrazioneRepository;

  /// Area key of the phase-based supplements area.
  static const _integrazioneArea = 'integrazione';

  // The CMS uses codes like "it-IT"; matches `IntegrazioneCubit._lang`.
  static const _lang = 'it-IT';

  /// Area resolved through each content's main-tab group, matching what
  /// `/path/me/progress` counts (`is_percorso_main_tab`), so a content reused
  /// in a materials group is not double-counted.
  static const _monthCompletedQuery = r'''
query StatisticsMonthCompleted {
  user_activities(filter: { completed_on: { _nnull: true } }, limit: -1) {
    activity {
      item {
        ... on percorsi_content {
          id
          timeframe { sort }
          used_in {
            percorsi_groups_id {
              is_percorso_main_tab
              percorso { root { internal_name } }
            }
          }
        }
      }
    }
  }
}
''';

  /// The month is inlined instead of passed as a variable: Directus types
  /// `_eq` on `timeframe.sort` as `GraphQLStringOrFloat`, which rejects an
  /// `Int!` variable (HTTP 400 GRAPHQL_VALIDATION) — same reason
  /// `HomeRepositoryImpl` interpolates the month into its query template.
  static const _monthTotalsQueryTemplate = r'''
query StatisticsMonthTotals {
  percorsi_content(
    filter: { timeframe: { sort: { _eq: {{month}} } } }
    limit: -1
  ) {
    id
    used_in {
      percorsi_groups_id {
        is_percorso_main_tab
        percorso { root { internal_name } }
      }
    }
  }
}
''';

  @override
  Future<List<AreaStat>> fetchStatistics(
    AppLocalizations l10n, {
    AreaTimeframe? timeframe,
    String? myId,
  }) async {
    try {
      final lifetime = await _fetchLifetimeProgress();
      if (timeframe == null) {
        return _areaMeta(l10n)
            .map((meta) => _mapArea(meta, lifetime.areas[meta.internalName]))
            .toList();
      }

      final monthCounts = await _fetchMonthCounts(timeframe.sort);
      // `integrazione` lives outside `percorsi_content`, so its per-month
      // figures come from the kit phases instead.
      final phaseCount = await _fetchPhaseCounts(
        monthSort: timeframe.sort,
        myId: myId,
      );

      return _areaMeta(l10n).map((meta) {
        final count = meta.internalName == _integrazioneArea
            ? phaseCount
            : monthCounts[meta.internalName];
        if (count == null) {
          return _mapArea(meta, lifetime.areas[meta.internalName]);
        }
        return AreaStat(
          id: meta.internalName,
          area: meta.title,
          assetName: meta.assetName,
          month: meta.timeframeLabel,
          completed: count.completed,
          total: count.total,
        );
      }).toList();
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

  /// Lifetime progress from `GET /path/me/progress`.
  Future<PathProgressDto> _fetchLifetimeProgress() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/path/me/progress',
      // The server caches this endpoint keyed by exact URL; a monotonic
      // throwaway param forces a fresh read after step completions.
      queryParameters: {'_': DateTime.now().millisecondsSinceEpoch},
    );
    return PathProgressResponseDto.fromJson(response.data ?? const {}).data;
  }

  /// Completed/total counts per area (`root.internal_name`) for the month with
  /// [monthSort], recomputed client-side from GraphQL. Only step-based areas
  /// are present in the result — `integrazione` is not monthly.
  Future<Map<String, ({int completed, int total})>> _fetchMonthCounts(
    int monthSort,
  ) async {
    final results = await Future.wait([
      _graphqlClient.query(_monthCompletedQuery),
      _graphqlClient.query(
        _monthTotalsQueryTemplate.replaceAll('{{month}}', monthSort.toString()),
      ),
    ]);

    final completed = <String, int>{};
    final completedBody = results[0]['data'] as Map<String, dynamic>?;
    final activities = completedBody?['user_activities'] as List<dynamic>?;
    for (final activity in activities ?? <dynamic>[]) {
      final items =
          (activity as Map<String, dynamic>)['activity'] as List<dynamic>?;
      for (final wrapper in items ?? <dynamic>[]) {
        final item = (wrapper as Map<String, dynamic>)['item'];
        if (item is! Map<String, dynamic>) continue;
        final timeframe = item['timeframe'] as Map<String, dynamic>?;
        if (timeframe?['sort'] != monthSort) continue;
        final area = _mainTabArea(item);
        if (area == null) continue;
        completed[area] = (completed[area] ?? 0) + 1;
        break;
      }
    }

    final totals = <String, int>{};
    final totalsBody = results[1]['data'] as Map<String, dynamic>?;
    final contents = totalsBody?['percorsi_content'] as List<dynamic>?;
    for (final content in contents ?? <dynamic>[]) {
      final area = _mainTabArea(content as Map<String, dynamic>);
      if (area == null) continue;
      totals[area] = (totals[area] ?? 0) + 1;
    }

    return {
      for (final area in {...completed.keys, ...totals.keys})
        area: (completed: completed[area] ?? 0, total: totals[area] ?? 0),
    };
  }

  /// Intake progress of the supplement phase matching the selected month, or
  /// null when it cannot be resolved (no [myId], no kit, or the request fails)
  /// — the caller then falls back to the lifetime figure.
  ///
  /// Month N maps to the phase with `sort == N`: the supplement plan advances
  /// one phase per path month. A phase the user has not reached yet is locked,
  /// and a locked phase reports `0/0` rather than leaking the lifetime
  /// percentage — that stale value is what made months 2/3 look partly done.
  ///
  /// For an unlocked phase, `total` is the planned intake days of the phase
  /// (sum of each supplement's `durationDays`) and `completed` the days
  /// actually marked as taken, capped per product so an over-logged supplement
  /// cannot push the bar past 100%.
  Future<({int completed, int total})?> _fetchPhaseCounts({
    required int monthSort,
    required String? myId,
  }) async {
    if (myId == null) return null;

    final IntegrazioneData data;
    try {
      data = await _integrazioneRepository.fetchIntegrazione(
        myId: myId,
        lang: _lang,
      );
    } on ApiException {
      // Best-effort: the other areas' stats are still worth showing.
      return null;
    }
    if (data.phases.isEmpty) return null;

    final index = data.phases.indexWhere((phase) => phase.sort == monthSort);
    // A month with no matching phase (e.g. the kit has fewer phases than the
    // path has months) has nothing to report for this area.
    if (index < 0) return (completed: 0, total: 0);

    // Not reached yet → nothing done in that month, by definition.
    if (data.isPhaseLocked(index)) return (completed: 0, total: 0);

    final phase = data.phases[index];
    var completed = 0;
    var total = 0;
    for (final product in phase.products) {
      total += product.durationDays;
      completed += product.takenCount.clamp(0, product.durationDays);
    }
    return (completed: completed, total: total);
  }

  /// The `root.internal_name` of the content's main-tab group, or null when
  /// the content is not linked to any main-tab group (e.g. materials-only).
  String? _mainTabArea(Map<String, dynamic> content) {
    final usedIn = content['used_in'] as List<dynamic>?;
    for (final usage in usedIn ?? <dynamic>[]) {
      final group =
          (usage as Map<String, dynamic>)['percorsi_groups_id']
              as Map<String, dynamic>?;
      if (group == null) continue;
      if (group['is_percorso_main_tab'] != true) continue;
      final percorso = group['percorso'] as Map<String, dynamic>?;
      final root = percorso?['root'] as Map<String, dynamic>?;
      final name = root?['internal_name'] as String?;
      if (name != null) return name;
    }
    return null;
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
