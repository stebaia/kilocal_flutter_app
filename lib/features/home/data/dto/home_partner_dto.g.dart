// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_partner_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HomePartnerDto _$HomePartnerDtoFromJson(Map<String, dynamic> json) =>
    HomePartnerDto(
      id: json['id'] as String?,
      name: json['name'] as String?,
      imageFileId: json['image_file_id'] as String?,
      imageFileName: json['image_file_name'] as String?,
      mainPartner: json['main_partner'] as bool?,
    );

Map<String, dynamic> _$HomePartnerDtoToJson(HomePartnerDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'image_file_id': instance.imageFileId,
      'image_file_name': instance.imageFileName,
      'main_partner': instance.mainPartner,
    };
