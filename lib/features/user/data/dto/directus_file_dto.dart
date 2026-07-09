import 'package:json_annotation/json_annotation.dart';

part 'directus_file_dto.g.dart';

/// Response wrapper of `POST /files` (Directus core upload).
///
/// The created file object is nested under a top-level `data` key; only its
/// `id` is needed to reference the file (e.g. as `directus_users.avatar`).
@JsonSerializable()
class DirectusFileResponseDto {
  const DirectusFileResponseDto({required this.data});

  final DirectusFileDto data;

  factory DirectusFileResponseDto.fromJson(Map<String, dynamic> json) =>
      _$DirectusFileResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$DirectusFileResponseDtoToJson(this);
}

@JsonSerializable()
class DirectusFileDto {
  const DirectusFileDto({required this.id});

  /// UUID of the uploaded file, served at `/assets/{id}`.
  final String id;

  factory DirectusFileDto.fromJson(Map<String, dynamic> json) =>
      _$DirectusFileDtoFromJson(json);

  Map<String, dynamic> toJson() => _$DirectusFileDtoToJson(this);
}
