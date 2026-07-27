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
    this.vimeoUrl,
  });

  final String? title;

  @JsonKey(name: 'image_file_id')
  final String? imageFileId;

  @JsonKey(name: 'image_file_name')
  final String? imageFileName;

  @JsonKey(name: 'cta_label')
  final String? ctaLabel;

  /// Fallback when the step's CMS asset has no `default_asset`/`mobile_asset`
  /// (true for 156/157 `percorsi_content` rows, confirmed by backend) — the
  /// Vimeo oEmbed poster is used instead. See [[home-continue-path-image-gap]].
  @JsonKey(name: 'vimeo_url')
  final String? vimeoUrl;

  factory HomeContinueStepDto.fromJson(Map<String, dynamic> json) =>
      _$HomeContinueStepDtoFromJson(json);

  Map<String, dynamic> toJson() => _$HomeContinueStepDtoToJson(this);
}
