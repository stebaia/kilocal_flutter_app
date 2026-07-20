import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

/// A single body-map point text: the anatomical [zone] label plus the
/// bottom-sheet [title] and [body] copy.
class BiotypePointText {
  const BiotypePointText({
    required this.zone,
    required this.title,
    required this.body,
  });

  final String zone;
  final String title;
  final String body;
}

/// All silhouette texts for one biotype + gender: the ordered body-map [points]
/// (index-aligned with the dot positions) and the four path-[areas] texts keyed
/// by area slug (`allenamento`/`alimentazione`/`benessere`/`integrazione`).
class BiotypeTexts {
  const BiotypeTexts({required this.points, required this.areas});

  final List<BiotypePointText> points;
  final Map<String, String> areas;
}

/// Loads the static silhouette texts bundled in `assets/biotype_texts.json`
/// (extracted from the "TESTI SILHOUETTE APP" spreadsheet). Kept local until the
/// backend exposes these texts. The JSON is loaded once and cached.
///
/// Shape: `{ "<number>": { "m"|"f": { points:[{zone,title,body}], areas:{...} } } }`.
/// Point order matches the dot indices in `biotype_body_points.dart`.
class BiotypeTextsLoader {
  BiotypeTextsLoader({this.assetPath = 'assets/biotype_texts.json'});

  final String assetPath;

  Map<String, dynamic>? _cache;

  Future<Map<String, dynamic>> _load() async {
    final cached = _cache;
    if (cached != null) return cached;
    final raw = await rootBundle.loadString(assetPath);
    final decoded = json.decode(raw) as Map<String, dynamic>;
    _cache = decoded;
    return decoded;
  }

  /// Texts for biotype [number] and gender, or `null` when absent (e.g. a
  /// type/gender with no entry). `isFemale` picks the `f` variant, else `m`.
  Future<BiotypeTexts?> forBiotype({
    required int? number,
    required bool isFemale,
  }) async {
    if (number == null) return null;
    final data = await _load();
    final byGender = data['$number'] as Map<String, dynamic>?;
    if (byGender == null) return null;
    // Fall back to the other gender when the requested one is missing (e.g. a
    // man reading a woman-only type should still see something rather than
    // nothing — in practice the gender always exists for valid combinations).
    final entry =
        (byGender[isFemale ? 'f' : 'm'] ?? byGender[isFemale ? 'm' : 'f'])
            as Map<String, dynamic>?;
    if (entry == null) return null;

    final points = (entry['points'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>()
        .map(
          (p) => BiotypePointText(
            zone: p['zone'] as String? ?? '',
            title: p['title'] as String? ?? '',
            body: p['body'] as String? ?? '',
          ),
        )
        .toList();

    final areas = (entry['areas'] as Map<String, dynamic>? ?? {}).map(
      (k, v) => MapEntry(k, v as String? ?? ''),
    );

    return BiotypeTexts(points: points, areas: areas);
  }
}
