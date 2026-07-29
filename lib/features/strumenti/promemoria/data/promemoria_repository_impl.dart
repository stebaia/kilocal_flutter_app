import 'package:dio/dio.dart';

import '../../../../core/network/api_exception.dart';
import '../domain/entities/promemoria_reminder.dart';
import '../domain/promemoria_repository.dart';
import 'dto/user_reminder_dto.dart';
import 'promemoria_api.dart';
import 'promemoria_notification_service.dart';

/// Backend-backed [PromemoriaRepository]: reads/writes calendar reminders via
/// [PromemoriaApi] and mirrors each future reminder as a local OS notification.
///
/// KNOWN BACKEND BUG (see wiki/strumenti.md): a single [add] can come back on a
/// later [getAll] as multiple rows — same content/time, one per future month on
/// the same day. Verified this repository sends exactly one `POST` per create
/// and [PromemoriaState.remindersInMonth] filters by year+month, not just day —
/// so the duplication happens server-side, not here.
class PromemoriaRepositoryImpl implements PromemoriaRepository {
  PromemoriaRepositoryImpl({
    required PromemoriaApi api,
    required PromemoriaNotificationService notifications,
  }) : _api = api,
       _notifications = notifications;

  final PromemoriaApi _api;
  final PromemoriaNotificationService _notifications;

  @override
  Future<List<PromemoriaReminder>> getAll() async {
    try {
      final response = await _api.list();
      final reminders =
          response.data.map(_toEntity).whereType<PromemoriaReminder>().toList()
            ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
      return reminders;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  @override
  Future<List<PromemoriaReminder>> add(PromemoriaInput input) async {
    try {
      // POST returns only `{ "data": <newId> }`, not the created row, so we
      // re-fetch the list to get the authoritative reminder (with its server
      // id) and schedule the notification on that.
      await _api.create({
        'content': input.message,
        'due_date': formatDate(input.dateTime),
        'due_time': formatTime(input.dateTime),
      });
      final reminders = await getAll();
      final created = reminders
          .where(
            (r) => r.message == input.message && r.dateTime == input.dateTime,
          )
          .lastOrNull;
      if (created != null) await _notifications.schedule(created);
      return reminders;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  @override
  Future<List<PromemoriaReminder>> update(
    PromemoriaReminder reminder,
    PromemoriaInput input,
  ) async {
    try {
      await _api.update(reminder.id, {
        'content': input.message,
        'due_date': formatDate(input.dateTime),
        'due_time': formatTime(input.dateTime),
      });
      // Cancel the old notification (its fire time/message may have changed)
      // and reschedule from the refreshed row.
      await _notifications.cancel(reminder.notificationId);
      final reminders = await getAll();
      final updated = reminders.where((r) => r.id == reminder.id).firstOrNull;
      if (updated != null) await _notifications.schedule(updated);
      return reminders;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  @override
  Future<void> delete(PromemoriaReminder reminder) async {
    try {
      await _api.delete(reminder.id);
      await _notifications.cancel(reminder.notificationId);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// Maps a DTO to an entity, combining `due_date` + `due_time`. Returns `null`
  /// for rows without a usable date (they can't be placed on the calendar).
  PromemoriaReminder? _toEntity(UserReminderDto dto) {
    final dateTime = parseDateTime(dto.dueDate, dto.dueTime);
    if (dateTime == null) return null;
    return PromemoriaReminder(
      id: dto.id,
      message: dto.content ?? '',
      dateTime: dateTime,
      completedAt: dto.completedAt == null
          ? null
          : DateTime.tryParse(dto.completedAt!),
    );
  }

  /// Combines a `YYYY-MM-DD` [date] and an optional `HH:mm[:ss]` [time] into a
  /// local [DateTime]. Missing time defaults to midnight.
  static DateTime? parseDateTime(String? date, String? time) {
    if (date == null || date.isEmpty) return null;
    final day = DateTime.tryParse(date);
    if (day == null) return null;
    var hour = 0;
    var minute = 0;
    if (time != null && time.isNotEmpty) {
      final parts = time.split(':');
      hour = int.tryParse(parts[0]) ?? 0;
      minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    }
    return DateTime(day.year, day.month, day.day, hour, minute);
  }

  /// `YYYY-MM-DD` for the backend `due_date`.
  static String formatDate(DateTime dt) =>
      '${dt.year.toString().padLeft(4, '0')}-'
      '${dt.month.toString().padLeft(2, '0')}-'
      '${dt.day.toString().padLeft(2, '0')}';

  /// `HH:mm` for the backend `due_time`.
  static String formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:'
      '${dt.minute.toString().padLeft(2, '0')}';
}
