import 'package:json_annotation/json_annotation.dart';

part 'benefit_dto.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class BenefitDto {
  const BenefitDto({
    required this.id,
    this.name,
    this.coupon,
    this.mainPartner,
    this.asset,
    this.logo,
    this.ctaBrand,
    this.translations = const [],
  });

  factory BenefitDto.fromJson(Map<String, dynamic> json) =>
      _$BenefitDtoFromJson(json);

  final String id;
  final String? name;
  final String? coupon;
  final bool? mainPartner;
  final BenefitFileDto? asset;
  final BenefitFileDto? logo;
  final BenefitCtaDto? ctaBrand;
  final List<BenefitTranslationDto> translations;

  Map<String, dynamic> toJson() => _$BenefitDtoToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class BenefitFileDto {
  const BenefitFileDto({this.id, this.filenameDownload});

  factory BenefitFileDto.fromJson(Map<String, dynamic> json) =>
      _$BenefitFileDtoFromJson(json);

  final String? id;
  final String? filenameDownload;

  Map<String, dynamic> toJson() => _$BenefitFileDtoToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class BenefitCtaDto {
  const BenefitCtaDto({this.id, this.translations = const []});

  factory BenefitCtaDto.fromJson(Map<String, dynamic> json) =>
      _$BenefitCtaDtoFromJson(json);

  final String? id;

  /// In the `links` type the url/label live on the translation, not the root.
  final List<BenefitCtaTranslationDto> translations;

  Map<String, dynamic> toJson() => _$BenefitCtaDtoToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class BenefitCtaTranslationDto {
  const BenefitCtaTranslationDto({this.url, this.label});

  factory BenefitCtaTranslationDto.fromJson(Map<String, dynamic> json) =>
      _$BenefitCtaTranslationDtoFromJson(json);

  final String? url;
  final String? label;

  Map<String, dynamic> toJson() => _$BenefitCtaTranslationDtoToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class BenefitTranslationDto {
  const BenefitTranslationDto({this.description, this.couponInstructions});

  factory BenefitTranslationDto.fromJson(Map<String, dynamic> json) =>
      _$BenefitTranslationDtoFromJson(json);

  final String? description;
  final String? couponInstructions;

  Map<String, dynamic> toJson() => _$BenefitTranslationDtoToJson(this);
}
