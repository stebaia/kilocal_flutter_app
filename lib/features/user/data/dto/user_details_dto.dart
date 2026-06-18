import 'package:json_annotation/json_annotation.dart';

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
  });

  @JsonKey(name: 'profile_status')
  final String? profileStatus;

  final String? gender;

  @JsonKey(fromJson: _toInt)
  final int? weight;

  @JsonKey(fromJson: _toInt)
  final int? height;

  final bool? newsletter;

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
    addresses: addresses?.map((e) => e.toDomain()).toList(),
  );
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
