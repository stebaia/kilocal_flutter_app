// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_moment_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HomeMomentDto _$HomeMomentDtoFromJson(Map<String, dynamic> json) =>
    HomeMomentDto(
      id: json['id'] as String?,
      title: json['title'] as String?,
      imageFileId: json['image_file_id'] as String?,
      imageFileName: json['image_file_name'] as String?,
    );

Map<String, dynamic> _$HomeMomentDtoToJson(HomeMomentDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'image_file_id': instance.imageFileId,
      'image_file_name': instance.imageFileName,
    };
