import 'package:dio/dio.dart';

import '../../../core/config/env.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/graphql_client.dart';
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
    return '''
query UserNotifications(\$myId: ID!, \$lang: String!) {
  user_notifications(
    filter: { user: { id: { _eq: \$myId } }, archived_on: { $archiveFilter } }
    sort: ["-created_on"]
  ) {
    id
    read_on
    archived_on
    created_on
    notification_event
    notification {
      asset {
        id
        filename_download
      }
      translations(filter: { languages_code: { code: { _eq: \$lang } } }) {
        title
        subject
        content
      }
      cta {
        translations(filter: { languages_code: { code: { _eq: \$lang } } }) {
          label
          url
        }
      }
    }
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
        variables: {'myId': myId, 'lang': _resolveLocale()},
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
    final notification = dto.notification;
    final translation = notification?.translations.firstOrNull;
    final asset = notification?.asset;

    final imageUrl = asset?.id != null && asset?.filenameDownload != null
        ? '${Env.baseUrl}/assets/${asset!.id}/${asset.filenameDownload}'
        : null;

    final ctaTranslation = notification?.cta?.translations.firstOrNull;
    final ctas = <NotificationCta>[];
    if (ctaTranslation?.url != null && ctaTranslation!.url!.isNotEmpty) {
      ctas.add(
        NotificationCta(
          label: ctaTranslation.label ?? '',
          url: ctaTranslation.url!,
        ),
      );
    }

    final NotificationType type;
    if (ctas.isNotEmpty && imageUrl != null) {
      type = NotificationType.withCta;
    } else if (ctas.isNotEmpty) {
      type = NotificationType.withCta;
    } else if (imageUrl != null) {
      type = NotificationType.withImage;
    } else {
      type = NotificationType.plain;
    }

    return NotificationItem(
      id: dto.id.toString(),
      title: translation?.title ?? translation?.subject ?? '',
      body: translation?.content ?? '',
      timestamp: dto.createdOn,
      type: type,
      category: dto.notificationEvent,
      imageUrl: imageUrl,
      ctas: ctas,
      archived: dto.archivedOn != null,
      read: dto.readOn != null,
    );
  }

  String _resolveLocale() {
    // The CMS uses codes like "it-IT" / "en-US". Default to Italian for now.
    return 'it-IT';
  }
}
