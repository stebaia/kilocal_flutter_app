import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/system_timer_service.dart';

/// Holds the state of the running workout timer so it survives navigation
/// across the whole app. Registered as a single `get_it` instance and shared
/// by every entry point (path steps, strumenti) so starting the timer from
/// either one drives the same countdown and the same overlay pill.
///
/// In addition to the in-app pill (driven by this controller), [start] hands
/// the timer to the native surface via [SystemTimerService] — the system Clock
/// app on Android and a Live Activity on iOS. The pill runs regardless of
/// whether the native surface is available.
class PathTimerController extends ChangeNotifier {
  PathTimerController({
    SystemTimerService? systemTimer,
    AudioPlayer? completionPlayer,
    this.label = 'KiloCal',
  }) : _systemTimer = systemTimer ?? SystemTimerService(),
       _completionPlayer = completionPlayer ?? AudioPlayer();

  final SystemTimerService _systemTimer;
  final AudioPlayer _completionPlayer;
  final String label;

  Duration _remaining = Duration.zero;
  Timer? _ticker;
  bool _running = false;
  bool _paused = false;

  Duration get remaining => _remaining;
  bool get isRunning => _running;
  bool get isPaused => _paused;

  void start(Duration duration) {
    _remaining = duration;
    _running = true;
    _paused = false;
    _tick();
    notifyListeners();
    // Fire-and-forget: native surface is best-effort, the pill is the source
    // of truth.
    _systemTimer.start(duration, label: label);
  }

  void togglePause() {
    if (!_running) return;
    _paused = !_paused;
    if (_paused) {
      _ticker?.cancel();
    } else {
      _tick();
    }
    notifyListeners();
  }

  void stop() {
    _ticker?.cancel();
    _running = false;
    _paused = false;
    _remaining = Duration.zero;
    notifyListeners();
    _systemTimer.stop();
  }

  void _tick() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remaining.inSeconds <= 1) {
        _remaining = Duration.zero;
        _ticker?.cancel();
        _running = false;
        _playCompletionSound();
      } else {
        _remaining -= const Duration(seconds: 1);
      }
      notifyListeners();
    });
  }

  Future<void> _playCompletionSound() async {
    try {
      await _completionPlayer.play(
        AssetSource('audio/timer_terminer.mp3'),
      );
    } catch (_) {
      // Best-effort: a missing/failed sound must not affect timer state.
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _completionPlayer.dispose();
    super.dispose();
  }
}

/// Persistent red pill showing the running timer, with pause/resume and
/// dismiss (stop) icons on the right. Renders nothing when the timer is not
/// running.
class PathTimerPill extends StatelessWidget {
  const PathTimerPill({super.key, required this.controller});

  final PathTimerController controller;

  String _format(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inHours)}:${two(d.inMinutes % 60)}:${two(d.inSeconds % 60)}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        if (!controller.isRunning) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.all(AppSpacing.screenGutter),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              // White border so the pill stays legible over other red
              // surfaces (e.g. the path/strumenti brand headers) instead of
              // blending into them.
              border: Border.all(color: AppColors.neutralWhite, width: 2),
            ),
            child: Material(
              color: AppColors.brandPink,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.spaceLg,
                  vertical: AppSpacing.spaceMd,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.pathTimerPill(_format(controller.remaining)),
                        style: AppTypography.textTheme.titleMedium?.copyWith(
                          color: AppColors.neutralWhite,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: controller.togglePause,
                      child: Icon(
                        controller.isPaused ? Icons.play_arrow : Icons.pause,
                        color: AppColors.neutralWhite,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.spaceMd),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: controller.stop,
                      child: const Icon(
                        Icons.close,
                        color: AppColors.neutralWhite,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
