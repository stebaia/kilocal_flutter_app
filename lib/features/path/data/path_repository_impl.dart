import 'package:dio/dio.dart';

import '../../../core/config/env.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/network/api_exception.dart';
import '../domain/entities/path_area_detail.dart';
import '../domain/entities/path_data.dart';
import '../domain/path_repository.dart';
import 'dto/path_area_steps_dto.dart';
import 'dto/path_progress_dto.dart';

/// Dio-backed implementation of [PathRepository].
///
/// Reads the already-computed progress from `GET /path/me/progress` and the
/// area detail from `GET /path/me/areas/{area}/steps`. Start/complete actions
/// use `POST /path/steps/{id}/start` and `/complete`.
class PathRepositoryImpl implements PathRepository {
  const PathRepositoryImpl({required Dio dio}) : _dio = dio;

  final Dio _dio;

  static const _headerAsset = 'assets/path_header_ellipse.svg';

  @override
  Future<PathData> fetchPath(AppLocalizations l10n) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/path/me/progress',
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
      return _mapAreaStepsDto(dto.data, l10n);
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

  PathAreaDetail _mapAreaStepsDto(PathAreaStepsDto dto, AppLocalizations l10n) {
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
        steps: steps.map((s) => _mapStepDto(s, timeframeTitle, l10n)).toList(),
      );
    }).toList();

    final hasMaterials = dto.groups.any(
      (g) => !g.isPercorsoMainTab && g.translations.isNotEmpty,
    );

    return PathAreaDetail(
      area: dto.area,
      percorsoInternalName: dto.percorso.internalName,
      completed: dto.progress.completed,
      total: dto.progress.total,
      timeframeGroups: timeframeGroups,
      hasMaterials: hasMaterials,
      isLocked: dto.access?.percorsoLocked ?? false,
    );
  }

  PathStepItem _mapStepDto(
    PathStepDto dto,
    String timeframeTitle,
    AppLocalizations l10n,
  ) {
    final title = dto.translations.titleFor(l10n.localeName) ?? '';
    final description = dto.translations.descriptionFor(l10n.localeName);
    final asset = dto.asset;

    final PathStepMedia media;
    if (asset.assetIsVideo && asset.vimeoUrl != null) {
      media = PathStepMedia(isVideo: true, vimeoUrl: asset.vimeoUrl);
    } else {
      final imageId = asset.mobileAsset ?? asset.defaultAsset;
      media = PathStepMedia(
        isVideo: false,
        imageUrl: imageId != null ? '${Env.baseUrl}/assets/$imageId' : null,
      );
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
