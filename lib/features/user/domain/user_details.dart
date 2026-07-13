import 'package:equatable/equatable.dart';

import 'profile_status.dart';

/// Whether a raw `user_details.gender` value denotes female. The survey stores
/// `m`/`f`/`other`; `f` (case-insensitive) is female, everything else — `m`,
/// `other`, null — is treated as non-female. Single source of truth reused by
/// the data layer and the presentation layer for gender-dependent assets.
bool genderIsFemale(String? gender) => gender?.toLowerCase() == 'f';

/// Detailed profile data returned by `GetUserDetails`.
class UserDetails extends Equatable {
  const UserDetails({
    this.profileStatus = ProfileStatus.unknown,
    this.gender,
    this.weight,
    this.height,
    this.newsletter,
    this.activeTimeframe,
    this.percorsoAllenamentoCurrStep,
    this.percorsoAlimentazioneCurrStep,
    this.percorsoBenessereCurrStep,
    this.percorsoIntegrazioneCurrPhase,
    this.biotype,
    this.allergie,
    this.intolleranze,
    this.dieta,
    this.addresses,
  });

  final ProfileStatus profileStatus;
  final String? gender;
  final String? weight;
  final String? height;
  final bool? newsletter;
  final int? activeTimeframe;
  final int? percorsoAllenamentoCurrStep;
  final int? percorsoAlimentazioneCurrStep;
  final int? percorsoBenessereCurrStep;
  final PercorsoIntegrazioneCurrPhase? percorsoIntegrazioneCurrPhase;

  /// The user's body-type / silhouette ("Il mio Tipo", e.g. "4 - Pera"),
  /// derived from `user_details.profile`. `null` if not yet assigned.
  final Biotype? biotype;

  /// Food-preference multi-selects (`user_details.allergie`/`intolleranze`/
  /// `dieta`), stored as lists of option values.
  final List<String>? allergie;
  final List<String>? intolleranze;
  final List<String>? dieta;

  final List<UserAddress>? addresses;

  bool get isToolBlocked => profileStatus.isToolBlocked;

  /// Whether the user is female, per `user_details.gender` — the survey stores
  /// `m`/`f`/`other` (see wiki survey). `other` and unknown values are treated
  /// as non-female (man silhouette) until the backend specifies otherwise.
  /// Single source of truth for gender-dependent UI (silhouettes, body map).
  bool get isFemale => genderIsFemale(gender);

  @override
  List<Object?> get props => [
    profileStatus,
    gender,
    weight,
    height,
    newsletter,
    activeTimeframe,
    percorsoAllenamentoCurrStep,
    percorsoAlimentazioneCurrStep,
    percorsoBenessereCurrStep,
    percorsoIntegrazioneCurrPhase,
    biotype,
    allergie,
    intolleranze,
    dieta,
    addresses,
  ];
}

/// The user's body-type profile ("Il mio Tipo") from the `profiles` collection.
///
/// [displayName] is the CMS type label, e.g. "Tipo 4" (from
/// `profiles.translations.title` — it already includes the type word and
/// number). [denomination] is the biotype name, e.g. "Pera" (from
/// `translations.name`). [id] is the raw `profiles` id, which is NOT the type
/// number (id 5 ↔ "Tipo 4"), kept only as an identifier. [silhouetteAssetName]
/// is the local person illustration chosen by gender + biotype color (see
/// [[profiles-biotype-schema]]), [description] the "Le tue caratteristiche"
/// copy, [kit] the recommended kit.
class Biotype extends Equatable {
  const Biotype({
    required this.id,
    required this.displayName,
    this.denomination,
    this.iconUrl,
    this.silhouetteAssetName,
    this.silhouetteCleanAssetName,
    this.description,
    this.mainColor,
    this.secondaryColor,
    this.kit,
  });

  final int id;
  final String displayName;
  final String? denomination;

  /// Full URL to the biotype SVG icon (`{baseUrl}/assets/{profile.icon.id}`),
  /// tinted with [mainColor]. `null` when the biotype has no icon.
  final String? iconUrl;

  final String? silhouetteAssetName;

  /// Full-color, dot-free silhouette asset chosen by gender + biotype number
  /// (`assets/person/<gender>-type<N>.png`), used by the interactive
  /// "characteristics" body map where the clickable dots are drawn as widgets
  /// on top. `null` when no clean asset exists for this type/gender.
  final String? silhouetteCleanAssetName;

  final String? description;
  final String? mainColor;
  final String? secondaryColor;
  final BiotypeKit? kit;

  /// The numeric type index parsed from [displayName] ("Tipo 4" → 4). Falls back
  /// to `null` when the label carries no number.
  int? get number =>
      int.tryParse(RegExp(r'\d+').firstMatch(displayName)?.group(0) ?? '');

  /// Concise label for the profile card, e.g. "Tipo 4 - Pera" (falls back to
  /// [displayName] when the denomination is missing).
  String get label => denomination != null && denomination!.isNotEmpty
      ? '$displayName - $denomination'
      : displayName;

  /// Builds the screen header, e.g. "Il mio Tipo - 4 Pera". Uses [myTypeWord]
  /// ("Il mio Tipo") and appends the number and [denomination] when available,
  /// otherwise falls back to [displayName].
  String header(String myTypeWord) {
    final parts = <String>[
      if (number != null) '$number',
      if (denomination != null && denomination!.isNotEmpty) denomination!,
    ];
    if (parts.isEmpty) return '$myTypeWord - $displayName';
    return '$myTypeWord - ${parts.join(' ')}';
  }

  @override
  List<Object?> get props => [
    id,
    displayName,
    denomination,
    iconUrl,
    silhouetteAssetName,
    silhouetteCleanAssetName,
    description,
    mainColor,
    secondaryColor,
    kit,
  ];
}

/// Recommended kit for a [Biotype] (`profiles.kit` → `product_kits`).
class BiotypeKit extends Equatable {
  const BiotypeKit({
    required this.id,
    this.title,
    this.description,
    this.price,
  });

  final String id;
  final String? title;
  final String? description;
  final double? price;

  @override
  List<Object?> get props => [id, title, description, price];
}

class PercorsoIntegrazioneCurrPhase extends Equatable {
  const PercorsoIntegrazioneCurrPhase({this.id, this.sort, this.translations});

  final String? id;
  final int? sort;
  final List<PhaseTranslation>? translations;

  @override
  List<Object?> get props => [id, sort, translations];
}

class PhaseTranslation extends Equatable {
  const PhaseTranslation({this.title, this.languageCode});

  final String? title;
  final String? languageCode;

  @override
  List<Object?> get props => [title, languageCode];
}

class UserAddress extends Equatable {
  const UserAddress({
    this.id,
    this.address,
    this.city,
    this.province,
    this.zip,
    this.phone,
  });

  final String? id;
  final String? address;
  final String? city;
  final String? province;
  final String? zip;
  final String? phone;

  @override
  List<Object?> get props => [id, address, city, province, zip, phone];
}
