// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'directus_file_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DirectusFileResponseDto _$DirectusFileResponseDtoFromJson(
  Map<String, dynamic> json,
) => DirectusFileResponseDto(
  data: DirectusFileDto.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$DirectusFileResponseDtoToJson(
  DirectusFileResponseDto instance,
) => <String, dynamic>{'data': instance.data};

DirectusFileDto _$DirectusFileDtoFromJson(Map<String, dynamic> json) =>
    DirectusFileDto(id: json['id'] as String);

Map<String, dynamic> _$DirectusFileDtoToJson(DirectusFileDto instance) =>
    <String, dynamic>{'id': instance.id};
