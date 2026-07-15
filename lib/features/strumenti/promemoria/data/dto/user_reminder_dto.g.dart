// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_reminder_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserReminderDto _$UserReminderDtoFromJson(Map<String, dynamic> json) =>
    UserReminderDto(
      id: _idFromJson(json['id']),
      content: json['content'] as String?,
      dueDate: json['due_date'] as String?,
      dueTime: json['due_time'] as String?,
      completedAt: json['completed_at'] as String?,
      redirectTo: json['redirectTo'] as String?,
    );

Map<String, dynamic> _$UserReminderDtoToJson(UserReminderDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'content': instance.content,
      'due_date': instance.dueDate,
      'due_time': instance.dueTime,
      'completed_at': instance.completedAt,
      'redirectTo': instance.redirectTo,
    };

UserRemindersResponseDto _$UserRemindersResponseDtoFromJson(
  Map<String, dynamic> json,
) => UserRemindersResponseDto(
  data:
      (json['data'] as List<dynamic>?)
          ?.map((e) => UserReminderDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);
