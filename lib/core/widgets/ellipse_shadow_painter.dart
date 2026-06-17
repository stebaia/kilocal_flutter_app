import 'dart:ui';

import 'package:flutter/material.dart';

/// CustomPainter that draws the elliptical blurred shadow from the SVG:
/// `<svg width="83" height="20" viewBox="0 0 83 20" ...>`
/// `<ellipse cx="41.1763" cy="9.60813" rx="35" ry="3.43137" fill="#1C1C1C"/>`
/// with group opacity 0.2 and gaussian blur stdDeviation="3.08824".
class EllipseShadowPainter extends CustomPainter {
  final Color shadowColor;
  final double opacity;
  final double blurSigma;

  const EllipseShadowPainter({
    this.shadowColor = const Color(0xFF1C1C1C),
    this.opacity = 0.2,
    this.blurSigma = 3.08824,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // SVG viewBox is 83x20.
    final double scaleX = size.width / 83;
    final double scaleY = size.height / 20;

    final Rect ovalRect = Rect.fromCenter(
      center: Offset(41.1763 * scaleX, 9.60813 * scaleY),
      width: 70 * scaleX, // rx * 2
      height: 6.86274 * scaleY, // ry * 2
    );

    // Apply blur to the whole layer, just like feGaussianBlur in SVG.
    canvas.saveLayer(
      null,
      Paint()
        ..imageFilter = ImageFilter.blur(
          sigmaX: blurSigma,
          sigmaY: blurSigma,
          tileMode: TileMode.decal,
        ),
    );

    canvas.drawOval(
      ovalRect,
      Paint()..color = shadowColor.withValues(alpha: opacity),
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Convenience widget that wraps [EllipseShadowPainter].
///
/// Use it below an image to reproduce the soft elliptical shadow.
class EllipseShadow extends StatelessWidget {
  final double width;
  final double height;
  final Color shadowColor;
  final double opacity;
  final double blurSigma;

  const EllipseShadow({
    super.key,
    this.width = 83,
    this.height = 20,
    this.shadowColor = const Color(0xFF1C1C1C),
    this.opacity = 0.2,
    this.blurSigma = 3.08824,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: EllipseShadowPainter(
        shadowColor: shadowColor,
        opacity: opacity,
        blurSigma: blurSigma,
      ),
    );
  }
}
