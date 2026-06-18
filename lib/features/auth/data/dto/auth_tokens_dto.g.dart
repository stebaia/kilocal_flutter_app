// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_tokens_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthTokensDto _$AuthTokensDtoFromJson(Map<String, dynamic> json) =>
    AuthTokensDto(
      data: AuthTokensDataDto.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AuthTokensDtoToJson(AuthTokensDto instance) =>
    <String, dynamic>{'data': instance.data};

AuthTokensDataDto _$AuthTokensDataDtoFromJson(Map<String, dynamic> json) =>
    AuthTokensDataDto(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      expires: (json['expires'] as num?)?.toInt(),
    );

Map<String, dynamic> _$AuthTokensDataDtoToJson(AuthTokensDataDto instance) =>
    <String, dynamic>{
      'access_token': instance.accessToken,
      'refresh_token': instance.refreshToken,
      'expires': instance.expires,
    };
