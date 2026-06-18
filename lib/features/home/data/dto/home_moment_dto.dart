import 'package:json_annotation/json_annotation.dart';

part 'home_moment_dto.g.dart';

/// DTO for a Momenti hero card shown on the home screen.
@JsonSerializable()
class HomeMomentDto {
  const HomeMomentDto({
    this.id,
    this.title,
    this.imageFileId,
    this.imageFileName,
  });

  final String? id;
  final String? title;

  @JsonKey(name: 'image_file_id')
  final String? imageFileId;

  @JsonKey(name: 'image_file_name')
  final String? imageFileName;

  factory HomeMomentDto.fromJson(Map<String, dynamic> json) =>
      _$HomeMomentDtoFromJson(json);

  Map<String, dynamic> toJson() => _$HomeMomentDtoToJson(this);
}
