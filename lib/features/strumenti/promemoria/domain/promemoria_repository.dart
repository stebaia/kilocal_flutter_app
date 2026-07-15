import 'entities/promemoria_reminder.dart';

/// Source of truth for the user's calendar reminders (backend
/// `/tools/reminders`), with a best-effort local notification per reminder.
abstract class PromemoriaRepository {
  /// All reminders for the current user, sorted by date/time ascending.
  Future<List<PromemoriaReminder>> getAll();

  /// Creates a reminder on the backend, schedules its local notification, and
  /// returns the refreshed list (the POST response carries only the new id).
  Future<List<PromemoriaReminder>> add(PromemoriaInput input);

  /// Updates the [reminder] with [input] on the backend, reschedules its local
  /// notification, and returns the refreshed list.
  Future<List<PromemoriaReminder>> update(
    PromemoriaReminder reminder,
    PromemoriaInput input,
  );

  /// Deletes the reminder [id] and cancels its local notification.
  Future<void> delete(PromemoriaReminder reminder);
}
