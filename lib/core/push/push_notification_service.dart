import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Handles Firebase Cloud Messaging (FCM): permissions, device token, and the
/// three delivery states (foreground, background-tap, terminated-tap).
///
/// This service is transport-only: it surfaces the token and incoming messages
/// via streams. Registering the token with the backend and rendering in-app UI
/// are the responsibility of the caller (e.g. the notifications feature).
///
/// The background isolate handler [firebaseMessagingBackgroundHandler] must stay
/// a top-level function and be registered before `runApp`.
class PushNotificationService {
  PushNotificationService({FirebaseMessaging? messaging})
    : _messaging = messaging ?? FirebaseMessaging.instance;

  final FirebaseMessaging _messaging;

  final StreamController<RemoteMessage> _onMessageController =
      StreamController<RemoteMessage>.broadcast();
  final StreamController<RemoteMessage> _onMessageOpenedController =
      StreamController<RemoteMessage>.broadcast();
  final StreamController<String> _onTokenRefreshController =
      StreamController<String>.broadcast();

  /// Messages received while the app is in the foreground.
  Stream<RemoteMessage> get onMessage => _onMessageController.stream;

  /// A notification the user tapped to open the app (background or terminated).
  Stream<RemoteMessage> get onMessageOpenedApp =>
      _onMessageOpenedController.stream;

  /// Emits whenever FCM rotates the device token; forward this to the backend.
  Stream<String> get onTokenRefresh => _onTokenRefreshController.stream;

  final List<StreamSubscription<dynamic>> _subs = [];

  /// The message that launched the app from a terminated state, if any.
  RemoteMessage? initialMessage;

  /// Requests notification permission, wires the delivery handlers, and reads
  /// the initial launch message. Call once during bootstrap.
  Future<void> init() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (kDebugMode) {
      debugPrint('[FCM] permission: ${settings.authorizationStatus}');
    }

    // Show heads-up notifications while in the foreground on iOS.
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    _subs.add(FirebaseMessaging.onMessage.listen(_onMessageController.add));
    _subs.add(
      FirebaseMessaging.onMessageOpenedApp.listen(
        _onMessageOpenedController.add,
      ),
    );
    _subs.add(_messaging.onTokenRefresh.listen(_onTokenRefreshController.add));

    // App opened from terminated state via a notification tap.
    initialMessage = await _messaging.getInitialMessage();
  }

  /// Current FCM registration token, or `null` if unavailable (e.g. iOS
  /// simulator without APNs, or permission denied).
  Future<String?> getToken() => _messaging.getToken();

  /// Subscribes the device to a topic (broadcast segment).
  Future<void> subscribeToTopic(String topic) =>
      _messaging.subscribeToTopic(topic);

  Future<void> unsubscribeFromTopic(String topic) =>
      _messaging.unsubscribeFromTopic(topic);

  Future<void> deleteToken() => _messaging.deleteToken();

  Future<void> dispose() async {
    for (final sub in _subs) {
      await sub.cancel();
    }
    await _onMessageController.close();
    await _onMessageOpenedController.close();
    await _onTokenRefreshController.close();
  }
}

/// Background/terminated message handler. Runs in a separate isolate, so it must
/// be a top-level (or static) function and cannot touch app state directly.
///
/// Registered via `FirebaseMessaging.onBackgroundMessage` in `main()`. It must
/// call `Firebase.initializeApp` itself because the isolate has no access to the
/// one created on the main isolate. Keep the work here minimal.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase is initialized by the framework before this handler runs on
  // supported versions; heavy work (DB writes, network) should be avoided.
  if (kDebugMode) {
    debugPrint('[FCM] background message: ${message.messageId}');
  }
}
