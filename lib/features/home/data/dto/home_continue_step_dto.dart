import 'package:json_annotation/json_annotation.dart';

part 'home_continue_step_dto.g.dart';

/// DTO for the "Continua il percorso" card data.
@JsonSerializable()
class HomeContinueStepDto {
  const HomeContinueStepDto({
    this.title,
    this.imageFileId,
    this.imageFileName,
    this.ctaLabel,
  });

  final String? title;

  @JsonKey(name: 'image_file_id')
  final String? imageFileId;

  @JsonKey(name: 'image_file_name')
  final String? imageFileName;

  @JsonKey(name: 'cta_label')
  final String? ctaLabel;

  factory HomeContinueStepDto.fromJson(Map<String, dynamic> json) =>
      _$HomeContinueStepDtoFromJson(json);

  Map<String, dynamic> toJson() => _$HomeContinueStepDtoToJson(this);
}
