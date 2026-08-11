import 'package:json_annotation/json_annotation.dart';

import 'path_material_dto.dart';

part 'area_material_dto.g.dart';

/// The backend returns ids as either strings or ints; normalize to string.
String _idFromJson(Object? value) => value?.toString() ?? '';
String? _nullableIdFromJson(Object? value) => value?.toString();

/// Payload of `GET /path/me/areas/{area}/groups/{groupId}/materials`.
///
/// Unlike the GraphQL collection, this endpoint returns materials already
/// normalized: the server applies the same article→material fallback as the web
/// platform (title/excerpt/image taken from the linked published article when
/// the material itself carries none) and drops materials whose article is not
/// published. Video materials missing a cover file are enriched with a
/// [AreaMaterialDto.thumbnailUrl] resolved through Vimeo oEmbed server-side.
@JsonSerializable()
class AreaMaterialsDto {
  const AreaMaterialsDto({
    this.area,
    this.groupId,
    this.categoryId,
    this.materials = const [],
  });

  factory AreaMaterialsDto.fromJson(Map<String, dynamic> json) =>
      _$AreaMaterialsDtoFromJson(json);

  final String? area;

  @JsonKey(name: 'group_id', fromJson: _nullableIdFromJson)
  final String? groupId;

  /// Echo of the `category_id` filter; null when the request was unfiltered.
  @JsonKey(name: 'category_id', fromJson: _nullableIdFromJson)
  final String? categoryId;

  final List<AreaMaterialDto> materials;

  Map<String, dynamic> toJson() => _$AreaMaterialsDtoToJson(this);
}

/// A single normalized material row.
@JsonSerializable()
class AreaMaterialDto {
  const AreaMaterialDto({
    required this.id,
    this.status,
    this.sort,
    this.canCheckAsCompleted,
    this.contentSource,
    this.articleId,
    this.articleStatus,
    this.articleSlug,
    this.translations = const [],
    this.image,
    this.thumbnailUrl,
    this.categories = const [],
    this.completed = false,
    this.completedOn,
  });

  factory AreaMaterialDto.fromJson(Map<String, dynamic> json) =>
      _$AreaMaterialDtoFromJson(json);

  @JsonKey(fromJson: _idFromJson)
  final String id;

  /// Directus status; `"published"` ⇒ available ("Disponibile").
  final String? status;

  final int? sort;

  @JsonKey(name: 'can_check_as_completed')
  final bool? canCheckAsCompleted;

  /// Where the server took title/excerpt/image from: `article` or `material`.
  @JsonKey(name: 'content_source')
  final String? contentSource;

  @JsonKey(name: 'article_id', fromJson: _nullableIdFromJson)
  final String? articleId;

  @JsonKey(name: 'article_status')
  final String? articleStatus;

  @JsonKey(name: 'article_slug')
  final String? articleSlug;

  final List<AreaMaterialTranslationDto> translations;

  /// Cover asset, already resolved from the article when the material has none.
  final PathMaterialAssetDto? image;

  /// Vimeo poster, filled in by the server when [image] carries no file.
  @JsonKey(name: 'thumbnail_url')
  final String? thumbnailUrl;

  final List<AreaMaterialCategoryDto> categories;

  /// Whether the user has completed this material — computed server-side, so
  /// the client no longer intersects `user_activities` itself.
  final bool completed;

  @JsonKey(name: 'completed_on')
  final String? completedOn;

  Map<String, dynamic> toJson() => _$AreaMaterialDtoToJson(this);
}

@JsonSerializable()
class AreaMaterialTranslationDto {
  const AreaMaterialTranslationDto({
    this.languagesCode,
    this.title,
    this.excerpt,
  });

  factory AreaMaterialTranslationDto.fromJson(Map<String, dynamic> json) =>
      _$AreaMaterialTranslationDtoFromJson(json);

  /// Plain language code (e.g. `it-IT`) — a string here, unlike the nested
  /// object the GraphQL translations use.
  @JsonKey(name: 'languages_code')
  final String? languagesCode;

  final String? title;

  /// Article `plot` or material `content`, depending on `content_source`.
  final String? excerpt;

  Map<String, dynamic> toJson() => _$AreaMaterialTranslationDtoToJson(this);
}

/// Category attached to a normalized material.
///
/// The OpenAPI spec types this as a bare object, so the field names below were
/// kept aligned with the `percorsi_material_categories` collection the GraphQL
/// path already maps. Every field is optional: an unexpected shape degrades to
/// an id-less category that the mapper skips rather than throwing.
@JsonSerializable()
class AreaMaterialCategoryDto {
  const AreaMaterialCategoryDto({
    this.id,
    this.internalName,
    this.title,
    this.translations = const [],
  });

  factory AreaMaterialCategoryDto.fromJson(Map<String, dynamic> json) =>
      _$AreaMaterialCategoryDtoFromJson(json);

  @JsonKey(fromJson: _nullableIdFromJson)
  final String? id;

  @JsonKey(name: 'internal_name')
  final String? internalName;

  /// Title when the server flattens the translation onto the category itself;
  /// otherwise it arrives in [translations].
  final String? title;

  final List<AreaMaterialTranslationDto> translations;

  /// Localized label, whichever of the two shapes the payload uses.
  String? get resolvedTitle => title ?? translations.firstOrNull?.title;

  Map<String, dynamic> toJson() => _$AreaMaterialCategoryDtoToJson(this);
}
