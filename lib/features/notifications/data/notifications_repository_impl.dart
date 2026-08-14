import 'package:dio/dio.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/graphql_client.dart';
import '../../../core/utils/cms_image_url.dart';
import '../domain/entities/notification_item.dart';
import '../domain/notifications_repository.dart';
import 'dto/notification_dto.dart';

/// GraphQL-backed implementation of [NotificationsRepository].
class NotificationsRepositoryImpl implements NotificationsRepository {
  NotificationsRepositoryImpl({required GraphqlClient graphqlClient})
    : _graphqlClient = graphqlClient;

  final GraphqlClient _graphqlClient;

  String _buildQuery({required bool archived}) {
    final archiveFilter = archived ? '_nnull: true' : '_null: true';
    // Backend requires filtering out e-mails and incomplete jobs, otherwise the
    // feed leaks non-web_app notifications and unfinished ones.
    //
    // Everything the UI needs (title, body, CTA, asset) is read from the
    // `job_payload` JSON column: it is already compiled with the notification's
    // variables and, unlike the `notification` relation, it is readable with the
    // user's own permissions. Selecting `notification { translations ... }`
    // fails a GraphQL validation error for end users, since the restricted
    // schema degrades those relations to opaque scalars.
    return '''
query UserNotifications(\$myId: ID!) {
  user_notifications(
    filter: {
      user: { id: { _eq: \$myId } }
      archived_on: { $archiveFilter }
      job_status: { _eq: "completed" }
      job_channel: { _eq: "web_app" }
    }
    sort: ["-created_on"]
  ) {
    id
    read_on
    archived_on
    created_on
    notification_event
    job_payload
  }
}
''';
  }

  static const _archiveMutation = r'''
mutation ArchiveUserNotification($id: ID!, $now: Date!) {
  update_user_notifications_item(id: $id, data: { archived_on: $now }) {
    id
  }
}
''';

  static const _markReadMutation = r'''
mutation MarkReadUserNotification($id: ID!, $now: Date!) {
  update_user_notifications_item(id: $id, data: { read_on: $now }) {
    id
  }
}
''';

  @override
  Future<List<NotificationItem>> fetchNotifications({
    required String myId,
    bool archived = false,
  }) async {
    try {
      final query = _buildQuery(archived: archived);
      final result = await _graphqlClient.query(
        query,
        variables: {'myId': myId},
      );

      final data = result['data'] as Map<String, dynamic>?;
      final rawNotifications = data?['user_notifications'] as List<dynamic>?;

      return rawNotifications?.map((json) {
            final dto = NotificationDto.fromJson(json as Map<String, dynamic>);
            return _mapDto(dto);
          }).toList() ??
          const [];
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  @override
  Future<void> archive(String id) async {
    await _update(_archiveMutation, id);
  }

  @override
  Future<void> markRead(String id) async {
    await _update(_markReadMutation, id);
  }

  Future<void> _update(String mutation, String id) async {
    try {
      final now = DateTime.now().toUtc().toIso8601String();
      await _graphqlClient.query(mutation, variables: {'id': id, 'now': now});
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  NotificationItem _mapDto(NotificationDto dto) {
    // The whole notification content lives inside the server-compiled
    // `job_payload` JSON (title, body HTML, CTA, asset), all with variables
    // already substituted.
    final imageUrl = cmsImageUrl(
      dto.jobPayloadAssetId,
      size: CmsImageSize.card,
    );

    final ctas = <NotificationCta>[];
    final ctaUrl = dto.jobPayloadCtaUrl;
    if (ctaUrl != null && ctaUrl.isNotEmpty) {
      ctas.add(
        NotificationCta(label: dto.jobPayloadCtaLabel ?? '', url: ctaUrl),
      );
    }

    final NotificationType type;
    if (ctas.isNotEmpty) {
      type = NotificationType.withCta;
    } else if (imageUrl != null) {
      type = NotificationType.withImage;
    } else {
      type = NotificationType.plain;
    }

    return NotificationItem(
      id: dto.id,
      title: dto.jobPayloadTitle ?? dto.jobPayloadSubject ?? '',
      body: dto.jobPayloadHtml ?? '',
      timestamp: dto.createdOn,
      type: type,
      category: dto.notificationEvent,
      imageUrl: imageUrl,
      ctas: ctas,
      archived: dto.archivedOn != null,
      read: dto.readOn != null,
    );
  }
}
