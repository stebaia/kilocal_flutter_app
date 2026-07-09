// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'integrazione_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

KitProductDto _$KitProductDtoFromJson(Map<String, dynamic> json) =>
    KitProductDto(
      id: _idFromJson(json['id']),
      sort: (json['sort'] as num?)?.toInt(),
      onlyForGender: json['only_for_gender'] as String?,
      phase: json['phase'] == null
          ? null
          : PhaseDto.fromJson(json['phase'] as Map<String, dynamic>),
      productsWithDuration:
          (json['products_with_duration'] as List<dynamic>?)
              ?.map(
                (e) => ProductDurationJunctionDto.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList() ??
          const [],
    );

Map<String, dynamic> _$KitProductDtoToJson(KitProductDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sort': instance.sort,
      'only_for_gender': instance.onlyForGender,
      'phase': instance.phase,
      'products_with_duration': instance.productsWithDuration,
    };

PhaseDto _$PhaseDtoFromJson(Map<String, dynamic> json) => PhaseDto(
  id: _idFromJson(json['id']),
  sort: (json['sort'] as num?)?.toInt(),
  translations:
      (json['translations'] as List<dynamic>?)
          ?.map((e) => PhaseTranslationDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$PhaseDtoToJson(PhaseDto instance) => <String, dynamic>{
  'id': instance.id,
  'sort': instance.sort,
  'translations': instance.translations,
};

PhaseTranslationDto _$PhaseTranslationDtoFromJson(Map<String, dynamic> json) =>
    PhaseTranslationDto(
      languagesCode: json['languages_code'] == null
          ? null
          : LanguageCodeDto.fromJson(
              json['languages_code'] as Map<String, dynamic>,
            ),
      title: json['title'] as String?,
    );

Map<String, dynamic> _$PhaseTranslationDtoToJson(
  PhaseTranslationDto instance,
) => <String, dynamic>{
  'languages_code': instance.languagesCode,
  'title': instance.title,
};

LanguageCodeDto _$LanguageCodeDtoFromJson(Map<String, dynamic> json) =>
    LanguageCodeDto(code: json['code'] as String?);

Map<String, dynamic> _$LanguageCodeDtoToJson(LanguageCodeDto instance) =>
    <String, dynamic>{'code': instance.code};

ProductDurationJunctionDto _$ProductDurationJunctionDtoFromJson(
  Map<String, dynamic> json,
) => ProductDurationJunctionDto(
  durationEntry: json['kit_products_duration_id'] == null
      ? null
      : ProductDurationDto.fromJson(
          json['kit_products_duration_id'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$ProductDurationJunctionDtoToJson(
  ProductDurationJunctionDto instance,
) => <String, dynamic>{'kit_products_duration_id': instance.durationEntry};

ProductDurationDto _$ProductDurationDtoFromJson(Map<String, dynamic> json) =>
    ProductDurationDto(
      id: _idFromJson(json['id']),
      duration: (json['duration'] as num?)?.toInt(),
      quantity: (json['quantity'] as num?)?.toInt(),
      product: json['product'] == null
          ? null
          : ProductDto.fromJson(json['product'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ProductDurationDtoToJson(ProductDurationDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'duration': instance.duration,
      'quantity': instance.quantity,
      'product': instance.product,
    };

ProductDto _$ProductDtoFromJson(Map<String, dynamic> json) => ProductDto(
  id: _idFromJson(json['id']),
  title: json['title'] as String?,
  useForBarcodeCheck: json['use_for_barcode_check'] as bool? ?? false,
  asset: json['asset'] == null
      ? null
      : ProductAssetDto.fromJson(json['asset'] as Map<String, dynamic>),
  translations:
      (json['translations'] as List<dynamic>?)
          ?.map(
            (e) => ProductTranslationDto.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
);

Map<String, dynamic> _$ProductDtoToJson(ProductDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'use_for_barcode_check': instance.useForBarcodeCheck,
      'asset': instance.asset,
      'translations': instance.translations,
    };

ProductTranslationDto _$ProductTranslationDtoFromJson(
  Map<String, dynamic> json,
) => ProductTranslationDto(
  languagesCode: json['languages_code'] == null
      ? null
      : LanguageCodeDto.fromJson(
          json['languages_code'] as Map<String, dynamic>,
        ),
  instructions: json['instructions'] as String?,
  timing: json['timing'] as String?,
  description: json['description'] as String?,
  avvertenze: json['avvertenze'] as String?,
);

Map<String, dynamic> _$ProductTranslationDtoToJson(
  ProductTranslationDto instance,
) => <String, dynamic>{
  'languages_code': instance.languagesCode,
  'instructions': instance.instructions,
  'timing': instance.timing,
  'description': instance.description,
  'avvertenze': instance.avvertenze,
};

UserIntegratoreDto _$UserIntegratoreDtoFromJson(Map<String, dynamic> json) =>
    UserIntegratoreDto(
      id: _idFromJson(json['id']),
      product: json['product'] == null
          ? null
          : ProductRefDto.fromJson(json['product'] as Map<String, dynamic>),
      tookDates: json['took_dates'] == null
          ? const []
          : _tookDatesFromJson(json['took_dates']),
      startedOn: json['started_on'] == null
          ? null
          : DateTime.parse(json['started_on'] as String),
      endedOn: json['ended_on'] == null
          ? null
          : DateTime.parse(json['ended_on'] as String),
      expectedToEndOn: json['expected_to_end_on'] == null
          ? null
          : DateTime.parse(json['expected_to_end_on'] as String),
      delayDays: json['delay_days'] as String?,
    );

Map<String, dynamic> _$UserIntegratoreDtoToJson(UserIntegratoreDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'product': instance.product,
      'took_dates': instance.tookDates.map((e) => e.toIso8601String()).toList(),
      'started_on': instance.startedOn?.toIso8601String(),
      'ended_on': instance.endedOn?.toIso8601String(),
      'expected_to_end_on': instance.expectedToEndOn?.toIso8601String(),
      'delay_days': instance.delayDays,
    };

ProductRefDto _$ProductRefDtoFromJson(Map<String, dynamic> json) =>
    ProductRefDto(id: _idFromJson(json['id']));

Map<String, dynamic> _$ProductRefDtoToJson(ProductRefDto instance) =>
    <String, dynamic>{'id': instance.id};

ProductAssetDto _$ProductAssetDtoFromJson(Map<String, dynamic> json) =>
    ProductAssetDto(
      id: _nullableIdFromJson(json['id']),
      defaultAsset: json['default_asset'] == null
          ? null
          : ProductFileDto.fromJson(
              json['default_asset'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$ProductAssetDtoToJson(ProductAssetDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'default_asset': instance.defaultAsset,
    };

ProductFileDto _$ProductFileDtoFromJson(Map<String, dynamic> json) =>
    ProductFileDto(
      id: json['id'] as String?,
      filenameDownload: json['filename_download'] as String?,
    );

Map<String, dynamic> _$ProductFileDtoToJson(ProductFileDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'filename_download': instance.filenameDownload,
    };
