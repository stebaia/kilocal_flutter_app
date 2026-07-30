import 'package:flutter/painting.dart';

/// Darkens [color] until it clears the WCAG AA 4.5:1 contrast ratio for text
/// on a white/near-white background.
///
/// Several CMS biotype colors are too light to read on white — the cyan
/// (#00ACAC), orange (#EF7900) and light blue (#009FE3) types all sit below
/// 3:1 — so we walk the HSL lightness down instead of hardcoding per-type
/// overrides, which keeps the hue (and the biotype's identity) intact.
Color readableOnWhite(Color color) {
  const target = 4.5;
  var hsl = HSLColor.fromColor(color);
  while (_contrastOnWhite(hsl.toColor()) < target && hsl.lightness > 0.05) {
    hsl = hsl.withLightness((hsl.lightness - 0.02).clamp(0.0, 1.0));
  }
  return hsl.toColor();
}

double _contrastOnWhite(Color color) =>
    1.05 / (color.computeLuminance() + 0.05);
