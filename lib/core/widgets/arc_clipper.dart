import 'package:flutter/material.dart';

/// Clips the top edge of a widget with a smooth concave arc.
///
/// Useful for bottom sheets / panels that need a curved top edge like the
/// register screen bottom bar.
class ArcClipper extends CustomClipper<Path> {
  const ArcClipper({this.arcHeight = 48});

  /// Height of the arc measured from the top corners down to the lowest point
  /// of the curve.
  final double arcHeight;

  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, arcHeight);
    path.quadraticBezierTo(
      size.width / 2,
      -arcHeight / 3,
      size.width,
      arcHeight,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant ArcClipper oldClipper) =>
      oldClipper.arcHeight != arcHeight;
}
