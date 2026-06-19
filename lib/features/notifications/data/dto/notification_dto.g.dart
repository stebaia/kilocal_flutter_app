// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationDto _$NotificationDtoFromJson(Map<String, dynamic> json) =>
    NotificationDto(
      id: (json['id'] as num).toInt(),
      readOn: json['read_on'] == null
          ? null
          : DateTime.parse(json['read_on'] as String),
      archivedOn: json['archived_on'] == null
          ? null
          : DateTime.parse(json['archived_on'] as String),
      createdOn: DateTime.parse(json['created_on'] as String),
      notificationEvent: json['notification_event'] as String?,
      notification: json['notification'] == null
          ? null
          : NotificationConfigDto.fromJson(
              json['notification'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$NotificationDtoToJson(NotificationDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'read_on': instance.readOn?.toIso8601String(),
      'archived_on': instance.archivedOn?.toIso8601String(),
      'created_on': instance.createdOn.toIso8601String(),
      'notification_event': instance.notificationEvent,
      'notification': instance.notification,
    };

NotificationConfigDto _$NotificationConfigDtoFromJson(
  Map<String, dynamic> json,
) => NotificationConfigDto(
  asset: json['asset'] == null
      ? null
      : NotificationAssetDto.fromJson(json['asset'] as Map<String, dynamic>),
  translations:
      (json['translations'] as List<dynamic>?)
          ?.map(
            (e) =>
                NotificationTranslationDto.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
  cta: json['cta'] == null
      ? null
      : NotificationCtaDto.fromJson(json['cta'] as Map<String, dynamic>),
);

Map<String, dynamic> _$NotificationConfigDtoToJson(
  NotificationConfigDto instance,
) => <String, dynamic>{
  'asset': instance.asset,
  'translations': instance.translations,
  'cta': instance.cta,
};

NotificationAssetDto _$NotificationAssetDtoFromJson(
  Map<String, dynamic> json,
) => NotificationAssetDto(
  id: json['id'] as String?,
  filenameDownload: json['filename_download'] as String?,
);

Map<String, dynamic> _$NotificationAssetDtoToJson(
  NotificationAssetDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'filename_download': instance.filenameDownload,
};

NotificationTranslationDto _$NotificationTranslationDtoFromJson(
  Map<String, dynamic> json,
) => NotificationTranslationDto(
  title: json['title'] as String?,
  subject: json['subject'] as String?,
  content: json['content'] as String?,
);

Map<String, dynamic> _$NotificationTranslationDtoToJson(
  NotificationTranslationDto instance,
) => <String, dynamic>{
  'title': instance.title,
  'subject': instance.subject,
  'content': instance.content,
};

NotificationCtaDto _$NotificationCtaDtoFromJson(Map<String, dynamic> json) =>
    NotificationCtaDto(
      translations:
          (json['translations'] as List<dynamic>?)
              ?.map(
                (e) => NotificationCtaTranslationDto.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList() ??
          const [],
    );

Map<String, dynamic> _$NotificationCtaDtoToJson(NotificationCtaDto instance) =>
    <String, dynamic>{'translations': instance.translations};

NotificationCtaTranslationDto _$NotificationCtaTranslationDtoFromJson(
  Map<String, dynamic> json,
) => NotificationCtaTranslationDto(
  label: json['label'] as String?,
  url: json['url'] as String?,
);

Map<String, dynamic> _$NotificationCtaTranslationDtoToJson(
  NotificationCtaTranslationDto instance,
) => <String, dynamic>{'label': instance.label, 'url': instance.url};
