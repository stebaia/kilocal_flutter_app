import 'package:json_annotation/json_annotation.dart';

part 'user_reminder_dto.g.dart';

/// The backend returns ids as either strings or ints; normalize to string.
String _idFromJson(Object? value) => value?.toString() ?? '';

/// DTO for a `user_reminders` row exposed by `GET/POST /tools/reminders`.
///
/// Calendar reminders have no `category`/`related_goal` (those are journal
/// goals). Time is split across [dueDate] (`YYYY-MM-DD`) and [dueTime]
/// (`HH:mm[:ss]`); both are nullable server-side.
@JsonSerializable()
class UserReminderDto {
  const UserReminderDto({
    required this.id,
    this.content,
    this.dueDate,
    this.dueTime,
    this.completedAt,
    this.redirectTo,
  });

  factory UserReminderDto.fromJson(Map<String, dynamic> json) =>
      _$UserReminderDtoFromJson(json);

  @JsonKey(fromJson: _idFromJson)
  final String id;

  final String? content;

  @JsonKey(name: 'due_date')
  final String? dueDate;

  @JsonKey(name: 'due_time')
  final String? dueTime;

  @JsonKey(name: 'completed_at')
  final String? completedAt;

  final String? redirectTo;

  Map<String, dynamic> toJson() => _$UserReminderDtoToJson(this);
}

/// Wrapper for `GET /tools/reminders` → `{ "data": [...] }`.
@JsonSerializable(createToJson: false)
class UserRemindersResponseDto {
  const UserRemindersResponseDto({this.data = const []});

  factory UserRemindersResponseDto.fromJson(Map<String, dynamic> json) =>
      _$UserRemindersResponseDtoFromJson(json);

  final List<UserReminderDto> data;
}
