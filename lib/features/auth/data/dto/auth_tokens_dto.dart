import 'package:json_annotation/json_annotation.dart';

part 'auth_tokens_dto.g.dart';

/// Response of `POST /auth/login` and `POST /auth/refresh`.
///
/// Shape: `{ "data": { "access_token": "...", "refresh_token": "...", "expires": 900000 } }`.
@JsonSerializable()
class AuthTokensDto {
  const AuthTokensDto({required this.data});

  final AuthTokensDataDto data;

  factory AuthTokensDto.fromJson(Map<String, dynamic> json) =>
      _$AuthTokensDtoFromJson(json);

  Map<String, dynamic> toJson() => _$AuthTokensDtoToJson(this);
}

@JsonSerializable()
class AuthTokensDataDto {
  const AuthTokensDataDto({
    required this.accessToken,
    required this.refreshToken,
    this.expires,
  });

  @JsonKey(name: 'access_token')
  final String accessToken;

  @JsonKey(name: 'refresh_token')
  final String refreshToken;

  final int? expires;

  factory AuthTokensDataDto.fromJson(Map<String, dynamic> json) =>
      _$AuthTokensDataDtoFromJson(json);

  Map<String, dynamic> toJson() => _$AuthTokensDataDtoToJson(this);
}
