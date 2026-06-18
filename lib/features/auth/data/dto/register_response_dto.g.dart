// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegisterResponseDto _$RegisterResponseDtoFromJson(Map<String, dynamic> json) =>
    RegisterResponseDto(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
    );

Map<String, dynamic> _$RegisterResponseDtoToJson(
  RegisterResponseDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'first_name': instance.firstName,
  'last_name': instance.lastName,
};
