import 'package:equatable/equatable.dart';

/// The biotype result carried by `outcome.profile` in the submit response.
///
/// Backend (Daniele Pastori) confirmed the result data lives at
/// `outcome.profile`, but not the shape of the value. Three encodings are
/// plausible and all appear in the wider CMS, so [SurveyOutcome.fromJson]
/// accepts each and normalizes to this entity:
///
///  - an expanded `profiles` row (the collection behind "Il mio Tipo");
///  - a bare profile id, which needs a follow-up read of `profiles`;
///  - a ready-made HTML string to inject into `{{outcome_profile}}`.
///
/// See `wiki/survey.md`. Once backend pins the contract down, the unused
/// branches can go.
class SurveyOutcome extends Equatable {
  const SurveyOutcome({
    this.profileId,
    this.typeLabel,
    this.denomination,
    this.description,
    this.kitImageId,
    this.iconId,
  });

  /// `profiles.id` — set for the expanded-row and bare-id encodings.
  final int? profileId;

  /// The type label, e.g. "Tipo 3" (`profiles.translations.title`).
  final String? typeLabel;

  /// The biotype denomination, e.g. "Pera" (`profiles.translations.name`).
  final String? denomination;

  /// Personalized copy about the user's type (HTML). This is what fills
  /// `{{outcome_profile}}` on the result screen.
  final String? description;

  /// `profiles.kit` asset for the pink Starter Kit card.
  final String? kitImageId;

  /// `profiles.icon` (SVG file id) for the silhouette badge.
  final String? iconId;

  /// True when nothing usable was parsed, so the UI can degrade instead of
  /// rendering an empty shell.
  bool get isEmpty =>
      typeLabel == null &&
      denomination == null &&
      description == null &&
      kitImageId == null;

  /// "Tipo 3 - Pera" for `{{type}}`, falling back to whichever half exists.
  String? get typeDisplay {
    final label = typeLabel;
    final name = denomination;
    if (label == null || label.isEmpty) return name;
    if (name == null || name.isEmpty) return label;
    return '$label - $name';
  }

  /// Parses `outcome.profile` across the three candidate encodings. Returns
  /// `null` when `outcome` carries no `profile` at all.
  static SurveyOutcome? fromJson(Map<String, dynamic>? outcome) {
    if (outcome == null) return null;
    final profile = outcome['profile'];

    // Encoding 3: pre-rendered HTML copy.
    if (profile is String) {
      final html = profile.trim();
      return html.isEmpty ? null : SurveyOutcome(description: html);
    }

    // Encoding 2: a bare id — only the id is knowable here; the caller
    // hydrates the rest from `profiles`.
    if (profile is num) return SurveyOutcome(profileId: profile.toInt());

    // Encoding 1: an expanded `profiles` row.
    if (profile is Map<String, dynamic>) return _fromProfileRow(profile);

    return null;
  }

  static SurveyOutcome _fromProfileRow(Map<String, dynamic> row) {
    final tr = _firstTranslation(row['translations']);
    return SurveyOutcome(
      profileId: (row['id'] as num?)?.toInt(),
      typeLabel: _string(tr?['title']),
      denomination: _string(tr?['name']),
      // `content_f` is the female-specific variant; the API returns the row
      // already resolved for the user, so prefer whichever is populated.
      description: _string(tr?['content']) ?? _string(tr?['content_f']),
      kitImageId: _assetId(row['kit']),
      iconId: _assetId(row['icon']),
    );
  }

  static Map<String, dynamic>? _firstTranslation(dynamic raw) {
    if (raw is List && raw.isNotEmpty) {
      final first = raw.first;
      if (first is Map<String, dynamic>) return first;
    }
    if (raw is Map<String, dynamic>) return raw;
    return null;
  }

  /// Directus relations arrive either expanded (`{ id: … }`) or as a raw
  /// id/uuid, depending on the query's `fields`.
  static String? _assetId(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      return _assetId(raw['image']) ?? _assetId(raw['id']);
    }
    if (raw is num) return raw.toString();
    return _string(raw);
  }

  static String? _string(dynamic raw) {
    if (raw is String && raw.trim().isNotEmpty) return raw.trim();
    return null;
  }

  @override
  List<Object?> get props => [
    profileId,
    typeLabel,
    denomination,
    description,
    kitImageId,
    iconId,
  ];
}
