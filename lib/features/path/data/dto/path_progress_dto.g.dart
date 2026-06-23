// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'path_progress_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PathProgressResponseDto _$PathProgressResponseDtoFromJson(
  Map<String, dynamic> json,
) => PathProgressResponseDto(
  data: PathProgressDto.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PathProgressResponseDtoToJson(
  PathProgressResponseDto instance,
) => <String, dynamic>{'data': instance.data};

PathProgressDto _$PathProgressDtoFromJson(Map<String, dynamic> json) =>
    PathProgressDto(
      overall: AreaProgressDto.fromJson(
        json['overall'] as Map<String, dynamic>,
      ),
      areas: (json['areas'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry(k, AreaProgressDto.fromJson(e as Map<String, dynamic>)),
      ),
    );

Map<String, dynamic> _$PathProgressDtoToJson(PathProgressDto instance) =>
    <String, dynamic>{'overall': instance.overall, 'areas': instance.areas};

AreaProgressDto _$AreaProgressDtoFromJson(Map<String, dynamic> json) =>
    AreaProgressDto(
      completed: (json['completed'] as num?)?.toInt() ?? 0,
      total: (json['total'] as num?)?.toInt() ?? 0,
      percent: (json['percent'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$AreaProgressDtoToJson(AreaProgressDto instance) =>
    <String, dynamic>{
      'completed': instance.completed,
      'total': instance.total,
      'percent': instance.percent,
    };
