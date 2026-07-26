import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/ellipse_shadow_painter.dart';

/// Illustration used inside home action cards.
///
/// Renders a local asset when [assetName] is provided, otherwise falls back
/// to the network [imageUrl]. Special layouts are applied for the known
/// `postcard.png` and `letter.png` assets (double postcard + shadow for the
/// former, single image + shadow for the latter).
class ActionCardIllustration extends StatelessWidget {
  const ActionCardIllustration({
    super.key,
    required this.imageUrl,
    this.assetName,
  });

  final String imageUrl;
  final String? assetName;

  @override
  Widget build(BuildContext context) {
    if (assetName == 'assets/postcard.png') {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 112,
            height: 112,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Back postcard, rotated to the left.
                Transform.rotate(
                  angle: -0.3,
                  child: Image.asset(assetName!, width: 112, height: 112),
                ),
                // Front postcard, slightly offset to the right.
                Positioned(
                  left: 0.2,
                  child: Image.asset(assetName!, width: 112, height: 112),
                ),
              ],
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -12),
            child: const EllipseShadow(width: 80, height: 16, opacity: 0.15),
          ),
        ],
      );
    }

    if (assetName == 'assets/letter.png') {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(assetName!, width: 112, height: 112),
          Transform.translate(
            offset: const Offset(0, -12),
            child: const EllipseShadow(width: 80, height: 16, opacity: 0.15),
          ),
        ],
      );
    }

    if (assetName != null) {
      return Image.asset(assetName!, width: 112, height: 112);
    }

    // Fallback to network image for any other card.
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Image.network(
        imageUrl,
        width: 116,
        height: 116,
        fit: BoxFit.cover,
      ),
    );
  }
}

class PathActionCardImage extends StatelessWidget {
  final String imageUrl;
  final String? assetName;

  const PathActionCardImage({
    super.key,
    this.assetName,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    // The dumbbell illustration is wider than the others, so keep it smaller
    // to avoid it overflowing too far past the pink circle. Sized close to
    // the 100x100 circle behind them (rather than 1.3-2x it) so the FittedBox
    // scaling in PathAreaTile doesn't make them look oversized on any device.
    final isLogo = assetName == 'assets/name_logo.png';
    final size = isLogo ? const Size(104, 72) : const Size(130, 90);

    return Image.asset(
      assetName!,
      width: size.width,
      height: size.height,
      fit: BoxFit.contain,
    );
  }
}
