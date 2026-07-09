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
    this.avatar,
  });

  final String id;
  final String? email;

  @JsonKey(name: 'first_name')
  final String? firstName;

  @JsonKey(name: 'last_name')
  final String? lastName;

  /// The user's role. Expanded to `{name}` on `GET /users/me?fields=...role.name`,
  /// but a plain id string on unqualified responses (e.g. `PATCH /users/me`);
  /// [_role] tolerates both, yielding `null` when not expanded.
  @JsonKey(fromJson: _role)
  final UserRoleDto? role;

  /// Avatar file id (`directus_users.avatar`), served at `/assets/{id}`.
  /// `null` when the user has no profile photo.
  @JsonKey(fromJson: _avatarId)
  final String? avatar;

  factory CurrentUserDataDto.fromJson(Map<String, dynamic> json) =>
      _$CurrentUserDataDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CurrentUserDataDtoToJson(this);
}

/// `role` arrives as an expanded object `{name}` when requested with
/// `fields=...role.name`, or as a plain id string otherwise. Parses the object
/// form and returns `null` for the string form (no name available).
UserRoleDto? _role(dynamic value) {
  if (value is Map<String, dynamic>) return UserRoleDto.fromJson(value);
  return null;
}

/// `avatar` may arrive as a plain file-id string or, when expanded, as an
/// object with an `id`. Returns the file id or `null`.
String? _avatarId(dynamic value) {
  if (value == null) return null;
  if (value is String) return value.isEmpty ? null : value;
  if (value is Map) return value['id']?.toString();
  return value.toString();
}

@JsonSerializable()
class UserRoleDto {
  const UserRoleDto({this.name});

  final String? name;

  factory UserRoleDto.fromJson(Map<String, dynamic> json) =>
      _$UserRoleDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UserRoleDtoToJson(this);
}
