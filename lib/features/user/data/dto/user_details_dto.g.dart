// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_details_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserDetailsDto _$UserDetailsDtoFromJson(Map<String, dynamic> json) =>
    UserDetailsDto(
      profileStatus: json['profile_status'] as String?,
      gender: json['gender'] as String?,
      weight: _toInt(json['weight']),
      height: _toInt(json['height']),
      newsletter: json['newsletter'] as bool?,
      activeTimeframe: json['active_timeframe'] == null
          ? null
          : ActiveTimeframeDto.fromJson(
              json['active_timeframe'] as Map<String, dynamic>,
            ),
      percorsoAllenamentoCurrStep:
          (json['percorso_allenamento_curr_step'] as num?)?.toInt(),
      percorsoAlimentazioneCurrStep:
          (json['percorso_alimentazione_curr_step'] as num?)?.toInt(),
      percorsoBenessereCurrStep: (json['percorso_benessere_curr_step'] as num?)
          ?.toInt(),
      percorsoIntegrazioneCurrPhase:
          json['percorso_integrazione_curr_phase'] == null
          ? null
          : PercorsoIntegrazioneCurrPhaseDto.fromJson(
              json['percorso_integrazione_curr_phase'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$UserDetailsDtoToJson(
  UserDetailsDto instance,
) => <String, dynamic>{
  'profile_status': instance.profileStatus,
  'gender': instance.gender,
  'weight': instance.weight,
  'height': instance.height,
  'newsletter': instance.newsletter,
  'active_timeframe': instance.activeTimeframe,
  'percorso_allenamento_curr_step': instance.percorsoAllenamentoCurrStep,
  'percorso_alimentazione_curr_step': instance.percorsoAlimentazioneCurrStep,
  'percorso_benessere_curr_step': instance.percorsoBenessereCurrStep,
  'percorso_integrazione_curr_phase': instance.percorsoIntegrazioneCurrPhase,
};

ActiveTimeframeDto _$ActiveTimeframeDtoFromJson(Map<String, dynamic> json) =>
    ActiveTimeframeDto(
      id: _idToString(json['id']),
      sort: (json['sort'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ActiveTimeframeDtoToJson(ActiveTimeframeDto instance) =>
    <String, dynamic>{'id': instance.id, 'sort': instance.sort};

PercorsoIntegrazioneCurrPhaseDto _$PercorsoIntegrazioneCurrPhaseDtoFromJson(
  Map<String, dynamic> json,
) => PercorsoIntegrazioneCurrPhaseDto(
  id: _idToString(json['id']),
  sort: (json['sort'] as num?)?.toInt(),
  translations: (json['translations'] as List<dynamic>?)
      ?.map((e) => PhaseTranslationDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$PercorsoIntegrazioneCurrPhaseDtoToJson(
  PercorsoIntegrazioneCurrPhaseDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'sort': instance.sort,
  'translations': instance.translations,
};

PhaseTranslationDto _$PhaseTranslationDtoFromJson(Map<String, dynamic> json) =>
    PhaseTranslationDto(
      title: json['title'] as String?,
      languagesCode: json['languages_code'] == null
          ? null
          : LanguageCodeDto.fromJson(
              json['languages_code'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$PhaseTranslationDtoToJson(
  PhaseTranslationDto instance,
) => <String, dynamic>{
  'title': instance.title,
  'languages_code': instance.languagesCode,
};

LanguageCodeDto _$LanguageCodeDtoFromJson(Map<String, dynamic> json) =>
    LanguageCodeDto(code: json['code'] as String?);

Map<String, dynamic> _$LanguageCodeDtoToJson(LanguageCodeDto instance) =>
    <String, dynamic>{'code': instance.code};

UserAddressDto _$UserAddressDtoFromJson(Map<String, dynamic> json) =>
    UserAddressDto(
      id: _idToString(json['id']),
      address: json['address'] as String?,
      city: json['city'] as String?,
      province: json['province'] as String?,
      zip: json['zip'] as String?,
      phone: json['phone'] as String?,
    );

Map<String, dynamic> _$UserAddressDtoToJson(UserAddressDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'address': instance.address,
      'city': instance.city,
      'province': instance.province,
      'zip': instance.zip,
      'phone': instance.phone,
    };
