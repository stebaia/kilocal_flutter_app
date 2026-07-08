// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diary_goal_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DiaryGoalsResponseDto _$DiaryGoalsResponseDtoFromJson(
  Map<String, dynamic> json,
) => DiaryGoalsResponseDto(
  data:
      (json['data'] as List<dynamic>?)
          ?.map((e) => DiaryGoalDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

DiaryGoalDto _$DiaryGoalDtoFromJson(Map<String, dynamic> json) => DiaryGoalDto(
  id: DiaryGoalDto._idToString(json['id']),
  content: json['content'] as String?,
  dueDate: json['due_date'] as String?,
  completedAt: json['completed_at'] as String?,
  category: DiaryGoalDto._refToString(json['category']),
  relatedGoal: DiaryGoalDto._refToString(json['related_goal']),
);
