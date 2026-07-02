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
      profile: json['profile'] == null
          ? null
          : BiotypeDto.fromJson(json['profile'] as Map<String, dynamic>),
      allergie: _toStringList(json['allergie']),
      intolleranze: _toStringList(json['intolleranze']),
      dieta: _toStringList(json['dieta']),
    );

Map<String, dynamic> _$UserDetailsDtoToJson(
  UserDetailsDto instance,
) => <String, dynamic>{
  'profile_status': instance.profileStatus,
  'gender': instance.gender,
  'weight': instance.weight,
  'height': instance.height,
  'newsletter': instance.newsletter,
  'allergie': instance.allergie,
  'intolleranze': instance.intolleranze,
  'dieta': instance.dieta,
  'active_timeframe': instance.activeTimeframe,
  'percorso_allenamento_curr_step': instance.percorsoAllenamentoCurrStep,
  'percorso_alimentazione_curr_step': instance.percorsoAlimentazioneCurrStep,
  'percorso_benessere_curr_step': instance.percorsoBenessereCurrStep,
  'percorso_integrazione_curr_phase': instance.percorsoIntegrazioneCurrPhase,
  'profile': instance.profile,
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

BiotypeDto _$BiotypeDtoFromJson(Map<String, dynamic> json) => BiotypeDto(
  id: _idToString(json['id']),
  title: json['title'] as String?,
  mainColor: json['main_color'] as String?,
  secondaryColor: json['secondary_color'] as String?,
  icon: json['icon'] == null
      ? null
      : BiotypeIconDto.fromJson(json['icon'] as Map<String, dynamic>),
  translations: (json['translations'] as List<dynamic>?)
      ?.map((e) => BiotypeTranslationDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  kit: json['kit'] == null
      ? null
      : BiotypeKitDto.fromJson(json['kit'] as Map<String, dynamic>),
);

Map<String, dynamic> _$BiotypeDtoToJson(BiotypeDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'main_color': instance.mainColor,
      'secondary_color': instance.secondaryColor,
      'icon': instance.icon,
      'translations': instance.translations,
      'kit': instance.kit,
    };

BiotypeTranslationDto _$BiotypeTranslationDtoFromJson(
  Map<String, dynamic> json,
) => BiotypeTranslationDto(
  title: json['title'] as String?,
  name: json['name'] as String?,
  content: json['content'] as String?,
  contentF: json['content_f'] as String?,
  languagesCode: json['languages_code'] == null
      ? null
      : LanguageCodeDto.fromJson(
          json['languages_code'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$BiotypeTranslationDtoToJson(
  BiotypeTranslationDto instance,
) => <String, dynamic>{
  'title': instance.title,
  'name': instance.name,
  'content': instance.content,
  'content_f': instance.contentF,
  'languages_code': instance.languagesCode,
};

BiotypeIconDto _$BiotypeIconDtoFromJson(Map<String, dynamic> json) =>
    BiotypeIconDto(id: _idToString(json['id']));

Map<String, dynamic> _$BiotypeIconDtoToJson(BiotypeIconDto instance) =>
    <String, dynamic>{'id': instance.id};

BiotypeKitDto _$BiotypeKitDtoFromJson(Map<String, dynamic> json) =>
    BiotypeKitDto(
      id: _idToString(json['id']),
      price: (json['price'] as num?)?.toDouble(),
      translations: (json['translations'] as List<dynamic>?)
          ?.map(
            (e) => BiotypeKitTranslationDto.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );

Map<String, dynamic> _$BiotypeKitDtoToJson(BiotypeKitDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'price': instance.price,
      'translations': instance.translations,
    };

BiotypeKitTranslationDto _$BiotypeKitTranslationDtoFromJson(
  Map<String, dynamic> json,
) => BiotypeKitTranslationDto(
  description: json['description'] as String?,
  tipoKit: json['tipo_kit'] as String?,
  languagesCode: json['languages_code'] == null
      ? null
      : LanguageCodeDto.fromJson(
          json['languages_code'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$BiotypeKitTranslationDtoToJson(
  BiotypeKitTranslationDto instance,
) => <String, dynamic>{
  'description': instance.description,
  'tipo_kit': instance.tipoKit,
  'languages_code': instance.languagesCode,
};

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
