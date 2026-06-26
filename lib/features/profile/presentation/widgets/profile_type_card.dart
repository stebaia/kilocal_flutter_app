import 'package:flutter/material.dart';

import '../../../../core/icons/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Pink gradient "Il mio Tipo" card with a soft wave decoration, a circular
/// icon badge, the type label, and a trailing chevron.
class ProfileTypeCard extends StatelessWidget {
  const ProfileTypeCard({super.key, required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          height: 64,
          decoration: const BoxDecoration(gradient: AppColors.brandGradient),
          child: Stack(
            children: [
              // Decorative translucent wave on the right half.
              Positioned.fill(
                child: CustomPaint(painter: _WavePainter()),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.spaceMd,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: AppIcon(
                        AppIcons.popsicle,
                        size: 18,
                        color: AppColors.neutralWhite,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.spaceSm),
                    Expanded(
                      child: Text(
                        label,
                        style: AppTypography.textTheme.titleMedium?.copyWith(
                          color: AppColors.neutralWhite,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: AppColors.neutralWhite,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Paints two soft, semi-transparent white waves sweeping across the card,
/// fading toward the right edge.
class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width * 0.35, size.height)
      ..cubicTo(
        size.width * 0.5,
        size.height * 0.2,
        size.width * 0.7,
        size.height * 1.1,
        size.width,
        size.height * 0.35,
      )
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, paint);

    final paint2 = Paint()
      ..color = Colors.white.withValues(alpha: 0.10)
      ..style = PaintingStyle.fill;

    final path2 = Path()
      ..moveTo(size.width * 0.55, 0)
      ..cubicTo(
        size.width * 0.7,
        size.height * 0.7,
        size.width * 0.85,
        -size.height * 0.1,
        size.width,
        size.height * 0.6,
      )
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) => false;
}
