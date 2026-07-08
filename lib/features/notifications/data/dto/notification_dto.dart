import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'notification_dto.g.dart';

/// GraphQL `ID` scalars come across as strings, but Directus can also send a
/// numeric primary key. Accept both.
String _idFromJson(dynamic value) => value.toString();

/// Directus can return a JSON column either as a decoded map or as a raw
/// JSON-encoded string. Normalise both into a `Map`.
Map<String, dynamic>? _jobPayloadFromJson(dynamic value) {
  if (value == null) return null;
  if (value is Map<String, dynamic>) return value;
  if (value is String) {
    if (value.isEmpty) return null;
    final decoded = jsonDecode(value);
    return decoded is Map<String, dynamic> ? decoded : null;
  }
  return null;
}

@JsonSerializable(fieldRename: FieldRename.snake)
class NotificationDto {
  const NotificationDto({
    required this.id,
    this.readOn,
    this.archivedOn,
    required this.createdOn,
    this.notificationEvent,
    this.jobPayload,
  });

  factory NotificationDto.fromJson(Map<String, dynamic> json) =>
      _$NotificationDtoFromJson(json);

  @JsonKey(fromJson: _idFromJson)
  final String id;
  final DateTime? readOn;
  final DateTime? archivedOn;
  final DateTime createdOn;
  final String? notificationEvent;

  /// Directus JSON column holding the whole compiled notification. Unlike the
  /// `notification` relation, this is readable with the user's own permissions
  /// and already has every template variable substituted.
  @JsonKey(fromJson: _jobPayloadFromJson)
  final Map<String, dynamic>? jobPayload;

  /// Server-rendered HTML body, with all template variables substituted.
  String? get jobPayloadHtml => jobPayload?['html'] as String?;

  /// Asset (image) id, when present. Directus returns it as the bare file id.
  String? get jobPayloadAssetId => jobPayload?['asset'] as String?;

  Map<String, dynamic>? get _cta =>
      jobPayload?['cta'] as Map<String, dynamic>?;

  /// CTA url. The `{{publicUrl}}` placeholder is not always compiled in this
  /// field, so resolve it from the payload's own `publicUrl`.
  String? get jobPayloadCtaUrl {
    final url = _cta?['url'] as String?;
    if (url == null) return null;
    final publicUrl = jobPayload?['publicUrl'] as String?;
    if (publicUrl == null) return url;
    return url.replaceAll('{{publicUrl}}', publicUrl);
  }

  String? get jobPayloadCtaLabel => _cta?['label'] as String?;

  Map<String, dynamic>? get _translations =>
      jobPayload?['translations'] as Map<String, dynamic>?;

  String? get jobPayloadTitle => _translations?['title'] as String?;

  String? get jobPayloadSubject => _translations?['subject'] as String?;

  Map<String, dynamic> toJson() => _$NotificationDtoToJson(this);
}
