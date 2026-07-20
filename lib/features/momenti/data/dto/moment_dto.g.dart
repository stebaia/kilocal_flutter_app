// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moment_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MomentDto _$MomentDtoFromJson(Map<String, dynamic> json) => MomentDto(
  id: json['id'] as String,
  translations:
      (json['translations'] as List<dynamic>?)
          ?.map((e) => MomentTranslationDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  asset: json['asset'] == null
      ? null
      : MomentAssetDto.fromJson(json['asset'] as Map<String, dynamic>),
);

Map<String, dynamic> _$MomentDtoToJson(MomentDto instance) => <String, dynamic>{
  'id': instance.id,
  'translations': instance.translations,
  'asset': instance.asset,
};

MomentTranslationDto _$MomentTranslationDtoFromJson(
  Map<String, dynamic> json,
) => MomentTranslationDto(
  title: json['title'] as String?,
  description: json['description'] as String?,
  plot: json['plot'] as String?,
);

Map<String, dynamic> _$MomentTranslationDtoToJson(
  MomentTranslationDto instance,
) => <String, dynamic>{
  'title': instance.title,
  'description': instance.description,
  'plot': instance.plot,
};

MomentAssetDto _$MomentAssetDtoFromJson(Map<String, dynamic> json) =>
    MomentAssetDto(
      defaultAsset: json['default_asset'] == null
          ? null
          : MomentFileDto.fromJson(
              json['default_asset'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$MomentAssetDtoToJson(MomentAssetDto instance) =>
    <String, dynamic>{'default_asset': instance.defaultAsset};

MomentFileDto _$MomentFileDtoFromJson(Map<String, dynamic> json) =>
    MomentFileDto(
      id: json['id'] as String?,
      filenameDownload: json['filename_download'] as String?,
    );

Map<String, dynamic> _$MomentFileDtoToJson(MomentFileDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'filename_download': instance.filenameDownload,
    };
