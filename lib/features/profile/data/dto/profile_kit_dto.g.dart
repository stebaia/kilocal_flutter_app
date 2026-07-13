// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_kit_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProfileKitDto _$ProfileKitDtoFromJson(Map<String, dynamic> json) =>
    ProfileKitDto(
      id: _idFromJson(json['id']),
      price: (json['price'] as num?)?.toDouble(),
      asset: json['asset'] == null
          ? null
          : KitAssetDto.fromJson(json['asset'] as Map<String, dynamic>),
      cta: json['cta'] == null
          ? null
          : KitLinkDto.fromJson(json['cta'] as Map<String, dynamic>),
      translations:
          (json['translations'] as List<dynamic>?)
              ?.map(
                (e) => KitTranslationDto.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      phases:
          (json['phases'] as List<dynamic>?)
              ?.map((e) => KitPhaseDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$ProfileKitDtoToJson(ProfileKitDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'price': instance.price,
      'asset': instance.asset,
      'cta': instance.cta,
      'translations': instance.translations,
      'phases': instance.phases,
    };

KitTranslationDto _$KitTranslationDtoFromJson(Map<String, dynamic> json) =>
    KitTranslationDto(
      languagesCode: json['languages_code'] == null
          ? null
          : LanguageCodeDto.fromJson(
              json['languages_code'] as Map<String, dynamic>,
            ),
      tipoKit: json['tipo_kit'] as String?,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$KitTranslationDtoToJson(KitTranslationDto instance) =>
    <String, dynamic>{
      'languages_code': instance.languagesCode,
      'tipo_kit': instance.tipoKit,
      'description': instance.description,
    };

KitPhaseDto _$KitPhaseDtoFromJson(Map<String, dynamic> json) => KitPhaseDto(
  sort: (json['sort'] as num?)?.toInt(),
  productsWithDuration:
      (json['products_with_duration'] as List<dynamic>?)
          ?.map(
            (e) => KitProductJunctionDto.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
);

Map<String, dynamic> _$KitPhaseDtoToJson(KitPhaseDto instance) =>
    <String, dynamic>{
      'sort': instance.sort,
      'products_with_duration': instance.productsWithDuration,
    };

KitProductJunctionDto _$KitProductJunctionDtoFromJson(
  Map<String, dynamic> json,
) => KitProductJunctionDto(
  durationEntry: json['kit_products_duration_id'] == null
      ? null
      : KitProductDurationDto.fromJson(
          json['kit_products_duration_id'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$KitProductJunctionDtoToJson(
  KitProductJunctionDto instance,
) => <String, dynamic>{'kit_products_duration_id': instance.durationEntry};

KitProductDurationDto _$KitProductDurationDtoFromJson(
  Map<String, dynamic> json,
) => KitProductDurationDto(
  product: json['product'] == null
      ? null
      : KitProductDto.fromJson(json['product'] as Map<String, dynamic>),
);

Map<String, dynamic> _$KitProductDurationDtoToJson(
  KitProductDurationDto instance,
) => <String, dynamic>{'product': instance.product};

KitProductDto _$KitProductDtoFromJson(Map<String, dynamic> json) =>
    KitProductDto(
      id: _idFromJson(json['id']),
      title: json['title'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      showInShop: json['show_in_shop'] as bool? ?? true,
      asset: json['asset'] == null
          ? null
          : KitAssetDto.fromJson(json['asset'] as Map<String, dynamic>),
      cta: json['cta'] == null
          ? null
          : KitLinkDto.fromJson(json['cta'] as Map<String, dynamic>),
      translations:
          (json['translations'] as List<dynamic>?)
              ?.map(
                (e) => KitProductTranslationDto.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList() ??
          const [],
    );

Map<String, dynamic> _$KitProductDtoToJson(KitProductDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'price': instance.price,
      'show_in_shop': instance.showInShop,
      'asset': instance.asset,
      'cta': instance.cta,
      'translations': instance.translations,
    };

KitProductTranslationDto _$KitProductTranslationDtoFromJson(
  Map<String, dynamic> json,
) => KitProductTranslationDto(
  languagesCode: json['languages_code'] == null
      ? null
      : LanguageCodeDto.fromJson(
          json['languages_code'] as Map<String, dynamic>,
        ),
  title: json['title'] as String?,
  description: json['description'] as String?,
);

Map<String, dynamic> _$KitProductTranslationDtoToJson(
  KitProductTranslationDto instance,
) => <String, dynamic>{
  'languages_code': instance.languagesCode,
  'title': instance.title,
  'description': instance.description,
};

KitLinkDto _$KitLinkDtoFromJson(Map<String, dynamic> json) => KitLinkDto(
  translations:
      (json['translations'] as List<dynamic>?)
          ?.map((e) => LinkTranslationDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$KitLinkDtoToJson(KitLinkDto instance) =>
    <String, dynamic>{'translations': instance.translations};

LinkTranslationDto _$LinkTranslationDtoFromJson(Map<String, dynamic> json) =>
    LinkTranslationDto(
      languagesCode: json['languages_code'] == null
          ? null
          : LanguageCodeDto.fromJson(
              json['languages_code'] as Map<String, dynamic>,
            ),
      label: json['label'] as String?,
      url: json['url'] as String?,
    );

Map<String, dynamic> _$LinkTranslationDtoToJson(LinkTranslationDto instance) =>
    <String, dynamic>{
      'languages_code': instance.languagesCode,
      'label': instance.label,
      'url': instance.url,
    };

LanguageCodeDto _$LanguageCodeDtoFromJson(Map<String, dynamic> json) =>
    LanguageCodeDto(code: json['code'] as String?);

Map<String, dynamic> _$LanguageCodeDtoToJson(LanguageCodeDto instance) =>
    <String, dynamic>{'code': instance.code};

KitAssetDto _$KitAssetDtoFromJson(Map<String, dynamic> json) => KitAssetDto(
  id: _nullableIdFromJson(json['id']),
  defaultAsset: json['default_asset'] == null
      ? null
      : KitFileDto.fromJson(json['default_asset'] as Map<String, dynamic>),
);

Map<String, dynamic> _$KitAssetDtoToJson(KitAssetDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'default_asset': instance.defaultAsset,
    };

KitFileDto _$KitFileDtoFromJson(Map<String, dynamic> json) => KitFileDto(
  id: json['id'] as String?,
  filenameDownload: json['filename_download'] as String?,
);

Map<String, dynamic> _$KitFileDtoToJson(KitFileDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'filename_download': instance.filenameDownload,
    };
