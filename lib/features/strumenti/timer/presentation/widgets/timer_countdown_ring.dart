import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';

/// Circular countdown: a grey track with a brand-red arc that grows
/// counter-clockwise from 12 o'clock as time elapses, capped by a filled dot at
/// its leading edge, with the remaining time in the middle.
class TimerCountdownRing extends StatelessWidget {
  const TimerCountdownRing({
    super.key,
    required this.remaining,
    required this.total,
  });

  final Duration remaining;
  final Duration total;

  /// Fraction of the countdown already elapsed, 0..1 — the part the red arc
  /// covers. Guards a zero [total] so a freshly-built ring paints empty rather
  /// than dividing by zero.
  double get _elapsed {
    if (total.inMilliseconds <= 0) return 0;
    final left = (remaining.inMilliseconds / total.inMilliseconds).clamp(
      0.0,
      1.0,
    );
    return 1 - left;
  }

  String _format(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    // Hours only appear once the countdown actually needs them, so the common
    // minutes:seconds case reads as "01:40" like the design.
    if (d.inHours > 0) {
      return '${two(d.inHours)}:${two(d.inMinutes % 60)}:${two(d.inSeconds % 60)}';
    }
    return '${two(d.inMinutes)}:${two(d.inSeconds % 60)}';
  }

  @override
  Widget build(BuildContext context) {
    // The host card is already square, so the painter just fills it.
    return CustomPaint(
      painter: _RingPainter(elapsed: _elapsed),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              _format(remaining),
              style: AppTypography.textTheme.displaySmall?.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.w400,
                fontSize: 44,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.elapsed});

  final double elapsed;

  static const double _stroke = 5;
  static const double _capRadius = 5.5;
  static const double _startAngle = -math.pi / 2;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (math.min(size.width, size.height) - _stroke) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _stroke
        ..color = AppColors.borderCard,
    );

    if (elapsed <= 0) return;

    // Negative sweep: the arc grows counter-clockwise (leftwards) from 12
    // o'clock as time is consumed, matching the design.
    final sweep = -2 * math.pi * elapsed;
    canvas.drawArc(
      rect,
      _startAngle,
      sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _stroke
        ..strokeCap = StrokeCap.round
        ..color = AppColors.accent,
    );

    // Dot at the arc's trailing edge — the point that travels as time drains.
    final endAngle = _startAngle + sweep;
    canvas.drawCircle(
      center + Offset(math.cos(endAngle), math.sin(endAngle)) * radius,
      _capRadius,
      Paint()..color = AppColors.accent,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.elapsed != elapsed;
}
