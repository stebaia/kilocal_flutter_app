import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../domain/entities/integrazione_data.dart';
import '../domain/entities/reminder_offset.dart';

/// Schedules **client-side** local notifications reminding the user to take a
/// supplement, one-shot at `now + offset` ("Posticipa di N ore/giorni").
///
/// Local-only by design: the backend exposes no reminder endpoint, and the
/// reminder is a personal, device-local snooze.
///
/// The active-reminder state (which product has a reminder, with what offset and
/// fire time) is persisted in [FlutterSecureStorage] rather than inferred from
/// the pending OS notification. This keeps the UI truthful even if the OS drops
/// or throttles the pending request, and lets us surface scheduling failures
/// instead of silently swallowing them.
class IntegrazioneReminderService {
  IntegrazioneReminderService({
    FlutterLocalNotificationsPlugin? plugin,
    FlutterSecureStorage? storage,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin(),
       _storage = storage ?? const FlutterSecureStorage();

  final FlutterLocalNotificationsPlugin _plugin;
  final FlutterSecureStorage _storage;
  bool _initialized = false;

  /// Secure-storage key for a product's active reminder (`offsetKey|iso`).
  String _storageKey(String productId) => 'integrazione_reminder_$productId';

  static const _channelId = 'integrazione_reminders';
  static const _channelName = 'Promemoria integrazione';
  static const _channelDescription =
      'Promemoria per l\'assunzione degli integratori.';

  /// Payload format: `offsetKey|scheduledIso` so both can be read back from a
  /// pending request.
  static const _payloadSeparator = '|';

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
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

  /// Requests notification permission from the OS (iOS/Android 13+).
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
      // ignore: avoid_print
      print('[REMINDER] iOS requestPermissions -> $granted');
      // iOS returns null/false once the choice has already been made (e.g. FCM
      // asked at boot). Don't block scheduling on that — the OS keeps its
      // existing grant; if truly denied, zonedSchedule simply won't fire.
      return granted ?? true;
    }

    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      // ignore: avoid_print
      print('[REMINDER] Android requestNotificationsPermission -> $granted');
      return granted ?? true;
    }
    return true;
  }

  /// Schedules (or replaces) a one-shot reminder for [product] at `now + offset`.
  /// Returns `false` if permission was denied; throws if scheduling fails so the
  /// caller can surface the real error instead of it being swallowed.
  Future<bool> scheduleReminder({
    required IntegrazioneProduct product,
    required ReminderOffset offset,
  }) async {
    await _ensureInitialized();
    final granted = await _requestPermission();
    // ignore: avoid_print
    print(
      '[REMINDER] scheduleReminder product=${product.id} '
      'offset=${offset.key} granted=$granted',
    );
    if (!granted) return false;

    final id = _notificationId(product.id);
    // Replace any existing reminder for this product.
    await _plugin.cancel(id);

    final scheduled = tz.TZDateTime.now(tz.local).add(offset.duration);
    final payload =
        '${offset.key}$_payloadSeparator'
        '${scheduled.toIso8601String()}';

    await _plugin.zonedSchedule(
      id,
      product.title,
      _reminderBody(product),
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
      payload: payload,
    );

    // Persist the active-reminder state as the source of truth for the UI.
    await _storage.write(key: _storageKey(product.id), value: payload);
    // ignore: avoid_print
    print('[REMINDER] stored key=${_storageKey(product.id)} value=$payload');
    return true;
  }

  /// Reads the currently-scheduled reminder for [productId], or `null` if none.
  Future<ActiveReminder?> getReminder(String productId) async {
    final stored = await _storage.read(key: _storageKey(productId));
    // ignore: avoid_print
    print(
      '[REMINDER] getReminder key=${_storageKey(productId)} '
      'stored=$stored',
    );
    if (stored == null) return null;

    final parts = stored.split(_payloadSeparator);
    if (parts.length != 2) return null;
    final offset = ReminderOffset.fromKey(parts[0]);
    final scheduledAt = DateTime.tryParse(parts[1]);
    if (offset == null || scheduledAt == null) {
      // Corrupt entry — clear it.
      await _storage.delete(key: _storageKey(productId));
      return null;
    }

    // If the reminder already fired (scheduledAt in the past), it's no longer
    // active: clear it so the UI reverts to "enable reminder".
    if (scheduledAt.isBefore(DateTime.now())) {
      await _storage.delete(key: _storageKey(productId));
      return null;
    }

    return ActiveReminder(offset: offset, scheduledAt: scheduledAt);
  }

  /// Cancels the reminder for a product, if any.
  Future<void> cancelReminder(String productId) async {
    await _ensureInitialized();
    await _plugin.cancel(_notificationId(productId));
    await _storage.delete(key: _storageKey(productId));
  }

  String _reminderBody(IntegrazioneProduct product) {
    final qty = product.quantity;
    return qty > 1
        ? 'Ricordati di assumere $qty dosi.'
        : 'Ricordati di assumere la tua dose.';
  }

  /// A stable per-product notification id derived from the product id.
  int _notificationId(String productId) =>
      int.tryParse(productId) ?? productId.hashCode & 0x7fffffff;
}
