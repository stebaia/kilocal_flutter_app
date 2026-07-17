import 'package:json_annotation/json_annotation.dart';

part 'moment_dto.g.dart';

/// DTO for the `moments` GraphQL collection.
@JsonSerializable()
class MomentDto {
  const MomentDto({required this.id, this.translations = const [], this.asset});

  factory MomentDto.fromJson(Map<String, dynamic> json) =>
      _$MomentDtoFromJson(json);

  final String id;
  final List<MomentTranslationDto> translations;
  final MomentAssetDto? asset;

  Map<String, dynamic> toJson() => _$MomentDtoToJson(this);
}

@JsonSerializable()
class MomentTranslationDto {
  const MomentTranslationDto({this.title, this.description, this.plot});

  factory MomentTranslationDto.fromJson(Map<String, dynamic> json) =>
      _$MomentTranslationDtoFromJson(json);

  final String? title;
  final String? description;

  /// Short plain-text abstract of the moment, shown in the info sheet.
  final String? plot;

  Map<String, dynamic> toJson() => _$MomentTranslationDtoToJson(this);
}

@JsonSerializable()
class MomentAssetDto {
  const MomentAssetDto({this.defaultAsset});

  factory MomentAssetDto.fromJson(Map<String, dynamic> json) =>
      _$MomentAssetDtoFromJson(json);

  @JsonKey(name: 'default_asset')
  final MomentFileDto? defaultAsset;

  Map<String, dynamic> toJson() => _$MomentAssetDtoToJson(this);
}

@JsonSerializable()
class MomentFileDto {
  const MomentFileDto({this.id, this.filenameDownload});

  factory MomentFileDto.fromJson(Map<String, dynamic> json) =>
      _$MomentFileDtoFromJson(json);

  final String? id;

  @JsonKey(name: 'filename_download')
  final String? filenameDownload;

  Map<String, dynamic> toJson() => _$MomentFileDtoToJson(this);
}
