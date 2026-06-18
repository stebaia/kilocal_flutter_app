import 'package:json_annotation/json_annotation.dart';

part 'home_month_progress_dto.g.dart';

/// DTO for the month progress computation.
@JsonSerializable()
class HomeMonthProgressDto {
  const HomeMonthProgressDto({this.total, this.completed});

  final int? total;
  final int? completed;

  factory HomeMonthProgressDto.fromJson(Map<String, dynamic> json) =>
      _$HomeMonthProgressDtoFromJson(json);

  Map<String, dynamic> toJson() => _$HomeMonthProgressDtoToJson(this);
}
