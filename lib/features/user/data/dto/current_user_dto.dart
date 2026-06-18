import 'package:json_annotation/json_annotation.dart';

part 'current_user_dto.g.dart';

/// Response wrapper of `GET /users/me` ([[user-current]]).
///
/// Directus wraps the user object under a top-level `data` key:
/// ```json
/// {
///   "data": {
///     "id": "...",
///     "email": "...",
///     "first_name": "...",
///     "last_name": "...",
///     "role": { "name": "..." }
///   }
/// }
/// ```
@JsonSerializable()
class CurrentUserResponseDto {
  const CurrentUserResponseDto({required this.data});

  final CurrentUserDataDto data;

  factory CurrentUserResponseDto.fromJson(Map<String, dynamic> json) =>
      _$CurrentUserResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CurrentUserResponseDtoToJson(this);
}

@JsonSerializable()
class CurrentUserDataDto {
  const CurrentUserDataDto({
    required this.id,
    this.email,
    this.firstName,
    this.lastName,
    this.role,
  });

  final String id;
  final String? email;

  @JsonKey(name: 'first_name')
  final String? firstName;

  @JsonKey(name: 'last_name')
  final String? lastName;

  final UserRoleDto? role;

  factory CurrentUserDataDto.fromJson(Map<String, dynamic> json) =>
      _$CurrentUserDataDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CurrentUserDataDtoToJson(this);
}

@JsonSerializable()
class UserRoleDto {
  const UserRoleDto({this.name});

  final String? name;

  factory UserRoleDto.fromJson(Map<String, dynamic> json) =>
      _$UserRoleDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UserRoleDtoToJson(this);
}
