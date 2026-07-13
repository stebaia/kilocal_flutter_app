import 'package:json_annotation/json_annotation.dart';

part 'profile_kit_dto.g.dart';

/// The backend returns ids as either strings or ints; normalize to string.
String _idFromJson(Object? value) => value?.toString() ?? '';
String? _nullableIdFromJson(Object? value) => value?.toString();

/// DTO for `product_kits` (the kit assigned to the user's profile), holding the
/// plan copy + image + CTA and the phases whose products are the supplement
/// cards. See [[integrazione-schema]].
@JsonSerializable()
class ProfileKitDto {
  const ProfileKitDto({
    required this.id,
    this.price,
    this.asset,
    this.cta,
    this.translations = const [],
    this.phases = const [],
  });

  factory ProfileKitDto.fromJson(Map<String, dynamic> json) =>
      _$ProfileKitDtoFromJson(json);

  @JsonKey(fromJson: _idFromJson)
  final String id;

  final double? price;
  final KitAssetDto? asset;
  final KitLinkDto? cta;

  /// `product_kits_translations` (holds `tipo_kit` + HTML `description`).
  final List<KitTranslationDto> translations;

  /// `product_kits.phases` → `kit_products` rows, each bundling products.
  final List<KitPhaseDto> phases;

  Map<String, dynamic> toJson() => _$ProfileKitDtoToJson(this);
}

@JsonSerializable()
class KitTranslationDto {
  const KitTranslationDto({
    this.languagesCode,
    this.tipoKit,
    this.description,
  });

  factory KitTranslationDto.fromJson(Map<String, dynamic> json) =>
      _$KitTranslationDtoFromJson(json);

  @JsonKey(name: 'languages_code')
  final LanguageCodeDto? languagesCode;

  @JsonKey(name: 'tipo_kit')
  final String? tipoKit;
  final String? description;

  Map<String, dynamic> toJson() => _$KitTranslationDtoToJson(this);
}

/// One `kit_products` row: a phase and the products bundled in it (via the
/// `products_with_duration` junction).
@JsonSerializable()
class KitPhaseDto {
  const KitPhaseDto({this.sort, this.productsWithDuration = const []});

  factory KitPhaseDto.fromJson(Map<String, dynamic> json) =>
      _$KitPhaseDtoFromJson(json);

  final int? sort;

  @JsonKey(name: 'products_with_duration')
  final List<KitProductJunctionDto> productsWithDuration;

  Map<String, dynamic> toJson() => _$KitPhaseDtoToJson(this);
}

/// Wrapper of the `products_with_duration` M2M junction row; the product lives
/// under `kit_products_duration_id.product`.
@JsonSerializable()
class KitProductJunctionDto {
  const KitProductJunctionDto({this.durationEntry});

  factory KitProductJunctionDto.fromJson(Map<String, dynamic> json) =>
      _$KitProductJunctionDtoFromJson(json);

  @JsonKey(name: 'kit_products_duration_id')
  final KitProductDurationDto? durationEntry;

  Map<String, dynamic> toJson() => _$KitProductJunctionDtoToJson(this);
}

@JsonSerializable()
class KitProductDurationDto {
  const KitProductDurationDto({this.product});

  factory KitProductDurationDto.fromJson(Map<String, dynamic> json) =>
      _$KitProductDurationDtoFromJson(json);

  final KitProductDto? product;

  Map<String, dynamic> toJson() => _$KitProductDurationDtoToJson(this);
}

/// DTO for `products` (the supplement subset used by the product cards).
@JsonSerializable()
class KitProductDto {
  const KitProductDto({
    required this.id,
    this.title,
    this.price,
    this.showInShop = true,
    this.asset,
    this.cta,
    this.translations = const [],
  });

  factory KitProductDto.fromJson(Map<String, dynamic> json) =>
      _$KitProductDtoFromJson(json);

  @JsonKey(fromJson: _idFromJson)
  final String id;
  final String? title;
  final double? price;

  @JsonKey(name: 'show_in_shop')
  final bool showInShop;

  final KitAssetDto? asset;
  final KitLinkDto? cta;

  /// `products_translations` (holds the `title` + HTML `description`).
  final List<KitProductTranslationDto> translations;

  Map<String, dynamic> toJson() => _$KitProductDtoToJson(this);
}

@JsonSerializable()
class KitProductTranslationDto {
  const KitProductTranslationDto({
    this.languagesCode,
    this.title,
    this.description,
  });

  factory KitProductTranslationDto.fromJson(Map<String, dynamic> json) =>
      _$KitProductTranslationDtoFromJson(json);

  @JsonKey(name: 'languages_code')
  final LanguageCodeDto? languagesCode;
  final String? title;
  final String? description;

  Map<String, dynamic> toJson() => _$KitProductTranslationDtoToJson(this);
}

/// A `links` row with its translations (the actual label + url live under
/// `links_translations`).
@JsonSerializable()
class KitLinkDto {
  const KitLinkDto({this.translations = const []});

  factory KitLinkDto.fromJson(Map<String, dynamic> json) =>
      _$KitLinkDtoFromJson(json);

  final List<LinkTranslationDto> translations;

  Map<String, dynamic> toJson() => _$KitLinkDtoToJson(this);
}

@JsonSerializable()
class LinkTranslationDto {
  const LinkTranslationDto({this.languagesCode, this.label, this.url});

  factory LinkTranslationDto.fromJson(Map<String, dynamic> json) =>
      _$LinkTranslationDtoFromJson(json);

  @JsonKey(name: 'languages_code')
  final LanguageCodeDto? languagesCode;
  final String? label;
  final String? url;

  Map<String, dynamic> toJson() => _$LinkTranslationDtoToJson(this);
}

@JsonSerializable()
class LanguageCodeDto {
  const LanguageCodeDto({this.code});

  factory LanguageCodeDto.fromJson(Map<String, dynamic> json) =>
      _$LanguageCodeDtoFromJson(json);

  final String? code;

  Map<String, dynamic> toJson() => _$LanguageCodeDtoToJson(this);
}

/// `product_kits.asset` / `products.asset` is an `assets` entity (not a file);
/// the image file lives in its `default_asset` relation.
@JsonSerializable()
class KitAssetDto {
  const KitAssetDto({this.id, this.defaultAsset});

  factory KitAssetDto.fromJson(Map<String, dynamic> json) =>
      _$KitAssetDtoFromJson(json);

  @JsonKey(fromJson: _nullableIdFromJson)
  final String? id;

  @JsonKey(name: 'default_asset')
  final KitFileDto? defaultAsset;

  Map<String, dynamic> toJson() => _$KitAssetDtoToJson(this);
}

/// A `directus_files` row: the actual downloadable asset.
@JsonSerializable()
class KitFileDto {
  const KitFileDto({this.id, this.filenameDownload});

  factory KitFileDto.fromJson(Map<String, dynamic> json) =>
      _$KitFileDtoFromJson(json);

  final String? id;

  @JsonKey(name: 'filename_download')
  final String? filenameDownload;

  Map<String, dynamic> toJson() => _$KitFileDtoToJson(this);
}
