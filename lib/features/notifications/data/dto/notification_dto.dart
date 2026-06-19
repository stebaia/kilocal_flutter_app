import 'package:json_annotation/json_annotation.dart';

part 'notification_dto.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class NotificationDto {
  const NotificationDto({
    required this.id,
    this.readOn,
    this.archivedOn,
    required this.createdOn,
    this.notificationEvent,
    this.notification,
  });

  factory NotificationDto.fromJson(Map<String, dynamic> json) =>
      _$NotificationDtoFromJson(json);

  final int id;
  final DateTime? readOn;
  final DateTime? archivedOn;
  final DateTime createdOn;
  final String? notificationEvent;
  final NotificationConfigDto? notification;

  Map<String, dynamic> toJson() => _$NotificationDtoToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class NotificationConfigDto {
  const NotificationConfigDto({
    this.asset,
    this.translations = const [],
    this.cta,
  });

  factory NotificationConfigDto.fromJson(Map<String, dynamic> json) =>
      _$NotificationConfigDtoFromJson(json);

  final NotificationAssetDto? asset;
  final List<NotificationTranslationDto> translations;
  final NotificationCtaDto? cta;

  Map<String, dynamic> toJson() => _$NotificationConfigDtoToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class NotificationAssetDto {
  const NotificationAssetDto({this.id, this.filenameDownload});

  factory NotificationAssetDto.fromJson(Map<String, dynamic> json) =>
      _$NotificationAssetDtoFromJson(json);

  final String? id;
  final String? filenameDownload;

  Map<String, dynamic> toJson() => _$NotificationAssetDtoToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class NotificationTranslationDto {
  const NotificationTranslationDto({this.title, this.subject, this.content});

  factory NotificationTranslationDto.fromJson(Map<String, dynamic> json) =>
      _$NotificationTranslationDtoFromJson(json);

  final String? title;
  final String? subject;
  final String? content;

  Map<String, dynamic> toJson() => _$NotificationTranslationDtoToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class NotificationCtaDto {
  const NotificationCtaDto({this.translations = const []});

  factory NotificationCtaDto.fromJson(Map<String, dynamic> json) =>
      _$NotificationCtaDtoFromJson(json);

  final List<NotificationCtaTranslationDto> translations;

  Map<String, dynamic> toJson() => _$NotificationCtaDtoToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class NotificationCtaTranslationDto {
  const NotificationCtaTranslationDto({this.label, this.url});

  factory NotificationCtaTranslationDto.fromJson(Map<String, dynamic> json) =>
      _$NotificationCtaTranslationDtoFromJson(json);

  final String? label;
  final String? url;

  Map<String, dynamic> toJson() => _$NotificationCtaTranslationDtoToJson(this);
}
