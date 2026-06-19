enum NotificationType { plain, withImage, withCta }

/// A call-to-action attached to a notification.
class NotificationCta {
  const NotificationCta({required this.label, required this.url});

  final String label;
  final String url;
}

class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    this.type = NotificationType.plain,
    this.category,
    this.imageUrl,
    this.ctas = const [],
    this.archived = false,
    this.read = false,
  });

  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final NotificationType type;
  final String? category;
  final String? imageUrl;
  final List<NotificationCta> ctas;
  final bool archived;
  final bool read;

  NotificationItem copyWith({bool? archived, bool? read}) {
    return NotificationItem(
      id: id,
      title: title,
      body: body,
      timestamp: timestamp,
      type: type,
      category: category,
      imageUrl: imageUrl,
      ctas: ctas,
      archived: archived ?? this.archived,
      read: read ?? this.read,
    );
  }
}
