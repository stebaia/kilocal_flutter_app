import 'package:equatable/equatable.dart';

/// A user-created reminder shown in the Promemoria tool.
///
/// Each reminder is a free-text [message] scheduled at a specific [dateTime].
/// Reminders are stored on the backend (`/tools/reminders`, see
/// `PromemoriaRepository`); a best-effort local OS notification is scheduled on
/// top of each future reminder.
class PromemoriaReminder extends Equatable {
  const PromemoriaReminder({
    required this.id,
    required this.message,
    required this.dateTime,
    this.completedAt,
  });

  /// Server id (`user_reminders.id`, a uuid). Also hashed into a stable int for
  /// the local-notification id.
  final String id;
  final String message;
  final DateTime dateTime;

  /// When the reminder was marked done, if ever (backend `completed_at`).
  final DateTime? completedAt;

  /// The calendar day this reminder falls on (time stripped), used to group
  /// reminders by day in the list/calendar views.
  DateTime get day => DateTime(dateTime.year, dateTime.month, dateTime.day);

  /// Deterministic 31-bit int derived from the uuid [id], used as the OS
  /// local-notification id (which must be an int).
  int get notificationId => id.hashCode & 0x7fffffff;

  PromemoriaReminder copyWith({
    String? id,
    String? message,
    DateTime? dateTime,
    DateTime? completedAt,
  }) {
    return PromemoriaReminder(
      id: id ?? this.id,
      message: message ?? this.message,
      dateTime: dateTime ?? this.dateTime,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  List<Object?> get props => [id, message, dateTime, completedAt];
}

/// Input for creating a new reminder (before an id is assigned).
class PromemoriaInput extends Equatable {
  const PromemoriaInput({required this.message, required this.dateTime});

  final String message;
  final DateTime dateTime;

  @override
  List<Object?> get props => [message, dateTime];
}
