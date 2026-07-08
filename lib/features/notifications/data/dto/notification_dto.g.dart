// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationDto _$NotificationDtoFromJson(Map<String, dynamic> json) =>
    NotificationDto(
      id: _idFromJson(json['id']),
      readOn: json['read_on'] == null
          ? null
          : DateTime.parse(json['read_on'] as String),
      archivedOn: json['archived_on'] == null
          ? null
          : DateTime.parse(json['archived_on'] as String),
      createdOn: DateTime.parse(json['created_on'] as String),
      notificationEvent: json['notification_event'] as String?,
      jobPayload: _jobPayloadFromJson(json['job_payload']),
    );

Map<String, dynamic> _$NotificationDtoToJson(NotificationDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'read_on': instance.readOn?.toIso8601String(),
      'archived_on': instance.archivedOn?.toIso8601String(),
      'created_on': instance.createdOn.toIso8601String(),
      'notification_event': instance.notificationEvent,
      'job_payload': instance.jobPayload,
    };
