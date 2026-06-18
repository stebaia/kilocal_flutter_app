// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_month_progress_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HomeMonthProgressDto _$HomeMonthProgressDtoFromJson(
  Map<String, dynamic> json,
) => HomeMonthProgressDto(
  total: (json['total'] as num?)?.toInt(),
  completed: (json['completed'] as num?)?.toInt(),
);

Map<String, dynamic> _$HomeMonthProgressDtoToJson(
  HomeMonthProgressDto instance,
) => <String, dynamic>{
  'total': instance.total,
  'completed': instance.completed,
};
