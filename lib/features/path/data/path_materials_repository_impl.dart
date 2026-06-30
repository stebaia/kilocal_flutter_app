import 'package:dio/dio.dart';

import '../../../core/config/env.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/graphql_client.dart';
import '../domain/entities/path_material.dart';
import '../domain/path_materials_repository.dart';
import 'dto/path_material_dto.dart';

/// GraphQL-backed implementation of [PathMaterialsRepository].
///
/// The "Materiali" group exposes no steps; its materials live in the separate
/// `percorsi_materials` collection, reachable from the group via the
/// `percorsi_groups_percorsi_materials` junction. We query the junction filtered
/// by the group id and map the nested materials. Category tabs are derived from
/// the categories present on the returned materials, de-duplicated by id.
class PathMaterialsRepositoryImpl implements PathMaterialsRepository {
  PathMaterialsRepositoryImpl({required GraphqlClient graphqlClient})
    : _graphqlClient = graphqlClient;

  final GraphqlClient _graphqlClient;

  static const _query = r'''
query GetGroupMaterials($groupId: GraphQLStringOrFloat!, $lang: String!) {
  percorsi_groups_percorsi_materials(
    filter: { percorsi_groups_id: { id: { _eq: $groupId } } }
  ) {
    percorsi_materials_id {
      id
      status
      connect_to_article
      asset {
        asset_is_video
        default_asset { id filename_download }
        mobile_asset { id filename_download }
      }
      translations(filter: { languages_code: { code: { _eq: $lang } } }) {
        title
      }
      categories {
        percorsi_material_categories_id {
          id
          internal_name
          translations(filter: { languages_code: { code: { _eq: $lang } } }) {
            title
          }
        }
      }
    }
  }
}
''';

  static const _detailQuery = r'''
query GetMaterial($id: ID!, $lang: String!) {
  percorsi_materials_by_id(id: $id) {
    id
    asset {
      asset_is_video
      vimeo_url
      default_asset { id filename_download }
      mobile_asset { id filename_download }
    }
    translations(filter: { languages_code: { code: { _eq: $lang } } }) {
      title
      content
    }
  }
}
''';

  @override
  Future<PathMaterialsData> fetchMaterials({required String groupId}) async {
    try {
      final lang = _resolveLocale();
      final result = await _graphqlClient.query(
        _query,
        variables: {'groupId': groupId, 'lang': lang},
      );

      final data = result['data'] as Map<String, dynamic>?;
      final rows =
          data?['percorsi_groups_percorsi_materials'] as List<dynamic>? ??
          const [];

      final materials = <PathMaterial>[];
      // Preserve first-seen order of categories across all materials so the tab
      // order is stable.
      final categories = <String, PathMaterialCategory>{};

      for (final row in rows) {
        final junction = PathMaterialJunctionDto.fromJson(
          row as Map<String, dynamic>,
        );
        final dto = junction.material;
        if (dto == null) continue;

        final categoryIds = <String>[];
        for (final cj in dto.categories) {
          final cat = cj.category;
          if (cat == null) continue;
          categoryIds.add(cat.id);
          categories.putIfAbsent(
            cat.id,
            () => PathMaterialCategory(
              id: cat.id,
              title: cat.translations.firstOrNull?.title ?? '',
            ),
          );
        }

        materials.add(_mapMaterial(dto, categoryIds));
      }

      return PathMaterialsData(
        categories: categories.values.toList(),
        materials: materials,
      );
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  @override
  Future<PathMaterialDetail?> fetchMaterialDetail({required String id}) async {
    try {
      final lang = _resolveLocale();
      final result = await _graphqlClient.query(
        _detailQuery,
        variables: {'id': id, 'lang': lang},
      );

      final data = result['data'] as Map<String, dynamic>?;
      final raw = data?['percorsi_materials_by_id'] as Map<String, dynamic>?;
      if (raw == null) return null;

      final dto = PathMaterialDto.fromJson(raw);
      final asset = dto.asset;
      final file = asset?.defaultAsset ?? asset?.mobileAsset;
      final translation = dto.translations.firstOrNull;

      return PathMaterialDetail(
        id: dto.id,
        title: translation?.title ?? '',
        isVideo: asset?.assetIsVideo ?? false,
        content: translation?.content,
        imageUrl: _assetUrl(file),
        vimeoUrl: asset?.vimeoUrl,
      );
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  PathMaterial _mapMaterial(PathMaterialDto dto, List<String> categoryIds) {
    final asset = dto.asset;
    final file = asset?.mobileAsset ?? asset?.defaultAsset;

    return PathMaterial(
      id: dto.id,
      title: dto.translations.firstOrNull?.title ?? '',
      isVideo: asset?.assetIsVideo ?? false,
      isAvailable: dto.status == 'published',
      categoryIds: categoryIds,
      imageUrl: _assetUrl(file),
    );
  }

  String? _assetUrl(PathMaterialFileDto? file) {
    if (file?.id == null) return null;
    return '${Env.baseUrl}/assets/${file!.id}/${file.filenameDownload ?? ''}';
  }

  String _resolveLocale() {
    // The CMS uses codes like "it-IT" / "en-US". Default to Italian for now,
    // matching the rest of the GraphQL repositories.
    return 'it-IT';
  }
}
