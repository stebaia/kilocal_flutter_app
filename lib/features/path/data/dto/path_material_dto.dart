import 'package:json_annotation/json_annotation.dart';

part 'path_material_dto.g.dart';

/// The backend returns ids as either strings or ints; normalize to string.
String _idFromJson(Object? value) => value?.toString() ?? '';
String? _nullableIdFromJson(Object? value) => value?.toString();

/// Wrapper of the `percorsi_groups_percorsi_materials` junction row: each row
/// nests the actual material under `percorsi_materials_id`.
@JsonSerializable()
class PathMaterialJunctionDto {
  const PathMaterialJunctionDto({this.material});

  factory PathMaterialJunctionDto.fromJson(Map<String, dynamic> json) =>
      _$PathMaterialJunctionDtoFromJson(json);

  @JsonKey(name: 'percorsi_materials_id')
  final PathMaterialDto? material;

  Map<String, dynamic> toJson() => _$PathMaterialJunctionDtoToJson(this);
}

/// DTO for the `percorsi_materials` GraphQL collection.
@JsonSerializable()
class PathMaterialDto {
  const PathMaterialDto({
    required this.id,
    this.status,
    this.connectToArticle = false,
    this.asset,
    this.article,
    this.translations = const [],
    this.categories = const [],
    this.ctas = const [],
  });

  factory PathMaterialDto.fromJson(Map<String, dynamic> json) =>
      _$PathMaterialDtoFromJson(json);

  @JsonKey(fromJson: _idFromJson)
  final String id;

  /// Directus status; `"published"` ⇒ available ("Disponibile").
  final String? status;

  @JsonKey(name: 'connect_to_article')
  final bool connectToArticle;

  final PathMaterialAssetDto? asset;

  /// Linked article; holds the body when [connectToArticle] is set. Only
  /// fetched on the detail query.
  final PathMaterialArticleDto? article;

  final List<PathMaterialTranslationDto> translations;
  final List<PathMaterialCategoryJunctionDto> categories;

  /// Call-to-action links; the downloadable PDF of a "schede" material lives
  /// here rather than on [asset]. Only fetched on the detail query.
  final List<PathMaterialCtaJunctionDto> ctas;

  Map<String, dynamic> toJson() => _$PathMaterialDtoToJson(this);
}

/// Junction row of the `percorsi_materials_links` many-to-many.
@JsonSerializable()
class PathMaterialCtaJunctionDto {
  const PathMaterialCtaJunctionDto({this.link});

  factory PathMaterialCtaJunctionDto.fromJson(Map<String, dynamic> json) =>
      _$PathMaterialCtaJunctionDtoFromJson(json);

  @JsonKey(name: 'links_id')
  final PathMaterialLinkDto? link;

  Map<String, dynamic> toJson() => _$PathMaterialCtaJunctionDtoToJson(this);
}

/// DTO for a `links` row: either an external url (on the translation) or a
/// downloadable file (on [attachmentTranslations]). Both are per-language.
@JsonSerializable()
class PathMaterialLinkDto {
  const PathMaterialLinkDto({
    this.downloadOnClick = false,
    this.translations = const [],
    this.attachmentTranslations = const [],
  });

  factory PathMaterialLinkDto.fromJson(Map<String, dynamic> json) =>
      _$PathMaterialLinkDtoFromJson(json);

  @JsonKey(name: 'download_on_click')
  final bool downloadOnClick;

  final List<PathMaterialLinkTranslationDto> translations;

  /// The CMS field is misspelled (`attachemnt_translations`); the JSON key must
  /// match it verbatim.
  @JsonKey(name: 'attachemnt_translations')
  final List<PathMaterialAttachmentTranslationDto> attachmentTranslations;

  Map<String, dynamic> toJson() => _$PathMaterialLinkDtoToJson(this);
}

@JsonSerializable()
class PathMaterialLinkTranslationDto {
  const PathMaterialLinkTranslationDto({this.label, this.url});

  factory PathMaterialLinkTranslationDto.fromJson(Map<String, dynamic> json) =>
      _$PathMaterialLinkTranslationDtoFromJson(json);

  /// CTA text, e.g. "Scarica il file".
  final String? label;

  /// External url; null for attachment-backed CTAs.
  final String? url;

  Map<String, dynamic> toJson() => _$PathMaterialLinkTranslationDtoToJson(this);
}

@JsonSerializable()
class PathMaterialAttachmentTranslationDto {
  const PathMaterialAttachmentTranslationDto({this.attachment});

  factory PathMaterialAttachmentTranslationDto.fromJson(
    Map<String, dynamic> json,
  ) => _$PathMaterialAttachmentTranslationDtoFromJson(json);

  final PathMaterialFileDto? attachment;

  Map<String, dynamic> toJson() =>
      _$PathMaterialAttachmentTranslationDtoToJson(this);
}

/// DTO for the `articles` row linked by a material via `connect_to_article`.
@JsonSerializable()
class PathMaterialArticleDto {
  const PathMaterialArticleDto({
    this.cover,
    this.translations = const [],
    this.blocks = const [],
  });

  factory PathMaterialArticleDto.fromJson(Map<String, dynamic> json) =>
      _$PathMaterialArticleDtoFromJson(json);

  final PathMaterialAssetDto? cover;
  final List<PathMaterialArticleTranslationDto> translations;
  final List<PathMaterialBlockDto> blocks;

  Map<String, dynamic> toJson() => _$PathMaterialArticleDtoToJson(this);
}

@JsonSerializable()
class PathMaterialArticleTranslationDto {
  const PathMaterialArticleTranslationDto({
    this.title,
    this.subtitle,
    this.plot,
  });

  factory PathMaterialArticleTranslationDto.fromJson(
    Map<String, dynamic> json,
  ) => _$PathMaterialArticleTranslationDtoFromJson(json);

  final String? title;

  /// Rarely populated (2 of the 38 linked articles on staging).
  final String? subtitle;

  /// HTML intro shown above the blocks; the main body for most articles.
  final String? plot;

  Map<String, dynamic> toJson() =>
      _$PathMaterialArticleTranslationDtoToJson(this);
}

/// A row of the `articles_blocks` many-to-any. [item] is null for block
/// collections the detail query does not select (only `block_text` is asked
/// for), so callers must skip null items rather than assume a text block.
@JsonSerializable()
class PathMaterialBlockDto {
  const PathMaterialBlockDto({this.collection, this.item});

  factory PathMaterialBlockDto.fromJson(Map<String, dynamic> json) =>
      _$PathMaterialBlockDtoFromJson(json);

  final String? collection;
  final PathMaterialBlockItemDto? item;

  Map<String, dynamic> toJson() => _$PathMaterialBlockDtoToJson(this);
}

@JsonSerializable()
class PathMaterialBlockItemDto {
  const PathMaterialBlockItemDto({this.translations = const []});

  factory PathMaterialBlockItemDto.fromJson(Map<String, dynamic> json) =>
      _$PathMaterialBlockItemDtoFromJson(json);

  final List<PathMaterialTranslationDto> translations;

  Map<String, dynamic> toJson() => _$PathMaterialBlockItemDtoToJson(this);
}

@JsonSerializable()
class PathMaterialTranslationDto {
  const PathMaterialTranslationDto({
    this.title,
    this.content,
    this.languagesCode,
  });

  factory PathMaterialTranslationDto.fromJson(Map<String, dynamic> json) =>
      _$PathMaterialTranslationDtoFromJson(json);

  final String? title;

  /// HTML body of the material; only fetched on the detail query.
  final String? content;

  @JsonKey(name: 'languages_code')
  final PathMaterialLanguageDto? languagesCode;

  Map<String, dynamic> toJson() => _$PathMaterialTranslationDtoToJson(this);
}

@JsonSerializable()
class PathMaterialLanguageDto {
  const PathMaterialLanguageDto({this.code});

  factory PathMaterialLanguageDto.fromJson(Map<String, dynamic> json) =>
      _$PathMaterialLanguageDtoFromJson(json);

  final String? code;

  Map<String, dynamic> toJson() => _$PathMaterialLanguageDtoToJson(this);
}

@JsonSerializable()
class PathMaterialAssetDto {
  const PathMaterialAssetDto({
    this.assetIsVideo = false,
    this.vimeoUrl,
    this.defaultAsset,
    this.mobileAsset,
  });

  factory PathMaterialAssetDto.fromJson(Map<String, dynamic> json) =>
      _$PathMaterialAssetDtoFromJson(json);

  @JsonKey(name: 'asset_is_video')
  final bool assetIsVideo;

  @JsonKey(name: 'vimeo_url')
  final String? vimeoUrl;

  @JsonKey(name: 'default_asset')
  final PathMaterialFileDto? defaultAsset;

  @JsonKey(name: 'mobile_asset')
  final PathMaterialFileDto? mobileAsset;

  Map<String, dynamic> toJson() => _$PathMaterialAssetDtoToJson(this);
}

@JsonSerializable()
class PathMaterialFileDto {
  const PathMaterialFileDto({this.id, this.filenameDownload});

  factory PathMaterialFileDto.fromJson(Map<String, dynamic> json) =>
      _$PathMaterialFileDtoFromJson(json);

  @JsonKey(fromJson: _nullableIdFromJson)
  final String? id;

  @JsonKey(name: 'filename_download')
  final String? filenameDownload;

  Map<String, dynamic> toJson() => _$PathMaterialFileDtoToJson(this);
}

/// Junction row tying a material to a category
/// (`percorsi_materials_percorsi_material_categories`).
@JsonSerializable()
class PathMaterialCategoryJunctionDto {
  const PathMaterialCategoryJunctionDto({this.category});

  factory PathMaterialCategoryJunctionDto.fromJson(Map<String, dynamic> json) =>
      _$PathMaterialCategoryJunctionDtoFromJson(json);

  @JsonKey(name: 'percorsi_material_categories_id')
  final PathMaterialCategoryDto? category;

  Map<String, dynamic> toJson() =>
      _$PathMaterialCategoryJunctionDtoToJson(this);
}

@JsonSerializable()
class PathMaterialCategoryDto {
  const PathMaterialCategoryDto({
    required this.id,
    this.internalName,
    this.heroAsset,
    this.translations = const [],
  });

  factory PathMaterialCategoryDto.fromJson(Map<String, dynamic> json) =>
      _$PathMaterialCategoryDtoFromJson(json);

  @JsonKey(fromJson: _idFromJson)
  final String id;

  @JsonKey(name: 'internal_name')
  final String? internalName;

  /// Category cover image, used as the card image fallback when a material has
  /// no asset of its own (e.g. Benessere consigli/video items).
  @JsonKey(name: 'hero_asset')
  final PathMaterialHeroAssetDto? heroAsset;

  final List<PathMaterialTranslationDto> translations;

  Map<String, dynamic> toJson() => _$PathMaterialCategoryDtoToJson(this);
}

/// The `hero_asset` `assets` wrapper on a category; the image file lives under
/// `default_asset`.
@JsonSerializable()
class PathMaterialHeroAssetDto {
  const PathMaterialHeroAssetDto({this.defaultAsset});

  factory PathMaterialHeroAssetDto.fromJson(Map<String, dynamic> json) =>
      _$PathMaterialHeroAssetDtoFromJson(json);

  @JsonKey(name: 'default_asset')
  final PathMaterialFileDto? defaultAsset;

  Map<String, dynamic> toJson() => _$PathMaterialHeroAssetDtoToJson(this);
}
