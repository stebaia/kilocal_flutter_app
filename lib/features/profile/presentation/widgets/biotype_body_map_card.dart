import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import 'biotype_body_points.dart';

/// "Il tuo punto di partenza" card: a light card with a colored title pill and
/// the biotype silhouette overlaid with clickable dots.
///
/// The silhouette is a dot-free, full-color asset ([silhouetteAssetName]); the
/// dots are drawn as widgets on top at fractional positions ([points]) so they
/// stay clickable and follow the biotype [accentColor]. Tapping a dot invokes
/// [onPointTap] with the tapped point.
class BiotypeBodyMapCard extends StatelessWidget {
  const BiotypeBodyMapCard({
    super.key,
    required this.title,
    required this.accentColor,
    this.silhouetteAssetName,
    this.silhouetteAspect = manSilhouetteAspect,
    this.points = const [],
    this.onPointTap,
  });

  /// Intrinsic w/h ratio of the man reference silhouettes (287x870).
  static const double manSilhouetteAspect = 287 / 870;

  /// Intrinsic w/h ratio of the woman reference silhouettes (279x870).
  static const double womanSilhouetteAspect = 279 / 870;

  /// Title shown in the pill, e.g. "Tipo 1 - Il tuo punto di partenza".
  final String title;

  /// Biotype `main_color`; tints the title pill and the dots.
  final Color accentColor;

  /// Dot-free silhouette asset (`assets/person/<gender>-type<N>.png`).
  final String? silhouetteAssetName;

  /// Intrinsic w/h ratio of [silhouetteAssetName]; the dot fractions were
  /// measured against this ratio, so the image is constrained to it.
  final double silhouetteAspect;

  /// Clickable dots in fractional silhouette coordinates.
  final List<BiotypeBodyPoint> points;

  final ValueChanged<BiotypeBodyPoint>? onPointTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: accentColor.withValues(alpha: 0.4)),
      ),
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.all(AppSpacing.spaceSm),
      child: Column(
        children: [
          _TitlePill(title: title, color: accentColor),
          const SizedBox(height: AppSpacing.spaceMd),
          Expanded(
            child: _Silhouette(
              assetName: silhouetteAssetName,
              aspect: silhouetteAspect,
              points: points,
              dotColor: accentColor,
              onPointTap: onPointTap,
            ),
          ),
          const SizedBox(height: AppSpacing.spaceSm),
        ],
      ),
    );
  }
}

/// Rounded, filled pill carrying the biotype title at the top of the card.
class _TitlePill extends StatelessWidget {
  const _TitlePill({required this.title, required this.color});

  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.spaceMd,
        vertical: AppSpacing.spaceSm,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: AppTypography.textTheme.titleSmall?.copyWith(
          color: AppColors.neutralWhite,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Renders the silhouette image and overlays the clickable dots, sized to the
/// image's rendered box via [LayoutBuilder] so dot positions stay accurate.
class _Silhouette extends StatelessWidget {
  const _Silhouette({
    required this.assetName,
    required this.aspect,
    required this.points,
    required this.dotColor,
    this.onPointTap,
  });

  final String? assetName;

  /// Intrinsic w/h ratio of the silhouette; the dot fractions were measured
  /// against it, so the image is constrained to this ratio and the dots are
  /// laid out on the exact same box — no letterboxing offset.
  final double aspect;

  final List<BiotypeBodyPoint> points;
  final Color dotColor;
  final ValueChanged<BiotypeBodyPoint>? onPointTap;

  @override
  Widget build(BuildContext context) {
    if (assetName == null || assetName!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Center(
      child: AspectRatio(
        aspectRatio: aspect,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: Image.asset(
                    assetName!,
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                    errorBuilder: (context, error, stackTrace) =>
                        const SizedBox.shrink(),
                  ),
                ),
                // The AspectRatio box now matches the image box exactly, so
                // fractional positions map straight onto it.
                for (final point in points)
                  _PositionedDot(
                    point: point,
                    box: constraints.biggest,
                    color: dotColor,
                    onTap: onPointTap,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// A single dot positioned at [BiotypeBodyPoint.position] within [box].
class _PositionedDot extends StatelessWidget {
  const _PositionedDot({
    required this.point,
    required this.box,
    required this.color,
    this.onTap,
  });

  final BiotypeBodyPoint point;
  final Size box;
  final Color color;
  final ValueChanged<BiotypeBodyPoint>? onTap;

  static const double _hitSize = 44;

  @override
  Widget build(BuildContext context) {
    final left = point.position.dx * box.width - _hitSize / 2;
    final top = point.position.dy * box.height - _hitSize / 2;

    return Positioned(
      left: left,
      top: top,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap == null ? null : () => onTap!(point),
        child: SizedBox(
          width: _hitSize,
          height: _hitSize,
          child: Center(child: _Dot(color: color)),
        ),
      ),
    );
  }
}

/// The dot glyph: a filled inner circle inside a thin ringed outer circle, over
/// a white disc so it reads on the tinted silhouette.
class _Dot extends StatelessWidget {
  const _Dot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.neutralWhite,
        border: Border.all(color: color, width: 2),
      ),
      alignment: Alignment.center,
      child: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }
}
