// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'benefit_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BenefitDto _$BenefitDtoFromJson(Map<String, dynamic> json) => BenefitDto(
  id: json['id'] as String,
  name: json['name'] as String?,
  coupon: json['coupon'] as String?,
  mainPartner: json['main_partner'] as bool?,
  asset: json['asset'] == null
      ? null
      : BenefitFileDto.fromJson(json['asset'] as Map<String, dynamic>),
  logo: json['logo'] == null
      ? null
      : BenefitFileDto.fromJson(json['logo'] as Map<String, dynamic>),
  ctaBrand: json['cta_brand'] == null
      ? null
      : BenefitCtaDto.fromJson(json['cta_brand'] as Map<String, dynamic>),
  translations:
      (json['translations'] as List<dynamic>?)
          ?.map(
            (e) => BenefitTranslationDto.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
);

Map<String, dynamic> _$BenefitDtoToJson(BenefitDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'coupon': instance.coupon,
      'main_partner': instance.mainPartner,
      'asset': instance.asset,
      'logo': instance.logo,
      'cta_brand': instance.ctaBrand,
      'translations': instance.translations,
    };

BenefitFileDto _$BenefitFileDtoFromJson(Map<String, dynamic> json) =>
    BenefitFileDto(
      id: json['id'] as String?,
      filenameDownload: json['filename_download'] as String?,
    );

Map<String, dynamic> _$BenefitFileDtoToJson(BenefitFileDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'filename_download': instance.filenameDownload,
    };

BenefitCtaDto _$BenefitCtaDtoFromJson(Map<String, dynamic> json) =>
    BenefitCtaDto(
      id: json['id'] as String?,
      translations:
          (json['translations'] as List<dynamic>?)
              ?.map(
                (e) => BenefitCtaTranslationDto.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList() ??
          const [],
    );

Map<String, dynamic> _$BenefitCtaDtoToJson(BenefitCtaDto instance) =>
    <String, dynamic>{'id': instance.id, 'translations': instance.translations};

BenefitCtaTranslationDto _$BenefitCtaTranslationDtoFromJson(
  Map<String, dynamic> json,
) => BenefitCtaTranslationDto(
  url: json['url'] as String?,
  label: json['label'] as String?,
);

Map<String, dynamic> _$BenefitCtaTranslationDtoToJson(
  BenefitCtaTranslationDto instance,
) => <String, dynamic>{'url': instance.url, 'label': instance.label};

BenefitTranslationDto _$BenefitTranslationDtoFromJson(
  Map<String, dynamic> json,
) => BenefitTranslationDto(
  description: json['description'] as String?,
  couponInstructions: json['coupon_instructions'] as String?,
);

Map<String, dynamic> _$BenefitTranslationDtoToJson(
  BenefitTranslationDto instance,
) => <String, dynamic>{
  'description': instance.description,
  'coupon_instructions': instance.couponInstructions,
};
