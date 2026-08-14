import 'package:dio/dio.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/graphql_client.dart';
import '../../../core/utils/cms_image_url.dart';
import '../domain/entities/momenti_data.dart';
import '../domain/momenti_repository.dart';
import 'dto/moment_dto.dart';

/// GraphQL-backed implementation of [MomentiRepository].
///
/// Reads the `moments` collection. Each moment exposes structured
/// `title` / `description` translations plus a hero `asset`; the "Meccanica"
/// block shown in the design is rich text inside `description`.
class MomentiRepositoryImpl implements MomentiRepository {
  MomentiRepositoryImpl({required GraphqlClient graphqlClient})
    : _graphqlClient = graphqlClient;

  final GraphqlClient _graphqlClient;

  static const _byIdQuery = r'''
query GetMoment($id: ID!, $lang: String!) {
  moments_by_id(id: $id) {
    id
    translations(filter: { languages_code: { code: { _eq: $lang } } }) {
      title
      description
      plot
    }
    asset {
      default_asset {
        id
        filename_download
      }
    }
  }
}
''';

  static const _currentQuery = r'''
query GetCurrentMoment($now: String!, $lang: String!) {
  moments(
    filter: {
      starts_on: { _lte: $now }
      ends_on: { _gte: $now }
    }
    sort: ["-starts_on", "-ends_on"]
    limit: 1
  ) {
    id
    translations(filter: { languages_code: { code: { _eq: $lang } } }) {
      title
      description
      plot
    }
    asset {
      default_asset {
        id
        filename_download
      }
    }
  }
}
''';

  @override
  Future<MomentiData?> fetchMoment({String? id}) async {
    try {
      final lang = _resolveLocale();
      final Map<String, dynamic>? rawMoment;

      if (id != null) {
        final result = await _graphqlClient.query(
          _byIdQuery,
          variables: {'id': id, 'lang': lang},
        );
        final data = result['data'] as Map<String, dynamic>?;
        rawMoment = data?['moments_by_id'] as Map<String, dynamic>?;
      } else {
        final now = DateTime.now().toUtc().toIso8601String();
        final result = await _graphqlClient.query(
          _currentQuery,
          variables: {'now': now, 'lang': lang},
        );
        final data = result['data'] as Map<String, dynamic>?;
        final moments = data?['moments'] as List<dynamic>?;
        rawMoment = moments?.firstOrNull as Map<String, dynamic>?;
      }

      if (rawMoment == null) return null;

      final dto = MomentDto.fromJson(rawMoment);
      return _mapDto(dto);
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  MomentiData _mapDto(MomentDto dto) {
    final translation = dto.translations.firstOrNull;
    final file = dto.asset?.defaultAsset;
    final plot = translation?.plot?.trim();

    return MomentiData(
      title: translation?.title ?? '',
      description: translation?.description ?? '',
      // Empty-string plots are common in the CMS; treat them as absent so the
      // header drops the info action instead of opening an empty sheet.
      plot: (plot == null || plot.isEmpty) ? null : plot,
      heroImageUrl: _assetUrl(file),
    );
  }

  String? _assetUrl(MomentFileDto? file) => cmsImageUrl(
    file?.id,
    size: CmsImageSize.hero,
    filename: file?.filenameDownload,
  );

  String _resolveLocale() {
    // The CMS uses codes like "it-IT" / "en-US". Default to Italian for now.
    return 'it-IT';
  }
}
