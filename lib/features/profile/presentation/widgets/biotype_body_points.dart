import 'package:flutter/widgets.dart';

/// A single clickable point on the biotype silhouette body map.
///
/// [position] is a fractional offset within the silhouette bounding box
/// (`0..1`, origin top-left), so the dots scale with the rendered image. [id]
/// identifies which body area the point maps to, used to resolve the bottom
/// sheet content once the backend provides it (see body-map integration note).
class BiotypeBodyPoint {
  const BiotypeBodyPoint({required this.id, required this.position});

  final String id;
  final Offset position;
}

/// Clickable dot positions per biotype number, measured from the reference
/// silhouettes (`assets/person/type-<N>-man.png`) with `tools/detect_dots.py`.
///
/// Man variants: types 1,2,3,4,6,7 (type 5 has no male variant). The dot *count*
/// varies by type (3 to 5 points). Types absent from this map render the
/// silhouette without any clickable dots.
///
/// The [BiotypeBodyPoint.id] values are provisional area slugs; the real
/// mapping to bottom-sheet content is pending the backend contract.
const Map<int, List<BiotypeBodyPoint>> kManBiotypeBodyPoints = {
  1: [
    BiotypeBodyPoint(id: 'p1', position: Offset(0.500, 0.064)),
    BiotypeBodyPoint(id: 'p2', position: Offset(0.667, 0.429)),
    BiotypeBodyPoint(id: 'p3', position: Offset(0.277, 0.616)),
    BiotypeBodyPoint(id: 'p4', position: Offset(0.750, 0.770)),
  ],
  2: [
    BiotypeBodyPoint(id: 'p1', position: Offset(0.500, 0.064)),
    BiotypeBodyPoint(id: 'p2', position: Offset(0.416, 0.351)),
    BiotypeBodyPoint(id: 'p3', position: Offset(0.702, 0.402)),
    BiotypeBodyPoint(id: 'p4', position: Offset(0.263, 0.494)),
    BiotypeBodyPoint(id: 'p5', position: Offset(0.702, 0.503)),
  ],
  3: [
    BiotypeBodyPoint(id: 'p1', position: Offset(0.507, 0.064)),
    BiotypeBodyPoint(id: 'p2', position: Offset(0.138, 0.305)),
    BiotypeBodyPoint(id: 'p3', position: Offset(0.778, 0.514)),
    BiotypeBodyPoint(id: 'p4', position: Offset(0.222, 0.556)),
  ],
  4: [
    BiotypeBodyPoint(id: 'p1', position: Offset(0.507, 0.078)),
    BiotypeBodyPoint(id: 'p2', position: Offset(0.611, 0.439)),
    BiotypeBodyPoint(id: 'p3', position: Offset(0.277, 0.517)),
    BiotypeBodyPoint(id: 'p4', position: Offset(0.695, 0.779)),
  ],
  6: [
    BiotypeBodyPoint(id: 'p1', position: Offset(0.507, 0.059)),
    BiotypeBodyPoint(id: 'p2', position: Offset(0.340, 0.399)),
    BiotypeBodyPoint(id: 'p3', position: Offset(0.674, 0.429)),
  ],
  7: [
    BiotypeBodyPoint(id: 'p1', position: Offset(0.479, 0.048)),
    BiotypeBodyPoint(id: 'p2', position: Offset(0.667, 0.204)),
    BiotypeBodyPoint(id: 'p3', position: Offset(0.312, 0.413)),
    BiotypeBodyPoint(id: 'p4', position: Offset(0.646, 0.450)),
  ],
};

/// Woman counterpart of [kManBiotypeBodyPoints], measured from
/// `assets/person/type-<N>-woman.png`. Unlike the man set, the woman variants
/// include type 5 (4 points). Dot counts: types 1-4 = 5, type 5 = 4, type 6 = 3,
/// type 7 = 4.
const Map<int, List<BiotypeBodyPoint>> kWomanBiotypeBodyPoints = {
  1: [
    BiotypeBodyPoint(id: 'p1', position: Offset(0.500, 0.073)),
    BiotypeBodyPoint(id: 'p2', position: Offset(0.328, 0.429)),
    BiotypeBodyPoint(id: 'p3', position: Offset(0.808, 0.505)),
    BiotypeBodyPoint(id: 'p4', position: Offset(0.371, 0.606)),
    BiotypeBodyPoint(id: 'p5', position: Offset(0.722, 0.802)),
  ],
  2: [
    BiotypeBodyPoint(id: 'p1', position: Offset(0.493, 0.064)),
    BiotypeBodyPoint(id: 'p2', position: Offset(0.450, 0.330)),
    BiotypeBodyPoint(id: 'p3', position: Offset(0.664, 0.393)),
    BiotypeBodyPoint(id: 'p4', position: Offset(0.306, 0.466)),
    BiotypeBodyPoint(id: 'p5', position: Offset(0.736, 0.475)),
  ],
  3: [
    BiotypeBodyPoint(id: 'p1', position: Offset(0.500, 0.064)),
    BiotypeBodyPoint(id: 'p2', position: Offset(0.192, 0.268)),
    BiotypeBodyPoint(id: 'p3', position: Offset(0.328, 0.436)),
    BiotypeBodyPoint(id: 'p4', position: Offset(0.715, 0.443)),
    BiotypeBodyPoint(id: 'p5', position: Offset(0.278, 0.595)),
  ],
  4: [
    BiotypeBodyPoint(id: 'p1', position: Offset(0.500, 0.078)),
    BiotypeBodyPoint(id: 'p2', position: Offset(0.371, 0.457)),
    BiotypeBodyPoint(id: 'p3', position: Offset(0.786, 0.512)),
    BiotypeBodyPoint(id: 'p4', position: Offset(0.371, 0.590)),
    BiotypeBodyPoint(id: 'p5', position: Offset(0.700, 0.733)),
  ],
  5: [
    BiotypeBodyPoint(id: 'p1', position: Offset(0.478, 0.089)),
    BiotypeBodyPoint(id: 'p2', position: Offset(0.435, 0.356)),
    BiotypeBodyPoint(id: 'p3', position: Offset(0.700, 0.429)),
    BiotypeBodyPoint(id: 'p4', position: Offset(0.228, 0.519)),
  ],
  6: [
    BiotypeBodyPoint(id: 'p1', position: Offset(0.478, 0.080)),
    BiotypeBodyPoint(id: 'p2', position: Offset(0.364, 0.372)),
    BiotypeBodyPoint(id: 'p3', position: Offset(0.651, 0.429)),
  ],
  7: [
    BiotypeBodyPoint(id: 'p1', position: Offset(0.493, 0.057)),
    BiotypeBodyPoint(id: 'p2', position: Offset(0.321, 0.195)),
    BiotypeBodyPoint(id: 'p3', position: Offset(0.300, 0.404)),
    BiotypeBodyPoint(id: 'p4', position: Offset(0.700, 0.429)),
  ],
};

/// Resolves the clickable dot positions for a biotype [number] and gender.
/// Returns an empty list when no reference positions exist (unknown type).
List<BiotypeBodyPoint> biotypeBodyPointsFor({
  required int? number,
  required bool isFemale,
}) {
  if (number == null) return const [];
  final map = isFemale ? kWomanBiotypeBodyPoints : kManBiotypeBodyPoints;
  return map[number] ?? const [];
}
