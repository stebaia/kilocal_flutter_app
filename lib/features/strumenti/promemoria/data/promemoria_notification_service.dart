import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../domain/entities/promemoria_reminder.dart';

/// Schedules and cancels the best-effort OS local notification tied to a
/// reminder. The reminder itself is persisted on the backend (see
/// `PromemoriaRepository`); this only mirrors it as an OS notification so the
/// user is alerted at the chosen date/time.
class PromemoriaNotificationService {
  PromemoriaNotificationService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  static const _channelId = 'promemoria_reminders';
  static const _channelName = 'Promemoria';
  static const _channelDescription = 'I tuoi promemoria personali.';

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
      ),
    );
    _initialized = true;
  }

  Future<bool> _requestPermission() async {
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (ios != null) {
      final granted = await ios.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? true;
    }
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? true;
    }
    return true;
  }

  /// Schedules the OS notification for [reminder]. Past-dated reminders are
  /// skipped (nothing to fire). Best-effort: silently no-ops if permission is
  /// denied so a scheduling failure never blocks the backend write.
  Future<void> schedule(PromemoriaReminder reminder) async {
    if (!reminder.dateTime.isAfter(DateTime.now())) return;
    await _ensureInitialized();
    final granted = await _requestPermission();
    if (!granted) return;

    final scheduled = tz.TZDateTime.from(reminder.dateTime, tz.local);
    await _plugin.zonedSchedule(
      reminder.notificationId,
      _channelName,
      reminder.message,
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Cancels the OS notification previously scheduled for [notificationId]
  /// (see [PromemoriaReminder.notificationId]).
  Future<void> cancel(int notificationId) async {
    await _ensureInitialized();
    await _plugin.cancel(notificationId);
  }
}
