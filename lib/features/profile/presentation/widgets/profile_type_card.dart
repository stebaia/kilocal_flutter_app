import 'package:flutter/material.dart';

import '../../../../core/icons/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/cms_svg_icon.dart';
import '../../../../core/widgets/wave_decoration.dart';

/// Pink gradient "Il mio Tipo" card with a soft wave decoration, a circular
/// icon badge, the type label, and a trailing chevron. When [cardColor] /
/// [iconColor] are provided (the biotype `main_color`) the card is filled with
/// that colour and the white icon badge shows the biotype icon tinted with it.
class ProfileTypeCard extends StatelessWidget {
  const ProfileTypeCard({
    super.key,
    required this.label,
    this.iconUrl,
    this.cardColor,
    this.iconColor,
    this.onTap,
  });

  final String label;
  final String? iconUrl;

  /// Card background (`main_color`). Falls back to the brand gradient.
  final Color? cardColor;

  /// Tint of the biotype icon inside the white badge (`main_color`).
  final Color? iconColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tint = iconColor ?? AppColors.accent;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            color: cardColor,
            gradient: cardColor == null ? AppColors.brandGradient : null,
          ),
          child: Stack(
            children: [
              // Decorative wave on the right half — a soft translucent white
              // flourish over the (biotype-coloured) card background.
              Positioned.fill(
                child: WaveDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                ),
              ),
              Container(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: AppColors.neutralWhite,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: CmsSvgIcon(
                          url: iconUrl,
                          size: 18,
                          color: tint,
                          fallback: AppIcon(
                            AppIcons.popsicle,
                            size: 18,
                            color: tint,
                          ),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
