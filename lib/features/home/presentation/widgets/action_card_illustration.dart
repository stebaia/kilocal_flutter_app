import 'package:flutter/material.dart';

import '../../../../core/icons/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/ellipse_shadow_painter.dart';
import '../../../../../core/widgets/cms_image.dart';

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
    this.isLocked = false,
  });

  final String imageUrl;
  final String? assetName;

  /// When true, overlays a lock badge on top of the illustration, matching
  /// the "coming soon" state design.
  final bool isLocked;

  @override
  Widget build(BuildContext context) {
    if (assetName == 'assets/postcard.png') {
      return _withLockOverlay(
        Column(
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
        ),
      );
    }

    if (assetName == 'assets/letter.png') {
      return _withLockOverlay(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(assetName!, width: 112, height: 112),
            Transform.translate(
              offset: const Offset(0, -12),
              child: const EllipseShadow(width: 80, height: 16, opacity: 0.15),
            ),
          ],
        ),
      );
    }

    if (assetName != null) {
      return _withLockOverlay(Image.asset(assetName!, width: 112, height: 112));
    }

    // Fallback to network image for any other card.
    return _withLockOverlay(
      ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: CmsImage(imageUrl, width: 116, height: 116, fit: BoxFit.cover),
      ),
    );
  }

  Widget _withLockOverlay(Widget illustration) {
    if (!isLocked) return illustration;

    return Stack(
      alignment: Alignment.center,
      children: [
        illustration,
        Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: const AppIcon(AppIcons.lock, size: 24, color: Colors.black),
        ),
      ],
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
