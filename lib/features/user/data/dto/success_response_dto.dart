import 'package:json_annotation/json_annotation.dart';

part 'success_response_dto.g.dart';

/// Generic `{ "success": true }` response returned by write endpoints such as
/// `PATCH /profile`.
@JsonSerializable()
class SuccessResponseDto {
  const SuccessResponseDto({this.success = false});

  final bool success;

  factory SuccessResponseDto.fromJson(Map<String, dynamic> json) =>
      _$SuccessResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SuccessResponseDtoToJson(this);
}
