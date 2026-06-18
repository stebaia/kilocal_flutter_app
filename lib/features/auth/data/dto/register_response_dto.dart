import 'package:json_annotation/json_annotation.dart';

part 'register_response_dto.g.dart';

/// Response of `POST /api/auth/register`.
///
/// Shape: `{ "id": "...", "email": "...", "first_name": "...", "last_name": "..." }`.
@JsonSerializable()
class RegisterResponseDto {
  const RegisterResponseDto({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
  });

  final String id;
  final String email;

  @JsonKey(name: 'first_name')
  final String? firstName;

  @JsonKey(name: 'last_name')
  final String? lastName;

  factory RegisterResponseDto.fromJson(Map<String, dynamic> json) =>
      _$RegisterResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterResponseDtoToJson(this);
}
