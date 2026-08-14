import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'device_token_api.dart';
import 'push_notification_service.dart';

/// Keeps the backend's copy of this device's FCM token in sync with Firebase.
///
/// [PushNotificationService] is transport-only: it surfaces the token but never
/// talks to our API. This class is the bridge — it owns the
/// `POST/DELETE /profile/device-tokens` calls and the lifecycle around them:
///
/// - [registerCurrentToken] after login / on app start with a live session.
/// - FCM token rotation, via [PushNotificationService.onTokenRefresh]: the new
///   token is registered automatically for as long as a session is active.
/// - [unregisterCurrentToken] on logout, so the device stops receiving pushes
///   meant for the user who just signed out.
///
/// Every call is best-effort: push registration must never break login or block
/// logout, so failures are swallowed (logged in debug) rather than rethrown.
class DeviceTokenRegistrar {
  DeviceTokenRegistrar({
    required DeviceTokenApi api,
    required PushNotificationService push,
    TargetPlatform? platformOverride,
  }) : _api = api,
       _push = push,
       _platformOverride = platformOverride;

  final DeviceTokenApi _api;
  final PushNotificationService _push;
  final TargetPlatform? _platformOverride;

  StreamSubscription<String>? _refreshSub;

  /// The token most recently registered with the backend. Kept so logout can
  /// revoke the exact token even if FCM stops returning it.
  String? _registeredToken;

  /// Whether a session is active. Gates the token-refresh listener: a rotation
  /// that arrives while logged out must not silently re-register the device.
  bool _sessionActive = false;

  /// Registers the current FCM token and starts following rotations.
  ///
  /// Call after a successful login and after restoring a session on app start.
  /// Safe to call repeatedly: the upsert is idempotent server-side.
  Future<void> registerCurrentToken() async {
    _sessionActive = true;
    _listenForRefresh();

    final token = await _readToken();
    if (token == null) return;
    await _register(token);
  }

  /// Revokes the registered token so this device stops receiving the user's
  /// pushes, then stops following rotations.
  ///
  /// Must run *before* the auth tokens are cleared: the endpoint is
  /// bearer-authenticated, so without a valid session the call 401s.
  Future<void> unregisterCurrentToken() async {
    _sessionActive = false;
    await _refreshSub?.cancel();
    _refreshSub = null;

    final token = _registeredToken ?? await _readToken();
    _registeredToken = null;
    if (token == null) return;

    try {
      await _api.unregister({'token': token});
    } on DioException catch (e) {
      // 404 just means the backend already dropped it — nothing to recover.
      _log('unregister failed: ${e.response?.statusCode ?? e.message}');
    } catch (e) {
      _log('unregister failed: $e');
    }
  }

  Future<void> dispose() async {
    await _refreshSub?.cancel();
    _refreshSub = null;
  }

  void _listenForRefresh() {
    _refreshSub ??= _push.onTokenRefresh.listen((token) {
      if (!_sessionActive) return;
      unawaited(_register(token));
    });
  }

  Future<void> _register(String token) async {
    try {
      await _api.register({'token': token, 'platform': _platformName});
      _registeredToken = token;
      _log('token registered ($_platformName)');
    } on DioException catch (e) {
      _log('register failed: ${e.response?.statusCode ?? e.message}');
    } catch (e) {
      _log('register failed: $e');
    }
  }

  /// Reads the token from FCM, tolerating the cases where it is unavailable
  /// (permission denied, or iOS simulator without APNs).
  Future<String?> _readToken() async {
    try {
      final token = await _push.getToken();
      if (token == null) _log('no FCM token available');
      return token;
    } catch (e) {
      _log('getToken failed: $e');
      return null;
    }
  }

  /// Maps the running platform onto the enum the API accepts
  /// (`ios` | `android` | `web`).
  String get _platformName {
    if (kIsWeb) return 'web';
    return switch (_platformOverride ?? defaultTargetPlatform) {
      TargetPlatform.iOS || TargetPlatform.macOS => 'ios',
      _ => 'android',
    };
  }

  void _log(String message) {
    if (kDebugMode) debugPrint('[FCM] $message');
  }
}
