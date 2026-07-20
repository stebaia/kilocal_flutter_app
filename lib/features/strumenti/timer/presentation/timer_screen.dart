import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../path/presentation/widgets/path_timer_pill.dart';
import '../../../path/presentation/widgets/path_timer_sheet.dart';
import 'widgets/timer_countdown_ring.dart';

/// Strumenti > Timer: the full-screen version of the path timer.
///
/// Same countdown engine as the in-path bottom sheet ([PathTimerController],
/// which also drives the native timer surface); the difference is presentation
/// — duration wheels and a running ring live on a white card over the brand red
/// ellipse instead of inside a sheet.
class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  late final PathTimerController _controller;

  /// Duration picked on the wheels, and the denominator of the ring's
  /// progress once running.
  Duration _picked = Duration.zero;
  Duration _total = Duration.zero;

  @override
  void initState() {
    super.initState();
    _controller = PathTimerController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _start() {
    if (_picked <= Duration.zero) return;
    setState(() => _total = _picked);
    _controller.start(_picked);
  }

  void _stop() {
    _controller.stop();
    setState(() => _total = Duration.zero);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppHeader(title: l10n.strumentiTimer, showBack: true),
            Expanded(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  final running = _controller.isRunning;
                  return _TimerPanel(
                    card: running
                        ? Padding(
                            padding: const EdgeInsets.all(AppSpacing.spaceLg),
                            child: TimerCountdownRing(
                              remaining: _controller.remaining,
                              total: _total,
                            ),
                          )
                        : Center(
                            child: TimerDurationWheels(
                              digitSize: 40,
                              onChanged: (d) => _picked = d,
                            ),
                          ),
                    actions: _TimerActions(
                      canStop: running,
                      onStop: _stop,
                      primaryLabel: running
                          ? (_controller.isPaused
                                ? l10n.pathTimerResume
                                : l10n.pathTimerPause)
                          : l10n.pathTimerStart,
                      primaryIcon: running
                          ? (_controller.isPaused
                                ? Icons.play_arrow_outlined
                                : Icons.pause)
                          : Icons.play_arrow_outlined,
                      onPrimary: running ? _controller.togglePause : _start,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Paints the brand header ellipse: a wide oval whose sides run off-screen so
/// only its curved bottom edge shows, filling the box from the top down.
///
/// This mirrors `path_header_ellipse.svg`, which is only the bottom 75px
/// sliver of an ellipse far wider than the screen (rx 589.5 on a 390 viewBox).
/// The asset can't be scaled to an arbitrary height — stretching flattens the
/// curve — so the same shape is painted at whatever height the header needs.
class _HeaderEllipsePainter extends CustomPainter {
  const _HeaderEllipsePainter();

  /// How far the oval extends past each side of the screen. Taken from the
  /// asset's rx:viewBox ratio (589.5 / 195), which is what gives the arc its
  /// shallow curvature.
  static const double _widthOverflow = 589.5 / 195;

  @override
  void paint(Canvas canvas, Size size) {
    final halfWidth = size.width / 2 * _widthOverflow;
    // The oval's bottom sits at the box's bottom edge; its top is clipped off
    // above the screen, exactly as in the source asset.
    final rect = Rect.fromLTRB(
      size.width / 2 - halfWidth,
      size.height - halfWidth * (584.5 / 589.5) * 2,
      size.width / 2 + halfWidth,
      size.height,
    );

    canvas.drawOval(
      rect,
      Paint()..shader = AppColors.brandGradient.createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_HeaderEllipsePainter oldDelegate) => false;
}

/// White rounded card holding the timer body, sitting on the brand red ellipse
/// that peeks out behind its top corners, with the action row underneath.
/// Mirrors the Promemoria panel treatment.
class _TimerPanel extends StatelessWidget {
  const _TimerPanel({required this.card, required this.actions});

  final Widget card;
  final Widget actions;

  /// Design size of the white card. It shrinks to the available width on
  /// narrow screens (the gutters win) but never grows past this.
  static const double _cardSize = 342;

  /// The ellipse covers at least this share of the screen height.
  static const double _ellipseScreenFraction = 1 / 3;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;

    return Stack(
      children: [
        // The brand ellipse, drawn tall enough to cover the top third of the
        // screen while keeping its curved bottom edge.
        //
        // `path_header_ellipse.svg` is only the bottom 75px sliver of a much
        // larger ellipse, so it cannot simply be scaled up — stretching it to
        // this height flattens the curve into a rectangle. Instead the same
        // ellipse is painted directly, at the asset's own proportions: it is
        // far wider than the screen (rx 589.5 over a 390 viewBox), so its
        // sides run off-screen and only the bottom arc shows.
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: ClipRect(
            child: SizedBox(
              height: screenHeight * _ellipseScreenFraction,
              child: CustomPaint(
                painter: const _HeaderEllipsePainter(),
                size: Size.infinite,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.spaceLg,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: _cardSize,
                  maxHeight: _cardSize,
                ),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: card,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.spaceLg),
              actions,
            ],
          ),
        ),
      ],
    );
  }
}

/// "interrompi" (outlined, disabled until the timer runs) next to the dark
/// primary action, whose label follows the timer state.
class _TimerActions extends StatelessWidget {
  const _TimerActions({
    required this.canStop,
    required this.onStop,
    required this.primaryLabel,
    required this.primaryIcon,
    required this.onPrimary,
  });

  final bool canStop;
  final VoidCallback onStop;
  final String primaryLabel;
  final IconData primaryIcon;
  final VoidCallback onPrimary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            // Disabled, the button flattens to a filled grey pill (no red
            // outline) as in the design; the theme's outline only reads as
            // "tappable" when it is.
            style: canStop
                ? null
                : OutlinedButton.styleFrom(
                    disabledBackgroundColor: AppColors.divider,
                    disabledForegroundColor: AppColors.textSecondary,
                    side: BorderSide.none,
                  ),
            onPressed: canStop ? onStop : null,
            iconAlignment: IconAlignment.end,
            icon: const Icon(Icons.refresh, size: 18),
            label: Text(l10n.pathTimerStop),
          ),
        ),
        const SizedBox(width: AppSpacing.spaceMd),
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.ink),
            onPressed: onPrimary,
            iconAlignment: IconAlignment.end,
            icon: Icon(primaryIcon, size: 18),
            label: Text(primaryLabel),
          ),
        ),
      ],
    );
  }
}
