import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Reusable decorative wave (`assets/decorations/wave.svg`) used as a soft
/// flourish on branded surfaces such as the "Il mio Tipo" card.
///
/// By default it keeps the asset's pink gradient. Pass [color] to recolor the
/// stroke to a single tint (e.g. a lighter shade of the biotype colour) so the
/// wave blends with a coloured card background. [alignment] and [fit] control
/// how the wave is placed within the available space.
class WaveDecoration extends StatelessWidget {
  const WaveDecoration({
    super.key,
    this.color,
    this.alignment = Alignment.centerRight,
    this.fit = BoxFit.cover,
  });

  final Color? color;
  final Alignment alignment;
  final BoxFit fit;

  static const _asset = 'assets/decorations/wave.svg';

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      _asset,
      fit: fit,
      alignment: alignment,
      colorFilter: color == null
          ? null
          : ColorFilter.mode(color!, BlendMode.srcIn),
    );
  }
}
