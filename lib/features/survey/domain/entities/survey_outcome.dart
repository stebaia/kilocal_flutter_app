import 'package:equatable/equatable.dart';

/// The biotype result of a survey submit.
///
/// Confirmed against a live `POST /survey/submit/type_survey` (2026-07-16): the
/// response's `outcome.profile` is only a **reference**, not the copy —
/// `{"id": 4, "kit_slug": "kit-tipo-2"}`. The display texts (title, name,
/// content) live in the `profiles` collection and must be hydrated from [id]
/// via GraphQL; see `SurveyRepository.fetchOutcomeProfile`.
///
/// The same submit response also carries the full expanded profile under
/// `legacy`, but that field is documented as "compatibilità client web in
/// migrazione" and will go away — do not read it.
class SurveyOutcome extends Equatable {
  const SurveyOutcome({
    required this.id,
    this.kitSlug,
    this.typeLabel,
    this.denomination,
    this.description,
    this.kitImageId,
    this.iconId,
    this.mainColor,
    this.secondaryColor,
  });

  /// `profiles.id`, the only identity the submit response gives us.
  final int id;

  /// The kit's SEO slug (`kit_slug`), e.g. `kit-tipo-2`.
  final String? kitSlug;

  /// The type label, e.g. "Tipo 2" (`profiles.translations.title`).
  final String? typeLabel;

  /// The biotype denomination, e.g. "Mela" (`profiles.translations.name`).
  final String? denomination;

  /// Personalized copy about the user's type (HTML), gender-aware. Fills
  /// `{{outcome_profile}}` on the result screen.
  final String? description;

  /// Kit image file id, resolved from `profiles.kit.asset.default_asset`.
  final String? kitImageId;

  /// `profiles.icon` (an SVG file id) for the badge.
  final String? iconId;

  /// `profiles.main_color` (CMS hex, e.g. `#009FE3`), used to tint the type
  /// highlight text and the Kit card background to match this biotype.
  final String? mainColor;

  /// `profiles.secondary_color` (CMS hex), the Kit card gradient's other end.
  final String? secondaryColor;

  /// True until the profile has been hydrated with its CMS copy.
  bool get isEmpty => typeLabel == null && denomination == null;

  /// "Tipo 2 - Mela" for `{{type}}`, falling back to whichever half exists.
  String? get typeDisplay {
    final label = typeLabel;
    final name = denomination;
    if (label == null || label.isEmpty) return name;
    if (name == null || name.isEmpty) return label;
    return '$label - $name';
  }

  SurveyOutcome copyWith({
    String? typeLabel,
    String? denomination,
    String? description,
    String? kitImageId,
    String? iconId,
    String? mainColor,
    String? secondaryColor,
  }) {
    return SurveyOutcome(
      id: id,
      kitSlug: kitSlug,
      typeLabel: typeLabel ?? this.typeLabel,
      denomination: denomination ?? this.denomination,
      description: description ?? this.description,
      kitImageId: kitImageId ?? this.kitImageId,
      iconId: iconId ?? this.iconId,
      mainColor: mainColor ?? this.mainColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
    );
  }

  /// Reads the `outcome.profile` reference from a submit response. Returns
  /// `null` when the outcome carries no usable profile id.
  static SurveyOutcome? fromJson(Map<String, dynamic>? outcome) {
    final profile = outcome?['profile'];
    if (profile is! Map<String, dynamic>) return null;
    final id = (profile['id'] as num?)?.toInt();
    if (id == null) return null;
    return SurveyOutcome(id: id, kitSlug: profile['kit_slug'] as String?);
  }

  @override
  List<Object?> get props => [
    id,
    kitSlug,
    typeLabel,
    denomination,
    description,
    kitImageId,
    iconId,
    mainColor,
    secondaryColor,
  ];
}
