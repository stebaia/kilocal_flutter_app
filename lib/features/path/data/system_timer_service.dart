import 'dart:io' show Platform;

import 'package:flutter/services.dart';
import 'package:live_activities/live_activities.dart';

/// Bridges the workout timer to the platform's native surfaces:
///
/// - **Android**: opens the system Clock app with a pre-filled timer via an
///   intent handled in `MainActivity`.
/// - **iOS (16.1+)**: starts a Live Activity that shows in the Dynamic Island,
///   using the `live_activities` plugin.
///
/// The in-app pill is always shown by the caller regardless of what this
/// service can do, so every method degrades quietly (never throws) and the UI
/// keeps working even when no native surface is available.
///
/// Disabled: [_kNativeSurfaceEnabled] is `false` because launching the system
/// Clock/a Live Activity when the in-app timer starts was unwanted — users
/// only expect the in-app pill. The native-surface code below is left intact
/// (not deleted) so it can be flipped back on with a one-line change if that
/// changes again.
class SystemTimerService {
  SystemTimerService({MethodChannel? androidChannel, LiveActivities? live})
    : _android = androidChannel ?? const MethodChannel('kilocal/system_timer'),
      _live = live ?? LiveActivities();

  static const bool _kNativeSurfaceEnabled = false;

  /// App Group id shared between the Runner app and the iOS widget extension.
  /// Must match the one configured in Xcode and the extension's entitlements.
  static const String _iosAppGroupId = 'group.com.kilocal.liveactivities';

  final MethodChannel _android;
  final LiveActivities _live;

  bool _iosInitialised = false;
  String? _iosActivityId;

  /// Starts the native timer surface for [duration]. Returns `true` when a
  /// native surface was started, `false` otherwise (caller still shows the
  /// pill).
  Future<bool> start(Duration duration, {required String label}) async {
    if (!_kNativeSurfaceEnabled) return false;
    if (Platform.isAndroid) {
      return _startAndroid(duration, label);
    }
    if (Platform.isIOS) {
      return _startIos(duration, label);
    }
    return false;
  }

  /// Ends any running native surface (Live Activity on iOS; the Android system
  /// timer is owned by the Clock app and is not ours to cancel).
  Future<void> stop() async {
    if (!_kNativeSurfaceEnabled) return;
    final id = _iosActivityId;
    if (Platform.isIOS && id != null) {
      try {
        await _live.endActivity(id);
      } catch (_) {
        // Ignore: the activity may already be gone.
      }
      _iosActivityId = null;
    }
  }

  Future<bool> _startAndroid(Duration duration, String label) async {
    try {
      final ok = await _android.invokeMethod<bool>('startTimer', {
        'seconds': duration.inSeconds,
        'label': label,
      });
      return ok ?? false;
    } on PlatformException {
      return false;
    }
  }

  Future<bool> _startIos(Duration duration, String label) async {
    try {
      // init() must run first: it wires up the App Group store the plugin
      // writes the activity data into.
      if (!_iosInitialised) {
        await _live.init(appGroupId: _iosAppGroupId);
        _iosInitialised = true;
      }

      if (!await _live.areActivitiesEnabled()) return false;

      final endDate = DateTime.now().add(duration);
      final activityId = 'workout-timer-${endDate.millisecondsSinceEpoch}';
      _iosActivityId = await _live.createActivity(
        activityId,
        {
          'label': label,
          // Epoch millis; the SwiftUI widget renders the countdown from this.
          'endDate': endDate.millisecondsSinceEpoch,
        },
        // No Push Notifications capability is configured on Runner, so remote
        // updates are off. The widget counts down on its own from `endDate`.
        iOSEnableRemoteUpdates: false,
      );
      return _iosActivityId != null;
    } catch (_) {
      return false;
    }
  }
}
