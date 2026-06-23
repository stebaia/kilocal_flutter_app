import 'package:json_annotation/json_annotation.dart';

part 'path_progress_dto.g.dart';

/// Response of `GET /path/me/progress`.
///
/// The backend returns the already-computed progress for the whole path and for
/// each area, keyed by the area `root.internal_name`
/// (`allenamento` / `alimentazione` / `benessere` / `integrazione`). All four
/// areas are always present, even when `total` is `0` (e.g. integrazione for a
/// user without a kit).
@JsonSerializable()
class PathProgressResponseDto {
  const PathProgressResponseDto({required this.data});

  factory PathProgressResponseDto.fromJson(Map<String, dynamic> json) =>
      _$PathProgressResponseDtoFromJson(json);

  final PathProgressDto data;

  Map<String, dynamic> toJson() => _$PathProgressResponseDtoToJson(this);
}

@JsonSerializable()
class PathProgressDto {
  const PathProgressDto({required this.overall, required this.areas});

  factory PathProgressDto.fromJson(Map<String, dynamic> json) =>
      _$PathProgressDtoFromJson(json);

  final AreaProgressDto overall;

  /// Keyed by `root.internal_name`.
  final Map<String, AreaProgressDto> areas;

  Map<String, dynamic> toJson() => _$PathProgressDtoToJson(this);
}

@JsonSerializable()
class AreaProgressDto {
  const AreaProgressDto({this.completed = 0, this.total = 0, this.percent = 0});

  factory AreaProgressDto.fromJson(Map<String, dynamic> json) =>
      _$AreaProgressDtoFromJson(json);

  final int completed;
  final int total;

  /// Integer 0-100. Redundant (client can recompute from completed/total) but
  /// kept to avoid UI rounding discrepancies.
  final int percent;

  Map<String, dynamic> toJson() => _$AreaProgressDtoToJson(this);
}
