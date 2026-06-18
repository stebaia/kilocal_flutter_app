import 'package:json_annotation/json_annotation.dart';

part 'home_partner_dto.g.dart';

/// DTO for a Benefit / partner card shown on the home screen.
@JsonSerializable()
class HomePartnerDto {
  const HomePartnerDto({
    this.id,
    this.name,
    this.imageFileId,
    this.imageFileName,
    this.mainPartner,
  });

  final String? id;
  final String? name;

  @JsonKey(name: 'image_file_id')
  final String? imageFileId;

  @JsonKey(name: 'image_file_name')
  final String? imageFileName;

  @JsonKey(name: 'main_partner')
  final bool? mainPartner;

  factory HomePartnerDto.fromJson(Map<String, dynamic> json) =>
      _$HomePartnerDtoFromJson(json);

  Map<String, dynamic> toJson() => _$HomePartnerDtoToJson(this);
}
