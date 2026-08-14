import 'package:dio/dio.dart';

import '../../../l10n/app_localizations.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/utils/cms_image_url.dart';
import '../domain/entities/path_area_detail.dart';
import '../domain/entities/path_data.dart';
import '../domain/entities/path_material.dart';
import '../domain/path_repository.dart';
import 'dto/path_area_steps_dto.dart';
import 'dto/path_progress_dto.dart';
import 'vimeo_oembed_service.dart';

/// Dio-backed implementation of [PathRepository].
///
/// Reads the already-computed progress from `GET /path/me/progress` and the
/// area detail from `GET /path/me/areas/{area}/steps`. Start/complete actions
/// use `POST /path/steps/{id}/start` and `/complete`.
class PathRepositoryImpl implements PathRepository {
  const PathRepositoryImpl({
    required Dio dio,
    required VimeoOembedService vimeoOembedService,
  }) : _dio = dio,
       _vimeoOembedService = vimeoOembedService;

  final Dio _dio;

  /// Video steps carry no cover file in the CMS (156/157 `percorsi_content`
  /// rows have no image — confirmed by backend, 2026-07), so their card poster
  /// is resolved from Vimeo, exactly as the materials list already does.
  final VimeoOembedService _vimeoOembedService;

  static const _headerAsset = 'assets/path_header_ellipse.svg';

  @override
  Future<PathData> fetchPath(AppLocalizations l10n) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/path/me/progress',
        // The server caches this endpoint keyed by exact URL; a monotonic
        // throwaway param forces a fresh read after step completions.
        queryParameters: {'_': DateTime.now().millisecondsSinceEpoch},
      );
      final dto = PathProgressResponseDto.fromJson(response.data ?? const {});
      return _mapProgressDto(dto.data, l10n);
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  @override
  Future<PathAreaDetail> fetchAreaSteps({
    required String area,
    required AppLocalizations l10n,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/path/me/areas/$area/steps',
      );
      final dto = PathAreaStepsResponseDto.fromJson(response.data ?? const {});
      // Vimeo posters for every video step of the area, resolved in one
      // concurrent pass so the cards render a thumbnail instead of a
      // placeholder. Failures are absent from the map and degrade to no image.
      final posters = await _vimeoOembedService.fetchAll(_videoUrls(dto.data));
      return _mapAreaStepsDto(dto.data, l10n, posters);
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  @override
  Future<void> startStep(String stepId) async {
    try {
      await _dio.post<Map<String, dynamic>>('/path/steps/$stepId/start');
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  @override
  Future<void> completeStep({
    required String stepId,
    required String area,
  }) async {
    try {
      await _dio.post<Map<String, dynamic>>(
        '/path/steps/$stepId/complete',
        data: {'percorsoInternalName': area},
      );
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  PathData _mapProgressDto(PathProgressDto dto, AppLocalizations l10n) {
    return PathData(
      overallCompleted: dto.overall.completed,
      overallTotal: dto.overall.total,
      headerAssetName: _headerAsset,
      areas: _areaMeta(
        l10n,
      ).map((meta) => _mapArea(meta, dto.areas[meta.internalName])).toList(),
    );
  }

  PathArea _mapArea(_AreaMeta meta, AreaProgressDto? progress) {
    return PathArea(
      id: meta.internalName,
      title: meta.title,
      assetName: meta.assetName,
      completed: progress?.completed ?? 0,
      total: progress?.total ?? 0,
    );
  }

  /// Every distinct Vimeo url in the area payload — main-tab steps and content
  /// groups alike, since both render step cards.
  Iterable<String> _videoUrls(PathAreaStepsDto dto) {
    final urls = <String>{};
    for (final group in dto.groups) {
      for (final step in group.steps) {
        final asset = step.asset;
        final url = asset.vimeoUrl;
        if (asset.assetIsVideo && url != null) urls.add(url);
      }
    }
    return urls;
  }

  PathAreaDetail _mapAreaStepsDto(
    PathAreaStepsDto dto,
    AppLocalizations l10n,
    Map<String, VimeoOembed> posters,
  ) {
    // Pick the main tab group; tolerate areas that expose no group at all
    // (200 with an empty `groups`) instead of throwing on `.first`.
    PathGroupDto? mainGroup;
    for (final g in dto.groups) {
      if (g.isPercorsoMainTab) {
        mainGroup = g;
        break;
      }
    }
    mainGroup ??= dto.groups.isNotEmpty ? dto.groups.first : null;

    final stepsByTimeframe = <int, List<PathStepDto>>{};
    for (final step in mainGroup?.steps ?? const <PathStepDto>[]) {
      stepsByTimeframe
          .putIfAbsent(step.timeframe.id, () => <PathStepDto>[])
          .add(step);
    }

    final sortedTimeframeIds = stepsByTimeframe.keys.toList()
      ..sort((a, b) {
        final stepA = stepsByTimeframe[a]!.first;
        final stepB = stepsByTimeframe[b]!.first;
        return stepA.timeframe.sort.compareTo(stepB.timeframe.sort);
      });

    // Authoritative month lock/active flags live in the top-level
    // `timeframes[]` when the backend sends them; otherwise fall back to the
    // flags nested on the step's timeframe object (older shape).
    final timeframeById = {
      for (final tf in dto.timeframes ?? const <PathTimeframeDto>[]) tf.id: tf,
    };

    final timeframeGroups = sortedTimeframeIds.map((timeframeId) {
      final steps = stepsByTimeframe[timeframeId]!
        ..sort((a, b) => a.sort.compareTo(b.sort));
      final nestedTimeframe = steps.first.timeframe;
      final timeframe = timeframeById[timeframeId] ?? nestedTimeframe;
      final timeframeTitle =
          timeframe.translations.titleFor(l10n.localeName) ?? '';
      final total = steps.length;
      final completed = steps.where((s) => s.completed).length;

      return PathTimeframeGroup(
        timeframeId: timeframeId,
        title: timeframeTitle,
        completed: completed,
        total: total,
        isLocked: timeframe.locked ?? false,
        isCurrent: timeframe.isCurrent ?? false,
        steps: steps
            .map((s) => _mapStepDto(s, timeframeTitle, l10n, posters))
            .toList(),
      );
    }).toList();

    PathGroupDto? materialsGroup;
    for (final g in dto.groups) {
      if (!g.isPercorsoMainTab && g.translations.isNotEmpty) {
        materialsGroup = g;
        break;
      }
    }

    // Content groups shown as cards on the Benessere screen (Mindfulness /
    // Self care / Stili di vita). The backend returns these as separate
    // `percorsi_groups` rows — all with `is_percorso_main_tab: false` — so we
    // take every titled group here, each with its own completed/total count and
    // a per-month breakdown (see `_monthsForGroup`).
    final orderedTimeframes =
        (dto.timeframes ?? const <PathTimeframeDto>[]).toList()
          ..sort((a, b) => a.sort.compareTo(b.sort));
    final groups = <PathAreaGroup>[
      for (final g in dto.groups)
        if (g.translations.titleFor(l10n.localeName)?.isNotEmpty ?? false)
          PathAreaGroup(
            id: g.id,
            title: g.translations.titleFor(l10n.localeName) ?? '',
            completed: g.steps.where((s) => s.completed).length,
            total: g.steps.length,
            months: _monthsForGroup(g, orderedTimeframes, l10n, posters),
            categories: _mapGroupCategories(g, l10n),
          ),
    ];

    return PathAreaDetail(
      area: dto.area,
      percorsoInternalName: dto.percorso.internalName,
      completed: dto.progress.completed,
      total: dto.progress.total,
      timeframeGroups: timeframeGroups,
      groups: groups,
      hasMaterials: materialsGroup != null,
      materialsGroupId: materialsGroup?.id,
      isLocked: dto.access?.percorsoLocked ?? false,
      isRestricted: dto.access?.restricted ?? false,
    );
  }

  /// Builds the per-month breakdown for a content group: one row per area
  /// timeframe, in order. A month with no steps in this group comes through
  /// with a 0/0 count and — unless the backend already marks it unlocked —
  /// locked, so the group detail always shows every month even when empty.
  List<PathTimeframeGroup> _monthsForGroup(
    PathGroupDto group,
    List<PathTimeframeDto> orderedTimeframes,
    AppLocalizations l10n,
    Map<String, VimeoOembed> posters,
  ) {
    final stepsByTimeframe = <int, List<PathStepDto>>{};
    for (final step in group.steps) {
      stepsByTimeframe
          .putIfAbsent(step.timeframe.id, () => <PathStepDto>[])
          .add(step);
    }

    return orderedTimeframes.map((tf) {
      final steps = [...?stepsByTimeframe[tf.id]]
        ..sort((a, b) => a.sort.compareTo(b.sort));
      final title = tf.translations.titleFor(l10n.localeName) ?? '';
      final total = steps.length;
      final completed = steps.where((s) => s.completed).length;
      return PathTimeframeGroup(
        timeframeId: tf.id,
        title: title,
        completed: completed,
        total: total,
        // A month is locked when the backend marks it locked or when this group
        // has no steps in it yet — so every month is always listed, empty ones
        // showing as locked 0/0 rather than disappearing.
        isLocked: (tf.locked ?? false) || total == 0,
        isCurrent: tf.isCurrent ?? false,
        steps: [for (final s in steps) _mapStepDto(s, title, l10n, posters)],
      );
    }).toList();
  }

  /// Maps a group's official material categories (`group.categories`), the
  /// authoritative source for the materials hub's tabs. Skips entries with no
  /// localized title (matches how groups/steps are already filtered above).
  List<PathMaterialCategory> _mapGroupCategories(
    PathGroupDto group,
    AppLocalizations l10n,
  ) {
    final categories = <PathMaterialCategory>[];
    for (final junction
        in group.categories ?? const <PathGroupCategoryJunctionDto>[]) {
      final category = junction.category;
      if (category == null) continue;
      final title = category.translations.titleFor(l10n.localeName);
      if (title == null || title.isEmpty) continue;
      categories.add(PathMaterialCategory(id: category.id, title: title));
    }
    return categories;
  }

  PathStepItem _mapStepDto(
    PathStepDto dto,
    String timeframeTitle,
    AppLocalizations l10n,
    Map<String, VimeoOembed> posters,
  ) {
    final title = dto.translations.titleFor(l10n.localeName) ?? '';
    final description = dto.translations.descriptionFor(l10n.localeName);
    final asset = dto.asset;

    final imageId = asset.mobileAsset ?? asset.defaultAsset;
    final stepImageUrl = cmsImageUrl(imageId, size: CmsImageSize.hero);

    final PathStepMedia media;
    if (asset.assetIsVideo && asset.vimeoUrl != null) {
      // Prefer a CMS cover when one exists; otherwise use the Vimeo poster, so
      // the card is never a bare placeholder just because the step is a video.
      media = PathStepMedia(
        isVideo: true,
        vimeoUrl: asset.vimeoUrl,
        imageUrl: stepImageUrl ?? posters[asset.vimeoUrl]?.thumbnailUrl,
      );
    } else {
      media = PathStepMedia(isVideo: false, imageUrl: stepImageUrl);
    }

    return PathStepItem(
      id: dto.id,
      title: title,
      timeframeTitle: timeframeTitle,
      asset: media,
      isCompleted: dto.completed,
      isStarted: dto.started,
      isCurrent: dto.isCurrent,
      isLocked: dto.locked,
      description: description,
    );
  }

  /// Client-side metadata for the four fixed areas, in display order. The key
  /// (`internalName`) must match `root.internal_name` returned by the backend.
  static List<_AreaMeta> _areaMeta(AppLocalizations l10n) => [
    _AreaMeta(
      internalName: 'allenamento',
      title: l10n.areaTraining,
      assetName: 'assets/training.png',
    ),
    _AreaMeta(
      internalName: 'alimentazione',
      title: l10n.areaNutrition,
      assetName: 'assets/alimentation.png',
    ),
    _AreaMeta(
      internalName: 'benessere',
      title: l10n.areaWellbeing,
      assetName: 'assets/wellness.png',
    ),
    _AreaMeta(
      internalName: 'integrazione',
      title: l10n.areaIntegration,
      assetName: 'assets/name_logo.png',
    ),
  ];
}

class _AreaMeta {
  const _AreaMeta({
    required this.internalName,
    required this.title,
    required this.assetName,
  });

  final String internalName;
  final String title;
  final String assetName;
}
