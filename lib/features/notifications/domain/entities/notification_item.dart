enum NotificationType { plain, withImage, withCta }

class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    this.type = NotificationType.plain,
    this.imageUrl,
    this.ctaLabel,
    this.archived = false,
  });

  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final NotificationType type;
  final String? imageUrl;
  final String? ctaLabel;
  final bool archived;

  NotificationItem copyWith({bool? archived}) {
    return NotificationItem(
      id: id,
      title: title,
      body: body,
      timestamp: timestamp,
      type: type,
      imageUrl: imageUrl,
      ctaLabel: ctaLabel,
      archived: archived ?? this.archived,
    );
  }
}