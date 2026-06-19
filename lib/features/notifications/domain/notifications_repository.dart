import 'entities/notification_item.dart';

/// Repository for the authenticated user's notification inbox.
abstract class NotificationsRepository {
  /// Fetches notifications for the given user, newest first, with localized
  /// text. Pass [archived] `true` to fetch only archived items.
  Future<List<NotificationItem>> fetchNotifications({
    required String myId,
    bool archived = false,
  });

  /// Soft-deletes a notification by setting [archived_on] to now.
  Future<void> archive(String id);

  /// Marks a notification as read by setting [read_on] to now.
  Future<void> markRead(String id);
}
