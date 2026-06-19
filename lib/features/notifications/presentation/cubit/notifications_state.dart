part of 'notifications_cubit.dart';

enum NotificationsStatus { initial, loading, loaded, error }

enum NotificationFilter { all, unread, read, archived }

class NotificationsState extends Equatable {
  const NotificationsState({
    this.status = NotificationsStatus.initial,
    this.items = const [],
    this.filter = NotificationFilter.all,
    this.error,
  });

  final NotificationsStatus status;
  final List<NotificationItem> items;
  final NotificationFilter filter;
  final ApiException? error;

  NotificationsState copyWith({
    NotificationsStatus? status,
    List<NotificationItem>? items,
    NotificationFilter? filter,
    ApiException? error,
  }) {
    return NotificationsState(
      status: status ?? this.status,
      items: items ?? this.items,
      filter: filter ?? this.filter,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, items, filter, error];
}
