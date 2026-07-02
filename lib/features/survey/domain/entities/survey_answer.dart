import 'package:equatable/equatable.dart';

/// A user's answer to a single survey section, held in memory while the wizard
/// is in progress. Serialized into a `SurveyStep` for
/// `POST /survey/submit/{internalName}` at the end.
///
/// The exact submit wire format (steps key, scalar vs object answer, date
/// format) is still pending backend confirmation — see the "Domande aperte al
/// backend" section of `wiki/survey.md`. This entity keeps everything needed to
/// build any of those shapes.
class SurveyAnswer extends Equatable {
  const SurveyAnswer({
    required this.sectionId,
    this.storeToField,
    this.selectedOptionIds = const [],
    this.optionValuesToStore = const [],
    this.textValue,
    this.otherValue,
    this.scaleValue,
  });

  final String sectionId;

  /// `user_details` field name to persist to, when the section stores data.
  final String? storeToField;

  /// Selected option ids for radio/checkbox (radio has at most one).
  final List<String> selectedOptionIds;

  /// The `value_to_store` of each selected option (parallel to
  /// [selectedOptionIds]).
  final List<String> optionValuesToStore;

  /// Raw text for `input` questions.
  final String? textValue;

  /// Free-text captured when an `is_other` option is selected.
  final String? otherValue;

  /// Numeric answer for `scale` questions.
  final int? scaleValue;

  bool get isEmpty =>
      selectedOptionIds.isEmpty &&
      (textValue == null || textValue!.trim().isEmpty) &&
      scaleValue == null;

  SurveyAnswer copyWith({
    List<String>? selectedOptionIds,
    List<String>? optionValuesToStore,
    String? textValue,
    String? otherValue,
    int? scaleValue,
  }) {
    return SurveyAnswer(
      sectionId: sectionId,
      storeToField: storeToField,
      selectedOptionIds: selectedOptionIds ?? this.selectedOptionIds,
      optionValuesToStore: optionValuesToStore ?? this.optionValuesToStore,
      textValue: textValue ?? this.textValue,
      otherValue: otherValue ?? this.otherValue,
      scaleValue: scaleValue ?? this.scaleValue,
    );
  }

  @override
  List<Object?> get props => [
    sectionId,
    storeToField,
    selectedOptionIds,
    optionValuesToStore,
    textValue,
    otherValue,
    scaleValue,
  ];
}

/// Onboarding status returned by `GET /survey/me/status`.
class SurveyStatusInfo extends Equatable {
  const SurveyStatusInfo({
    required this.profileStatus,
    required this.completedSurveys,
    this.userDetailsId,
  });

  /// e.g. `initial_survey`, `type_survey`, `starter_kit`, `active`, …
  final String profileStatus;

  /// `internal_name`s already submitted.
  final List<String> completedSurveys;

  final String? userDetailsId;

  @override
  List<Object?> get props => [profileStatus, completedSurveys, userDetailsId];
}

/// Result of `POST /survey/submit/{internalName}`.
class SurveySubmitResult extends Equatable {
  const SurveySubmitResult({
    required this.surveySubmitId,
    required this.profileStatus,
    this.outcome,
    this.kitShopUrl,
  });

  final String surveySubmitId;
  final String profileStatus;

  /// Scoring outcome (biotype/kit). Shape is CMS-defined — kept as a raw map
  /// until the contract is confirmed with backend.
  final Map<String, dynamic>? outcome;

  /// Suggested kit checkout URL.
  final String? kitShopUrl;

  @override
  List<Object?> get props => [
    surveySubmitId,
    profileStatus,
    outcome,
    kitShopUrl,
  ];
}
