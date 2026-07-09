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
    this.translations = const [],
    this.categories = const [],
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
  final List<PathMaterialTranslationDto> translations;
  final List<PathMaterialCategoryJunctionDto> categories;

  Map<String, dynamic> toJson() => _$PathMaterialDtoToJson(this);
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
