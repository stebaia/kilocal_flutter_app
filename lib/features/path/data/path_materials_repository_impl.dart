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
  PathMaterialsRepositoryImpl({
    required GraphqlClient graphqlClient,
    required Dio dio,
  }) : _graphqlClient = graphqlClient,
       _dio = dio;

  final GraphqlClient _graphqlClient;

  /// Directus REST is used only for the completion write: `user_activities` has
  /// no dedicated app endpoint and the many-to-any create is awkward over
  /// GraphQL, so we POST the plain JSON body the backend documented.
  final Dio _dio;

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
          hero_asset {
            default_asset { id filename_download }
          }
          translations(filter: { languages_code: { code: { _eq: $lang } } }) {
            title
          }
        }
      }
    }
  }
}
''';

  /// Materials of a group, reduced to their ids — used to size the group badge
  /// (denominator) and to know which materials belong to the group when
  /// intersecting with the user's completed activities.
  static const _groupMaterialIdsQuery = r'''
query GetGroupMaterialIds($groupId: GraphQLStringOrFloat!) {
  percorsi_groups_percorsi_materials(
    filter: { percorsi_groups_id: { id: { _eq: $groupId } } }
  ) {
    percorsi_materials_id { id }
  }
}
''';

  /// The user's completed activities that link a `percorsi_materials` item.
  /// The M2A `activity` is many-to-any, so the material is reached through an
  /// inline fragment. Only `completed_on _nnull` is filtered server-side; the
  /// collection is matched client-side because the nested M2A filter returns
  /// nothing on this Directus instance (same gotcha as the diary history query).
  static const _completedMaterialsQuery = r'''
query GetCompletedMaterials($filter: user_activities_filter) {
  user_activities(filter: $filter) {
    activity {
      collection
      item {
        __typename
        ... on percorsi_materials { id }
      }
    }
  }
}
''';

  static const _completedFilter = <String, dynamic>{
    'completed_on': {'_nnull': true},
  };

  /// Detail of one material. Materials with `connect_to_article` carry no body
  /// of their own: their title/subtitle/body live on the linked `articles` row,
  /// whose text is split across `plot` (intro) and the `blocks` many-to-any.
  /// Only `block_text` is requested — on staging the article blocks of every
  /// linked material are `block_text`, bar a single `block_aside_asset`.
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
    article {
      id
      cover {
        asset_is_video
        vimeo_url
        default_asset { id filename_download }
        mobile_asset { id filename_download }
      }
      translations(filter: { languages_code: { code: { _eq: $lang } } }) {
        title
        subtitle
        plot
      }
      blocks(sort: ["sort"]) {
        collection
        item {
          ... on block_text {
            id
            translations(filter: { languages_code: { code: { _eq: $lang } } }) {
              title
              content
            }
          }
        }
      }
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

      // Materials the user has completed (across all groups), used to flag each
      // card so the "Completati" filter can select them — mirrors the web app,
      // which intersects the material list with the completed-materials list.
      final completedIds = await _fetchCompletedMaterialIds();

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
        // Cover image to fall back to when the material carries no asset of its
        // own: the first category hero we encounter for this material.
        String? categoryHeroUrl;
        for (final cj in dto.categories) {
          final cat = cj.category;
          if (cat == null) continue;
          categoryIds.add(cat.id);
          categoryHeroUrl ??= _assetUrl(cat.heroAsset?.defaultAsset);
          categories.putIfAbsent(
            cat.id,
            () => PathMaterialCategory(
              id: cat.id,
              title: cat.translations.firstOrNull?.title ?? '',
            ),
          );
        }

        materials.add(
          _mapMaterial(
            dto,
            categoryIds,
            isCompleted: completedIds.contains(dto.id),
            fallbackImageUrl: categoryHeroUrl,
          ),
        );
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
      final translation = dto.translations.firstOrNull;
      final articleTranslation = dto.article?.translations.firstOrNull;

      // Materials that link an article have no body/asset of their own, so we
      // fall back to the article for the body, the subtitle and the hero image.
      final content = _nonEmpty(translation?.content) ?? _articleContent(dto);
      final asset = dto.asset ?? dto.article?.cover;
      final file = asset?.defaultAsset ?? asset?.mobileAsset;

      return PathMaterialDetail(
        id: dto.id,
        title:
            _nonEmpty(translation?.title) ??
            _nonEmpty(articleTranslation?.title) ??
            '',
        isVideo: asset?.assetIsVideo ?? false,
        subtitle: _nonEmpty(articleTranslation?.subtitle),
        content: content,
        imageUrl: _assetUrl(file),
        vimeoUrl: asset?.vimeoUrl,
      );
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  @override
  Future<void> markMaterialCompleted({
    required String materialId,
    required String userId,
  }) async {
    try {
      // Idempotent: never duplicate a completion the user already has.
      final completedIds = await _fetchCompletedMaterialIds();
      if (completedIds.contains(materialId)) return;

      final now = DateTime.now().toUtc().toIso8601String();
      await _dio.post<Map<String, dynamic>>(
        '/items/user_activities',
        data: <String, dynamic>{
          'user': userId,
          // Both timestamps set so the completed-materials query (which filters
          // on `completed_on`) and the diary Cronologia pick the row up.
          'started_on': now,
          'completed_on': now,
          'activity': [
            {'collection': 'percorsi_materials', 'item': materialId},
          ],
        },
      );
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  @override
  Future<Map<String, PathGroupProgress>> fetchGroupProgress({
    required List<String> groupIds,
  }) async {
    if (groupIds.isEmpty) return const {};
    try {
      // Set of material ids the user has completed (across all groups): one read
      // instead of per-group, then intersected with each group's material ids.
      final completedIds = await _fetchCompletedMaterialIds();

      final progress = <String, PathGroupProgress>{};
      for (final groupId in groupIds) {
        final materialIds = await _fetchGroupMaterialIds(groupId);
        final completed = materialIds.where(completedIds.contains).length;
        progress[groupId] = PathGroupProgress(
          completed: completed,
          total: materialIds.length,
        );
      }
      return progress;
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// Ids of the materials tied to [groupId] via the junction (the group total).
  Future<List<String>> _fetchGroupMaterialIds(String groupId) async {
    final result = await _graphqlClient.query(
      _groupMaterialIdsQuery,
      variables: {'groupId': groupId},
    );
    final data = result['data'] as Map<String, dynamic>?;
    final rows =
        data?['percorsi_groups_percorsi_materials'] as List<dynamic>? ??
        const [];

    final ids = <String>[];
    for (final row in rows) {
      final material =
          (row as Map<String, dynamic>)['percorsi_materials_id']
              as Map<String, dynamic>?;
      final id = material?['id'];
      if (id != null) ids.add(id.toString());
    }
    return ids;
  }

  /// Ids of `percorsi_materials` the user has completed (a `user_activities`
  /// row with `completed_on` set whose activity links a material).
  Future<Set<String>> _fetchCompletedMaterialIds() async {
    final result = await _graphqlClient.query(
      _completedMaterialsQuery,
      variables: {'filter': _completedFilter},
    );
    final data = result['data'] as Map<String, dynamic>?;
    final rows = data?['user_activities'] as List<dynamic>? ?? const [];

    final ids = <String>{};
    for (final row in rows) {
      final links = (row as Map<String, dynamic>)['activity'] as List<dynamic>?;
      for (final link in links ?? const []) {
        final item =
            (link as Map<String, dynamic>)['item'] as Map<String, dynamic>?;
        if (item == null || item['__typename'] != 'percorsi_materials') {
          continue;
        }
        final id = item['id'];
        if (id != null) ids.add(id.toString());
      }
    }
    return ids;
  }

  PathMaterial _mapMaterial(
    PathMaterialDto dto,
    List<String> categoryIds, {
    required bool isCompleted,
    String? fallbackImageUrl,
  }) {
    final asset = dto.asset;
    final file = asset?.mobileAsset ?? asset?.defaultAsset;

    // Most Benessere materials (consigli and Vimeo videos) carry no image file
    // of their own; fall back to the category cover so the card is not a bare
    // placeholder — matching the web app.
    final imageUrl = _assetUrl(file) ?? fallbackImageUrl;

    return PathMaterial(
      id: dto.id,
      title: dto.translations.firstOrNull?.title ?? '',
      isVideo: asset?.assetIsVideo ?? false,
      isAvailable: dto.status == 'published',
      isCompleted: isCompleted,
      categoryIds: categoryIds,
      imageUrl: imageUrl,
    );
  }

  String? _assetUrl(PathMaterialFileDto? file) {
    if (file?.id == null) return null;
    return '${Env.baseUrl}/assets/${file!.id}/${file.filenameDownload ?? ''}';
  }

  String? _nonEmpty(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  /// HTML body of a material that links an article: the article's `plot` intro
  /// followed by its `block_text` blocks, already sorted by the query. Blocks of
  /// other collections resolve to a null `item` and are skipped.
  String? _articleContent(PathMaterialDto dto) {
    final article = dto.article;
    if (article == null) return null;

    final parts = <String>[];

    final plot = _nonEmpty(article.translations.firstOrNull?.plot);
    if (plot != null) parts.add(plot);

    for (final block in article.blocks) {
      final translation = block.item?.translations.firstOrNull;
      if (translation == null) continue;

      final title = _nonEmpty(translation.title);
      if (title != null) parts.add('<h3>$title</h3>');

      final content = _nonEmpty(translation.content);
      if (content != null) parts.add(content);
    }

    return parts.isEmpty ? null : parts.join('\n');
  }

  String _resolveLocale() {
    // The CMS uses codes like "it-IT" / "en-US". Default to Italian for now,
    // matching the rest of the GraphQL repositories.
    return 'it-IT';
  }
}
