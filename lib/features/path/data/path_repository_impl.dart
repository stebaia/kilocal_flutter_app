import 'package:dio/dio.dart';

import '../../../l10n/app_localizations.dart';
import '../../../core/network/api_exception.dart';
import '../domain/entities/path_data.dart';
import '../domain/path_repository.dart';
import 'dto/path_progress_dto.dart';

/// Dio-backed implementation of [PathRepository].
///
/// Reads the already-computed progress from `GET /path/me/progress`. The numbers
/// (completed/total/percent) come from the backend keyed by the area
/// `internal_name`; the titles, icons and header asset stay client-side because
/// they are part of the static layout, not of the user's progress.
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
      return _mapDto(dto.data, l10n);
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  PathData _mapDto(PathProgressDto dto, AppLocalizations l10n) {
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
