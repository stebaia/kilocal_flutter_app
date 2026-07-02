// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'current_user_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CurrentUserResponseDto _$CurrentUserResponseDtoFromJson(
  Map<String, dynamic> json,
) => CurrentUserResponseDto(
  data: CurrentUserDataDto.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$CurrentUserResponseDtoToJson(
  CurrentUserResponseDto instance,
) => <String, dynamic>{'data': instance.data};

CurrentUserDataDto _$CurrentUserDataDtoFromJson(Map<String, dynamic> json) =>
    CurrentUserDataDto(
      id: json['id'] as String,
      email: json['email'] as String?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      role: json['role'] == null
          ? null
          : UserRoleDto.fromJson(json['role'] as Map<String, dynamic>),
      avatar: _avatarId(json['avatar']),
    );

Map<String, dynamic> _$CurrentUserDataDtoToJson(CurrentUserDataDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'role': instance.role,
      'avatar': instance.avatar,
    };

UserRoleDto _$UserRoleDtoFromJson(Map<String, dynamic> json) =>
    UserRoleDto(name: json['name'] as String?);

Map<String, dynamic> _$UserRoleDtoToJson(UserRoleDto instance) =>
    <String, dynamic>{'name': instance.name};
