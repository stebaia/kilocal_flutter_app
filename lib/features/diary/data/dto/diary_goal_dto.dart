import 'package:json_annotation/json_annotation.dart';

part 'diary_goal_dto.g.dart';

/// Response wrapper for `GET /journal/goals` → `{ "data": [ ... ] }`.
@JsonSerializable(createToJson: false)
class DiaryGoalsResponseDto {
  const DiaryGoalsResponseDto({this.data = const []});

  factory DiaryGoalsResponseDto.fromJson(Map<String, dynamic> json) =>
      _$DiaryGoalsResponseDtoFromJson(json);

  final List<DiaryGoalDto> data;
}

/// A `UserGoal` (extends `UserReminder`). `category`/`related_goal` can be an
/// integer or a string in the spec, so they are read as raw strings.
@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class DiaryGoalDto {
  const DiaryGoalDto({
    required this.id,
    this.content,
    this.dueDate,
    this.completedAt,
    this.category,
    this.relatedGoal,
  });

  factory DiaryGoalDto.fromJson(Map<String, dynamic> json) =>
      _$DiaryGoalDtoFromJson(json);

  @JsonKey(fromJson: _idToString)
  final String id;
  final String? content;
  final String? dueDate;
  final String? completedAt;

  @JsonKey(fromJson: _refToString)
  final String? category;

  @JsonKey(fromJson: _refToString)
  final String? relatedGoal;

  static String? _refToString(Object? value) => value?.toString();
  static String _idToString(Object? value) => value?.toString() ?? '';
}
