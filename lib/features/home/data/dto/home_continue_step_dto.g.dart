// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_continue_step_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HomeContinueStepDto _$HomeContinueStepDtoFromJson(Map<String, dynamic> json) =>
    HomeContinueStepDto(
      title: json['title'] as String?,
      imageFileId: json['image_file_id'] as String?,
      imageFileName: json['image_file_name'] as String?,
      ctaLabel: json['cta_label'] as String?,
      vimeoUrl: json['vimeo_url'] as String?,
      stepId: json['step_id'] as String?,
      area: json['area'] as String?,
    );

Map<String, dynamic> _$HomeContinueStepDtoToJson(
  HomeContinueStepDto instance,
) => <String, dynamic>{
  'title': instance.title,
  'image_file_id': instance.imageFileId,
  'image_file_name': instance.imageFileName,
  'cta_label': instance.ctaLabel,
  'vimeo_url': instance.vimeoUrl,
  'step_id': instance.stepId,
  'area': instance.area,
};
