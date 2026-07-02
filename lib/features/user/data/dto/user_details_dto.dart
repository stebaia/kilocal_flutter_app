import 'package:json_annotation/json_annotation.dart';

import '../../../../core/config/env.dart';
import '../../domain/profile_status.dart';
import '../../domain/user_details.dart';

part 'user_details_dto.g.dart';

/// `user_details` node returned by the `GetUserDetails` GraphQL query
/// ([[profilo-read]]).
@JsonSerializable()
class UserDetailsDto {
  const UserDetailsDto({
    this.profileStatus,
    this.gender,
    this.weight,
    this.height,
    this.newsletter,
    this.activeTimeframe,
    this.percorsoAllenamentoCurrStep,
    this.percorsoAlimentazioneCurrStep,
    this.percorsoBenessereCurrStep,
    this.percorsoIntegrazioneCurrPhase,
    this.profile,
    this.allergie,
    this.intolleranze,
    this.dieta,
  });

  @JsonKey(name: 'profile_status')
  final String? profileStatus;

  final String? gender;

  @JsonKey(fromJson: _toInt)
  final int? weight;

  @JsonKey(fromJson: _toInt)
  final int? height;

  final bool? newsletter;

  @JsonKey(fromJson: _toStringList)
  final List<String>? allergie;

  @JsonKey(fromJson: _toStringList)
  final List<String>? intolleranze;

  @JsonKey(fromJson: _toStringList)
  final List<String>? dieta;

  @JsonKey(name: 'active_timeframe')
  final ActiveTimeframeDto? activeTimeframe;

  @JsonKey(name: 'percorso_allenamento_curr_step')
  final int? percorsoAllenamentoCurrStep;

  @JsonKey(name: 'percorso_alimentazione_curr_step')
  final int? percorsoAlimentazioneCurrStep;

  @JsonKey(name: 'percorso_benessere_curr_step')
  final int? percorsoBenessereCurrStep;

  @JsonKey(name: 'percorso_integrazione_curr_phase')
  final PercorsoIntegrazioneCurrPhaseDto? percorsoIntegrazioneCurrPhase;

  /// Body-type profile (`profiles`) — "Il mio Tipo".
  final BiotypeDto? profile;

  factory UserDetailsDto.fromJson(Map<String, dynamic> json) =>
      _$UserDetailsDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UserDetailsDtoToJson(this);

  UserDetails toDomain({List<UserAddressDto>? addresses}) => UserDetails(
    profileStatus: ProfileStatus.fromString(profileStatus),
    gender: gender,
    weight: weight?.toString(),
    height: height?.toString(),
    newsletter: newsletter,
    activeTimeframe: activeTimeframe?.sort,
    percorsoAllenamentoCurrStep: percorsoAllenamentoCurrStep,
    percorsoAlimentazioneCurrStep: percorsoAlimentazioneCurrStep,
    percorsoBenessereCurrStep: percorsoBenessereCurrStep,
    percorsoIntegrazioneCurrPhase: percorsoIntegrazioneCurrPhase?.toDomain(),
    biotype: profile?.toDomain(gender: gender),
    allergie: allergie,
    intolleranze: intolleranze,
    dieta: dieta,
    addresses: addresses?.map((e) => e.toDomain()).toList(),
  );
}

/// Parses a Directus JSON value that may arrive as a `List` or a single value
/// into a `List<String>?`.
List<String>? _toStringList(dynamic value) {
  if (value == null) return null;
  if (value is List) {
    return value.map((e) => e.toString()).toList();
  }
  return [value.toString()];
}

/// Converts an id returned by Directus (which can be either an [int] or a
/// [String]) into a [String?].
String? _idToString(dynamic value) => value?.toString();

/// Parses a value that may arrive as a [num] or as a [String] into an [int?].
int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

@JsonSerializable()
class ActiveTimeframeDto {
  const ActiveTimeframeDto({this.id, this.sort});

  @JsonKey(fromJson: _idToString)
  final String? id;
  final int? sort;

  factory ActiveTimeframeDto.fromJson(Map<String, dynamic> json) =>
      _$ActiveTimeframeDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ActiveTimeframeDtoToJson(this);
}

@JsonSerializable()
class PercorsoIntegrazioneCurrPhaseDto {
  const PercorsoIntegrazioneCurrPhaseDto({
    this.id,
    this.sort,
    this.translations,
  });

  @JsonKey(fromJson: _idToString)
  final String? id;
  final int? sort;
  final List<PhaseTranslationDto>? translations;

  factory PercorsoIntegrazioneCurrPhaseDto.fromJson(
    Map<String, dynamic> json,
  ) => _$PercorsoIntegrazioneCurrPhaseDtoFromJson(json);

  Map<String, dynamic> toJson() =>
      _$PercorsoIntegrazioneCurrPhaseDtoToJson(this);

  PercorsoIntegrazioneCurrPhase toDomain() => PercorsoIntegrazioneCurrPhase(
    id: id,
    sort: sort,
    translations: translations?.map((e) => e.toDomain()).toList(),
  );
}

@JsonSerializable()
class PhaseTranslationDto {
  const PhaseTranslationDto({this.title, this.languagesCode});

  final String? title;

  @JsonKey(name: 'languages_code')
  final LanguageCodeDto? languagesCode;

  factory PhaseTranslationDto.fromJson(Map<String, dynamic> json) =>
      _$PhaseTranslationDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PhaseTranslationDtoToJson(this);

  PhaseTranslation toDomain() =>
      PhaseTranslation(title: title, languageCode: languagesCode?.code);
}

@JsonSerializable()
class LanguageCodeDto {
  const LanguageCodeDto({this.code});

  final String? code;

  factory LanguageCodeDto.fromJson(Map<String, dynamic> json) =>
      _$LanguageCodeDtoFromJson(json);

  Map<String, dynamic> toJson() => _$LanguageCodeDtoToJson(this);
}

/// `profiles` node — the user's body-type ("Il mio Tipo").
@JsonSerializable()
class BiotypeDto {
  const BiotypeDto({
    this.id,
    this.title,
    this.mainColor,
    this.secondaryColor,
    this.icon,
    this.translations,
    this.kit,
  });

  @JsonKey(fromJson: _idToString)
  final String? id;
  final String? title;

  @JsonKey(name: 'main_color')
  final String? mainColor;

  @JsonKey(name: 'secondary_color')
  final String? secondaryColor;

  /// SVG icon file (`profiles.icon`), served at `{baseUrl}/assets/{icon.id}`.
  final BiotypeIconDto? icon;

  final List<BiotypeTranslationDto>? translations;

  final BiotypeKitDto? kit;

  factory BiotypeDto.fromJson(Map<String, dynamic> json) =>
      _$BiotypeDtoFromJson(json);

  Map<String, dynamic> toJson() => _$BiotypeDtoToJson(this);

  Biotype? toDomain({String? gender}) {
    final biotypeId = int.tryParse(id ?? '');
    if (biotypeId == null) return null;

    // Directus stores translations per language; the query does not filter by
    // locale here, so pick the first available translation (single-locale
    // response in practice).
    final translation = translations?.firstOrNull;
    final isFemale = _isFemale(gender);

    // `translations.title` is the ready-to-display label ("Tipo 4"); the slug
    // `title` field ("tipo-4-m") is a fallback only.
    final displayName = translation?.title ?? title ?? '';

    final iconId = icon?.id;

    return Biotype(
      id: biotypeId,
      displayName: displayName,
      denomination: translation?.name,
      iconUrl: iconId != null ? '${Env.baseUrl}/assets/$iconId' : null,
      // The silhouette is a local asset chosen by gender + biotype color
      // (`main_color`), not a CMS file — see [[profiles-biotype-schema]].
      silhouetteAssetName: _silhouetteAsset(
        isFemale: isFemale,
        mainColor: mainColor,
      ),
      description: isFemale
          ? (translation?.contentF ?? translation?.content)
          : translation?.content,
      mainColor: mainColor,
      secondaryColor: secondaryColor,
      kit: kit?.toDomain(),
    );
  }
}

bool _isFemale(String? gender) {
  final g = gender?.toLowerCase();
  return g == 'female' || g == 'f' || g == 'femmina';
}

/// Biotype `main_color` hex → `assets/person/` color name. Values are the fixed
/// palette used by the CMS `profiles` collection.
const _biotypeColorByHex = <String, String>{
  '#00ACAC': 'cyan',
  '#009640': 'green',
  '#EF7900': 'orange',
  '#009FE3': 'azure',
  '#E6007E': 'pink',
  '#82368C': 'purple',
  '#1D71B8': 'blue',
};

/// Resolves the local silhouette asset (`assets/person/<gender>-<color>.png`)
/// from the biotype [mainColor] hex, falling back to the nearest known palette
/// color when the hex is unrecognised, and to `blue` when absent.
String _silhouetteAsset({required bool isFemale, String? mainColor}) {
  final gender = isFemale ? 'woman' : 'man';
  final color = _colorNameFor(mainColor) ?? 'blue';
  return 'assets/person/$gender-$color.png';
}

String? _colorNameFor(String? hex) {
  if (hex == null || hex.isEmpty) return null;
  final normalized = hex.trim().toUpperCase().startsWith('#')
      ? hex.trim().toUpperCase()
      : '#${hex.trim().toUpperCase()}';

  final exact = _biotypeColorByHex[normalized];
  if (exact != null) return exact;

  // Unknown hex: pick the palette entry with the smallest RGB distance.
  final target = _parseRgb(normalized);
  if (target == null) return null;

  String? best;
  var bestDistance = double.infinity;
  _biotypeColorByHex.forEach((paletteHex, name) {
    final rgb = _parseRgb(paletteHex);
    if (rgb == null) return;
    final d = _rgbDistance(target, rgb);
    if (d < bestDistance) {
      bestDistance = d;
      best = name;
    }
  });
  return best;
}

({int r, int g, int b})? _parseRgb(String hex) {
  final value = hex.replaceFirst('#', '');
  if (value.length != 6) return null;
  final parsed = int.tryParse(value, radix: 16);
  if (parsed == null) return null;
  return (r: (parsed >> 16) & 0xFF, g: (parsed >> 8) & 0xFF, b: parsed & 0xFF);
}

double _rgbDistance(({int r, int g, int b}) a, ({int r, int g, int b}) b) {
  final dr = (a.r - b.r).toDouble();
  final dg = (a.g - b.g).toDouble();
  final db = (a.b - b.b).toDouble();
  return dr * dr + dg * dg + db * db;
}

@JsonSerializable()
class BiotypeTranslationDto {
  const BiotypeTranslationDto({
    this.title,
    this.name,
    this.content,
    this.contentF,
    this.languagesCode,
  });

  final String? title;

  /// The biotype denomination shown alongside the number, e.g. "Pera".
  final String? name;
  final String? content;

  @JsonKey(name: 'content_f')
  final String? contentF;

  @JsonKey(name: 'languages_code')
  final LanguageCodeDto? languagesCode;

  factory BiotypeTranslationDto.fromJson(Map<String, dynamic> json) =>
      _$BiotypeTranslationDtoFromJson(json);

  Map<String, dynamic> toJson() => _$BiotypeTranslationDtoToJson(this);
}

@JsonSerializable()
class BiotypeIconDto {
  const BiotypeIconDto({this.id});

  @JsonKey(fromJson: _idToString)
  final String? id;

  factory BiotypeIconDto.fromJson(Map<String, dynamic> json) =>
      _$BiotypeIconDtoFromJson(json);

  Map<String, dynamic> toJson() => _$BiotypeIconDtoToJson(this);
}

@JsonSerializable()
class BiotypeKitDto {
  const BiotypeKitDto({this.id, this.price, this.translations});

  @JsonKey(fromJson: _idToString)
  final String? id;
  final double? price;
  final List<BiotypeKitTranslationDto>? translations;

  factory BiotypeKitDto.fromJson(Map<String, dynamic> json) =>
      _$BiotypeKitDtoFromJson(json);

  Map<String, dynamic> toJson() => _$BiotypeKitDtoToJson(this);

  BiotypeKit? toDomain() {
    if (id == null) return null;
    final translation = translations?.firstOrNull;
    return BiotypeKit(
      id: id!,
      title: translation?.tipoKit,
      description: translation?.description,
      price: price,
    );
  }
}

@JsonSerializable()
class BiotypeKitTranslationDto {
  const BiotypeKitTranslationDto({
    this.description,
    this.tipoKit,
    this.languagesCode,
  });

  final String? description;

  @JsonKey(name: 'tipo_kit')
  final String? tipoKit;

  @JsonKey(name: 'languages_code')
  final LanguageCodeDto? languagesCode;

  factory BiotypeKitTranslationDto.fromJson(Map<String, dynamic> json) =>
      _$BiotypeKitTranslationDtoFromJson(json);

  Map<String, dynamic> toJson() => _$BiotypeKitTranslationDtoToJson(this);
}

@JsonSerializable()
class UserAddressDto {
  const UserAddressDto({
    this.id,
    this.address,
    this.city,
    this.province,
    this.zip,
    this.phone,
  });

  @JsonKey(fromJson: _idToString)
  final String? id;
  final String? address;
  final String? city;
  final String? province;
  final String? zip;
  final String? phone;

  factory UserAddressDto.fromJson(Map<String, dynamic> json) =>
      _$UserAddressDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UserAddressDtoToJson(this);

  UserAddress toDomain() => UserAddress(
    id: id,
    address: address,
    city: city,
    province: province,
    zip: zip,
    phone: phone,
  );
}
