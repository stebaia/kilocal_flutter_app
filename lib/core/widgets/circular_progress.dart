import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Circular percentage indicator used on home and statistics screens.
/// Displays a ring filled to [value] (0..1) with a centered percentage label.
class CircularProgress extends StatelessWidget {
  const CircularProgress({
    super.key,
    required this.value,
    this.size = 64,
    this.strokeWidth = 6,
    this.trackColor,
    this.foregroundColor,
  });

  final double value;
  final double size;
  final double strokeWidth;
  final Color? trackColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0.0, 1.0);
    final fg = foregroundColor ?? AppColors.accent;
    final bg = trackColor ?? AppColors.accentSoft;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: clamped,
              strokeWidth: strokeWidth,
              
              valueColor: AlwaysStoppedAnimation<Color>(fg),
            ),
          ),
          Text(
            '${(clamped * 100).round()}%',
            style: AppTypography.numericAccentCircular
          ),
        ],
      ),
    );
  }
}