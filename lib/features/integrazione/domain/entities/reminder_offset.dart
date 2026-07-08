/// The snooze offsets a user can pick for a supplement reminder.
///
/// Reminders are one-shot local notifications scheduled at `now + duration`
/// ("Posticipa di 2 ore", "Posticipa di 1 giorno"), matching the design.
enum ReminderOffset {
  hours2(Duration(hours: 2)),
  hours4(Duration(hours: 4)),
  hours8(Duration(hours: 8)),
  day1(Duration(days: 1));

  const ReminderOffset(this.duration);

  final Duration duration;

  /// Stable key persisted in the notification payload so an active reminder can
  /// be reconstructed from `pendingNotificationRequests`.
  String get key => name;

  static ReminderOffset? fromKey(String? key) {
    for (final o in ReminderOffset.values) {
      if (o.key == key) return o;
    }
    return null;
  }
}

/// A currently-scheduled reminder for a product: the chosen [offset] and the
/// absolute [scheduledAt] time it will fire.
class ActiveReminder {
  const ActiveReminder({required this.offset, required this.scheduledAt});

  final ReminderOffset offset;
  final DateTime scheduledAt;
}
