import 'package:dio/dio.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/graphql_client.dart';
import '../../../core/utils/cms_image_url.dart';
import '../domain/entities/path_material.dart';
import '../domain/path_materials_repository.dart';
import 'dto/area_material_dto.dart';
import 'dto/path_material_dto.dart';
import 'vimeo_oembed_service.dart';

/// Implementation of [PathMaterialsRepository].
///
/// The "Materiali" group exposes no steps; its materials live in the separate
/// `percorsi_materials` collection, reachable from the group via the
/// `percorsi_groups_percorsi_materials` junction.
///
/// The list is read from the REST endpoint
/// `GET /path/me/areas/{area}/groups/{groupId}/materials`, which returns the
/// materials already normalized the way the web platform renders them: the
/// article→material fallback for title/excerpt/image is applied server-side,
/// materials whose linked article is not published are dropped, and video
/// materials with no cover file carry a Vimeo `thumbnail_url`. That fallback
/// used to live here, spread across the list query, the detail query and the
/// card mapper, and it is what made unpublished-article recipes render as empty
/// cards. The remaining reads (detail, group progress) still go through
/// GraphQL, which has no REST equivalent.
class PathMaterialsRepositoryImpl implements PathMaterialsRepository {
  PathMaterialsRepositoryImpl({
    required GraphqlClient graphqlClient,
    required Dio dio,
    required VimeoOembedService vimeoOembedService,
  }) : _graphqlClient = graphqlClient,
       _dio = dio,
       _vimeoOembedService = vimeoOembedService;

  final GraphqlClient _graphqlClient;

  /// Video materials carry no cover file in the CMS — the poster lives on Vimeo,
  /// so the card thumbnails are resolved through oEmbed (cached in the service).
  final VimeoOembedService _vimeoOembedService;

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
        vimeo_url
        default_asset { id filename_download }
        mobile_asset { id filename_download }
      }
      article {
        cover {
          asset_is_video
          vimeo_url
          default_asset { id filename_download }
          mobile_asset { id filename_download }
        }
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
  ///
  /// The downloadable PDF of a "Scheda" is not part of `asset` (which is null on
  /// those materials): it hangs off the `ctas` links, whose `attachment` is
  /// per-language. `attachemnt_translations` is misspelled in the CMS schema.
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
    categories {
      percorsi_material_categories_id {
        id
        internal_name
      }
    }
    ctas {
      links_id {
        download_on_click
        translations(filter: { languages_code: { code: { _eq: $lang } } }) {
          label
          url
        }
        attachemnt_translations(
          filter: { languages_code: { code: { _eq: $lang } } }
        ) {
          attachment { id filename_download }
        }
      }
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
  Future<PathMaterialsData> fetchMaterials({
    required String groupId,
    String? area,
  }) async {
    // Without the area key the REST route cannot be addressed, so a cold
    // deep-link into the hub still resolves through the GraphQL collection.
    if (area == null || area.isEmpty) {
      return _fetchMaterialsFromGraphql(groupId: groupId);
    }
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/path/me/areas/$area/groups/$groupId/materials',
      );

      final data = response.data?['data'] as Map<String, dynamic>?;
      if (data == null) {
        return const PathMaterialsData(categories: [], materials: []);
      }

      return _mapAreaMaterials(AreaMaterialsDto.fromJson(data));
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// Maps the normalized REST payload. The article→material fallback and the
  /// Vimeo posters are already applied server-side, so this only reshapes the
  /// rows and collects the category tabs in first-seen order.
  PathMaterialsData _mapAreaMaterials(AreaMaterialsDto dto) {
    final materials = <PathMaterial>[];
    final categories = <String, PathMaterialCategory>{};

    for (final row in dto.materials) {
      final categoryIds = <String>[];
      var hidesImage = false;

      for (final cat in row.categories) {
        final id = cat.id;
        if (id == null || id.isEmpty) continue;
        categoryIds.add(id);
        final category = categories.putIfAbsent(
          id,
          () => PathMaterialCategory(
            id: id,
            title: cat.resolvedTitle ?? '',
            internalName: cat.internalName,
          ),
        );
        hidesImage = hidesImage || category.hidesImage;
      }

      final image = row.image;
      final file = image?.mobileAsset ?? image?.defaultAsset;

      materials.add(
        PathMaterial(
          id: row.id,
          title: row.translations.firstOrNull?.title ?? '',
          isVideo: image?.assetIsVideo ?? false,
          isAvailable: row.status == 'published',
          isCompleted: row.completed,
          categoryIds: categoryIds,
          // `thumbnail_url` is the Vimeo poster the server resolved for video
          // materials that carry no cover file of their own.
          imageUrl: _assetUrl(file, CmsImageSize.card) ?? row.thumbnailUrl,
          hidesImage: hidesImage,
        ),
      );
    }

    return PathMaterialsData(
      categories: categories.values.toList(),
      materials: materials,
    );
  }

  /// Legacy GraphQL read of the group's materials, kept for callers that reach
  /// the hub without an area key. Applies the article→material cover fallback
  /// client-side; the REST path gets it from the server instead.
  Future<PathMaterialsData> _fetchMaterialsFromGraphql({
    required String groupId,
  }) async {
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

      final dtos = <PathMaterialDto>[];
      for (final row in rows) {
        final junction = PathMaterialJunctionDto.fromJson(
          row as Map<String, dynamic>,
        );
        final dto = junction.material;
        if (dto != null) dtos.add(dto);
      }

      // Vimeo posters for the video materials, resolved in one concurrent pass
      // so the cards don't fall back to the category hero.
      final posters = await _vimeoOembedService.fetchAll(
        dtos
            .where((dto) => dto.asset?.assetIsVideo ?? false)
            .map((dto) => dto.asset?.vimeoUrl)
            .whereType<String>(),
      );

      final materials = <PathMaterial>[];
      // Preserve first-seen order of categories across all materials so the tab
      // order is stable.
      final categories = <String, PathMaterialCategory>{};

      for (final dto in dtos) {
        final categoryIds = <String>[];
        // Cover image to fall back to when the material carries no asset of its
        // own: the first category hero we encounter for this material.
        String? categoryHeroUrl;
        var hidesImage = false;
        for (final cj in dto.categories) {
          final cat = cj.category;
          if (cat == null) continue;
          categoryIds.add(cat.id);
          categoryHeroUrl ??= _assetUrl(
            cat.heroAsset?.defaultAsset,
            CmsImageSize.hero,
          );
          final category = categories.putIfAbsent(
            cat.id,
            () => PathMaterialCategory(
              id: cat.id,
              title: cat.translations.firstOrNull?.title ?? '',
              internalName: cat.internalName,
            ),
          );
          hidesImage = hidesImage || category.hidesImage;
        }

        final vimeoUrl = dto.asset?.vimeoUrl;
        materials.add(
          _mapMaterial(
            dto,
            categoryIds,
            isCompleted: completedIds.contains(dto.id),
            vimeoPosterUrl: vimeoUrl == null
                ? null
                : posters[vimeoUrl]?.thumbnailUrl,
            fallbackImageUrl: categoryHeroUrl,
            hidesImage: hidesImage,
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
      final completedIds = await _fetchCompletedMaterialIds();

      return PathMaterialDetail(
        id: dto.id,
        title:
            _nonEmpty(translation?.title) ??
            _nonEmpty(articleTranslation?.title) ??
            '',
        isVideo: asset?.assetIsVideo ?? false,
        isCompleted: completedIds.contains(dto.id),
        subtitle: _nonEmpty(articleTranslation?.subtitle),
        content: content,
        imageUrl: _assetUrl(file, CmsImageSize.hero),
        vimeoUrl: asset?.vimeoUrl,
        attachments: _attachments(dto),
        hidesImage: _isAdvice(dto),
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
    required bool hidesImage,
    String? vimeoPosterUrl,
    String? fallbackImageUrl,
  }) {
    final asset = dto.asset;

    // "Schede" and "Ricette" are `connect_to_article` materials with a null
    // `asset`: their cover lives on the linked article, exactly like in the
    // detail screen. Without this fallback the whole tab renders placeholders.
    // Only the image is borrowed — the play/document badge must keep following
    // the material's own asset, or an article with a video cover would badge a
    // PDF card as a video.
    final coverAsset = asset ?? dto.article?.cover;
    final file = coverAsset?.mobileAsset ?? coverAsset?.defaultAsset;

    // Video materials carry no image file of their own, so their cover is the
    // Vimeo poster; the remaining ones (consigli) fall back to the category
    // cover so the card is not a bare placeholder — matching the web app.
    final imageUrl =
        _assetUrl(file, CmsImageSize.card) ??
        vimeoPosterUrl ??
        fallbackImageUrl;

    return PathMaterial(
      id: dto.id,
      title: dto.translations.firstOrNull?.title ?? '',
      isVideo: asset?.assetIsVideo ?? false,
      isAvailable: dto.status == 'published',
      isCompleted: isCompleted,
      categoryIds: categoryIds,
      imageUrl: imageUrl,
      hidesImage: hidesImage,
    );
  }

  /// Whether the material belongs to the "Consigli utili" category, which is
  /// rendered text-only.
  bool _isAdvice(PathMaterialDto dto) => dto.categories.any(
    (cj) => cj.category?.internalName == PathMaterialCategories.advice,
  );

  /// Image url for a material cover/thumbnail, resized server-side.
  ///
  /// The REST materials payload returns files without `filename_download`
  /// (only id/width/height/type), and Directus serves `/assets/<id>` on its
  /// own — so the name is appended only when there is one, rather than
  /// building a url with a dangling slash.
  String? _assetUrl(PathMaterialFileDto? file, CmsImageSize size) =>
      cmsImageUrl(file?.id, size: size, filename: file?.filenameDownload);

  /// Untransformed url for a downloadable attachment (PDFs and the like),
  /// which must not go through the image pipeline.
  ///
  /// Attachment file names contain spaces ("Obiettivo della settimana.pdf"),
  /// which would make the url unparseable for url_launcher.
  String? _attachmentUrl(PathMaterialFileDto? file) =>
      cmsFileUrl(file?.id, filename: file?.filenameDownload);

  String? _nonEmpty(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  /// Downloadable files offered by the material's CTAs. A `links` row can also
  /// carry an external `url` instead of a file; those are skipped, since the
  /// detail screen only renders downloads.
  List<PathMaterialAttachment> _attachments(PathMaterialDto dto) {
    final attachments = <PathMaterialAttachment>[];

    for (final junction in dto.ctas) {
      final link = junction.link;
      if (link == null) continue;

      final label = _nonEmpty(link.translations.firstOrNull?.label);

      for (final translation in link.attachmentTranslations) {
        final file = translation.attachment;
        final url = _attachmentUrl(file);
        if (url == null) continue;

        attachments.add(
          PathMaterialAttachment(
            url: url,
            label: label ?? file?.filenameDownload ?? '',
          ),
        );
      }
    }

    return attachments;
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
