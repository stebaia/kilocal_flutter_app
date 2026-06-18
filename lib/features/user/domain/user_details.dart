import 'package:equatable/equatable.dart';

import 'profile_status.dart';

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
  final List<UserAddress>? addresses;

  bool get isToolBlocked => profileStatus.isToolBlocked;

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
    addresses,
  ];
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
