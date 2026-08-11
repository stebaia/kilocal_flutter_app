import '../../user/domain/user_details.dart';
import '../domain/entities/pharmacy.dart';
import '../domain/entities/survey_answer.dart';
import '../domain/entities/survey_outcome.dart';
import '../domain/entities/survey_step.dart';

/// Maps the raw GraphQL/REST JSON of the survey domain into entities, and builds
/// the submit body. Kept as free functions (matching `cms_form_mapper.dart`).

Survey mapSurvey(Map<String, dynamic> json) {
  final rawSections = json['sections'] as List<dynamic>? ?? const [];
  final sections =
      rawSections
          .map((e) => _mapSection(e as Map<String, dynamic>))
          .whereType<SurveySection>()
          .toList()
        ..sort((a, b) => a.sort.compareTo(b.sort));

  return Survey(
    id: json['id']?.toString() ?? '',
    internalName: json['internal_name'] as String? ?? '',
    sections: sections,
  );
}

SurveySection? _mapSection(Map<String, dynamic> junction) {
  final section = junction['survey_sections_id'] as Map<String, dynamic>?;
  if (section == null) return null;

  final tr = _first(section['translations']);
  final cta = _first(section['default_cta_translations']);
  final answer = section['possible_answer'] as Map<String, dynamic>?;

  return SurveySection(
    id: section['id']?.toString() ?? '',
    sort: (junction['sort'] as num?)?.toInt() ?? 0,
    conditionAction: section['condition_action'] as String? ?? 'show',
    useCustomCta: section['use_custom_cta'] as bool? ?? false,
    storeInUserData: section['store_in_user_data'] as bool? ?? false,
    userDataFieldName: section['user_data_field_name'] as String?,
    showAsDropdown: section['show_as_dropdown'] as bool? ?? false,
    singleProductBarcodeCheck:
        section['single_product_barcode_check'] as bool? ?? false,
    showSingleProductCta: section['show_single_product_cta'] as bool? ?? false,
    loadKilocalPoints: section['load_kilocal_points'] as bool? ?? false,
    isDobQuestion: section['is_dob_question'] as bool? ?? false,
    isGenderQuestion: section['is_gender_question'] as bool? ?? false,
    isMenopausaQuestion: section['is_menopausa_question'] as bool? ?? false,
    smallNotificationText: section['small_notification_text'] as String?,
    title: tr?['title'] as String?,
    subtitle: tr?['subtitle'] as String?,
    content: tr?['content'] as String?,
    ctaLabel: cta?['label'] as String?,
    question: answer == null ? null : _mapQuestion(answer),
    conditions: _mapConditions(section['conditions']),
  );
}

SurveyQuestion _mapQuestion(Map<String, dynamic> json) {
  final textTr = _first(json['text_translations']);
  final scaleTr = _first(json['scale_translations']);
  final scale = _scaleBounds(json['scale_values']);

  final rawOptions = json['options'] as List<dynamic>? ?? const [];
  final options =
      rawOptions
          .map((e) => _mapOption(e as Map<String, dynamic>))
          .whereType<SurveyOption>()
          .toList()
        ..sort((a, b) => a.sort.compareTo(b.sort));

  return SurveyQuestion(
    id: json['id']?.toString() ?? '',
    type: _answerType(json['type'] as String?),
    inputType: _inputType(json['input_type'] as String?),
    required: json['required'] as bool? ?? false,
    placeholder: textTr?['placeholder'] as String?,
    otherValidations: json['other_validations'] as String?,
    scaleFrom: scale?.$1,
    scaleTo: scale?.$2,
    scaleInitialLabel: scaleTr?['initial_label'] as String?,
    scaleFinalLabel: scaleTr?['final_label'] as String?,
    resultValue: json['result_value'] as String?,
    options: options,
  );
}

SurveyOption? _mapOption(Map<String, dynamic> junction) {
  final option =
      junction['survey_question_options_id'] as Map<String, dynamic>?;
  if (option == null) return null;
  final tr = _first(option['translations']);
  return SurveyOption(
    id: option['id']?.toString() ?? '',
    sort: (option['sort'] as num?)?.toInt() ?? 0,
    isOther: option['is_other'] as bool? ?? false,
    deselectOthers: option['deselect_others'] as bool? ?? false,
    text: tr?['text'] as String?,
    valueToStore: option['value_to_store'] as String?,
    resultValue: option['result_value'] as String?,
    warningWhenSelected: tr?['warning_when_selected'] as String?,
  );
}

List<SurveyCondition> _mapConditions(dynamic raw) {
  final list = raw as List<dynamic>? ?? const [];
  final out = <SurveyCondition>[];
  for (final e in list) {
    // The junction row can dangle (condition deleted) — guard for null.
    final cond =
        (e as Map<String, dynamic>)['survey_section_conditions_id']
            as Map<String, dynamic>?;
    if (cond == null) continue;
    final value = cond['value'] as Map<String, dynamic>?;
    final values = (cond['values'] as List<dynamic>? ?? const [])
        .map(
          (v) =>
              ((v as Map<String, dynamic>)['survey_question_options_id']
                      as Map<String, dynamic>?)?['id']
                  ?.toString(),
        )
        .whereType<String>()
        .toList();
    out.add(
      SurveyCondition(
        condition: cond['condition'] as String? ?? '_eq',
        simpleValue: cond['simple_value'] as String?,
        valueOptionId: value?['id']?.toString(),
        valueOptionIds: values,
      ),
    );
  }
  return out;
}

/// Maps a `modals` singleton row to [SurveyAlertModal].
SurveyAlertModal mapAlertModal(Map<String, dynamic> json) {
  final tr = _first(json['translations']);
  return SurveyAlertModal(
    title: tr?['title'] as String?,
    content: tr?['content'] as String?,
  );
}

SurveyStatusInfo mapStatus(Map<String, dynamic> json) {
  return SurveyStatusInfo(
    profileStatus: json['profile_status'] as String? ?? '',
    completedSurveys: (json['completed_surveys'] as List<dynamic>? ?? const [])
        .map((e) => e.toString())
        .toList(),
    userDetailsId: json['user_details_id']?.toString(),
  );
}

SurveyMonthEndPending mapMonthEndPending(Map<String, dynamic> json) {
  return SurveyMonthEndPending(
    month: (json['month'] as num?)?.toInt() ?? 0,
    internalName: json['internal_name'] as String? ?? '',
    goalInternalName: json['goal_internal_name'] as String? ?? '',
    slug: json['slug'] as String?,
    userReminderId: json['user_reminder_id']?.toString(),
  );
}

Pharmacy mapPharmacy(Map<String, dynamic> json) {
  return Pharmacy(
    id: json['id']?.toString() ?? '',
    title: json['title'] as String?,
    address: json['address'] as String?,
    city: json['city'] as String?,
    province: json['province'] as String?,
    zip: json['zip'] as String?,
    region: json['region'] as String?,
    storeId: json['store_id']?.toString(),
  );
}

/// Fills [outcome] with the CMS copy of its `profiles` row.
///
/// `translations.title` is the display label ("Tipo 2") and `name` the
/// denomination ("Mela"); [gender] picks the `content_f` variant for female
/// profiles, matching `BiotypeDto.toDomain`.
SurveyOutcome mapOutcomeProfile(
  SurveyOutcome outcome,
  Map<String, dynamic> row, {
  String? gender,
}) {
  final tr = _first(row['translations']);
  final isFemale = genderIsFemale(gender);
  final kitAsset = (row['kit'] as Map<String, dynamic>?)?['asset'];
  final defaultAsset =
      (kitAsset as Map<String, dynamic>?)?['default_asset']
          as Map<String, dynamic>?;

  return outcome.copyWith(
    typeLabel: tr?['title'] as String?,
    denomination: tr?['name'] as String?,
    description: isFemale
        ? (tr?['content_f'] as String? ?? tr?['content'] as String?)
        : tr?['content'] as String?,
    kitImageId: defaultAsset?['id']?.toString(),
    iconId: (row['icon'] as Map<String, dynamic>?)?['id']?.toString(),
    mainColor: row['main_color'] as String?,
    secondaryColor: row['secondary_color'] as String?,
  );
}

SurveySubmitResult mapSubmitResult(Map<String, dynamic> json) {
  return SurveySubmitResult(
    surveySubmitId: json['survey_submit_id']?.toString() ?? '',
    profileStatus: json['profile_status'] as String? ?? '',
    outcome: json['outcome'] as Map<String, dynamic>?,
    kitShopUrl: json['kit_shop_url'] as String?,
  );
}

/// Builds the `SurveySubmitBody` for `POST /survey/submit/{internalName}`.
///
/// Wire format confirmed by backend (Daniele Pastori) with a real fixture — see
/// [[survey-domande-backend]]:
///  - `steps` is keyed by the **question id** (`section.question.id`), not the
///    section id; each step also carries `sectionId` internally.
///  - `storeToField` = `user_data_field_name` when `store_in_user_data` is true,
///    else `null` — and is always present (answers without it still contribute
///    to the outcome/biotype scoring).
///  - Only answerable sections (with a `possible_answer`) produce a step;
///    info/intermezzo/result sections are skipped.
///  - radio/checkbox answers → `{ id, value_to_store }` (single object for
///    radio, array for checkbox), plus `is_other` / `other_value` on the "Altro"
///    option; input/scale answers → the raw scalar.
///  - `bmi` = weight(kg) / height(m)^2 (float); `ageValue` = whole years.
///  - `pharmacy_data` = the selected [Pharmacy] object (`load_kilocal_points`
///    step); `single_product_id` = the numeric product id from the answer to
///    the `show_as_dropdown` product question (its option `value_to_store`).
Map<String, dynamic> buildSubmitBody({
  required List<SurveyAnswer> answers,
  required Survey survey,
  Pharmacy? pharmacy,
}) {
  final steps = <String, dynamic>{};
  double? heightCm;
  double? weightKg;
  DateTime? dob;
  Object? singleProductId;

  final sectionById = {for (final s in survey.sections) s.id: s};

  for (final a in answers) {
    if (a.isEmpty) continue;
    final section = sectionById[a.sectionId];
    final question = section?.question;
    // Only answerable sections produce a step (info/result screens don't).
    if (section == null || question == null) continue;

    // Map key = question id; storeToField null unless the section persists data.
    final storeToField = section.storeInUserData
        ? section.userDataFieldName
        : null;
    steps[question.id] = _stepPayload(
      a,
      section: section,
      question: question,
      storeToField: storeToField,
    );

    // Collect the pieces needed for bmi / ageValue.
    if (a.textValue != null) {
      if (section.isDobQuestion) {
        dob = DateTime.tryParse(a.textValue!);
      } else if (section.userDataFieldName == 'height') {
        heightCm = double.tryParse(a.textValue!.replaceAll(',', '.'));
      } else if (section.userDataFieldName == 'weight') {
        weightKg = double.tryParse(a.textValue!.replaceAll(',', '.'));
      }
    }

    // The product dropdown answer carries the product id in value_to_store.
    if (section.showAsDropdown && a.optionValuesToStore.isNotEmpty) {
      final raw = a.optionValuesToStore.first;
      if (raw.isNotEmpty) singleProductId = int.tryParse(raw) ?? raw;
    }
  }

  final body = <String, dynamic>{
    'bmi': _computeBmi(heightCm: heightCm, weightKg: weightKg),
    'steps': steps,
    'pharmacy_data': pharmacy?.toSubmitJson(),
    'single_product_id': singleProductId,
  };
  final age = _computeAge(dob);
  if (age != null) body['ageValue'] = age;
  return body;
}

Map<String, dynamic> _stepPayload(
  SurveyAnswer a, {
  required SurveySection section,
  required SurveyQuestion question,
  required String? storeToField,
}) {
  // The backend fixture uses numeric ids where possible; fall back to the raw
  // string for non-numeric ids.
  final step = <String, dynamic>{
    'sectionId': _numOrString(section.id),
    'storeToField': storeToField,
  };

  switch (question.type) {
    case SurveyAnswerType.radio:
    case SurveyAnswerType.checkbox:
      final byId = {for (final o in question.options) o.id: o};
      final selected = <Map<String, dynamic>>[];
      for (final id in a.selectedOptionIds) {
        final opt = byId[id];
        selected.add({
          'id': _numOrString(id),
          if (opt?.valueToStore != null) 'value_to_store': opt!.valueToStore,
          if (opt?.isOther ?? false) ...{
            'is_other': true,
            if (a.otherValue != null) 'other_value': a.otherValue,
          },
        });
      }
      // Single-choice radio submits a single object; checkbox an array.
      step['answer'] = question.type == SurveyAnswerType.radio
          ? (selected.isNotEmpty ? selected.first : null)
          : selected;
    case SurveyAnswerType.scale:
      step['answer'] = a.scaleValue;
    case SurveyAnswerType.input:
    case SurveyAnswerType.unknown:
      step['answer'] = a.textValue;
  }
  return step;
}

/// Returns the numeric form of a CMS id when it parses as an int, else the raw
/// string. Matches the backend fixture, which sends `sectionId`/`id` as numbers.
Object _numOrString(String id) => int.tryParse(id) ?? id;

/// bmi = weight(kg) / height(m)^2, 1 decimal. Null when inputs are missing.
num? _computeBmi({double? heightCm, double? weightKg}) {
  if (heightCm == null || weightKg == null || heightCm <= 0) return null;
  final m = heightCm / 100.0;
  return double.parse((weightKg / (m * m)).toStringAsFixed(1));
}

int? _computeAge(DateTime? dob) {
  if (dob == null) return null;
  final now = DateTime.now();
  var age = now.year - dob.year;
  if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
    age--;
  }
  return age;
}

(int, int)? _scaleBounds(dynamic scaleValues) {
  // scale_values is JSON like [{ "from": 0, "to": 10 }].
  if (scaleValues is List && scaleValues.isNotEmpty) {
    final first = scaleValues.first;
    if (first is Map) {
      final from = (first['from'] as num?)?.toInt();
      final to = (first['to'] as num?)?.toInt();
      if (from != null && to != null) return (from, to);
    }
  }
  return null;
}

SurveyAnswerType _answerType(String? raw) {
  switch (raw) {
    case 'radio':
      return SurveyAnswerType.radio;
    case 'checkbox':
      return SurveyAnswerType.checkbox;
    case 'input':
      return SurveyAnswerType.input;
    case 'scale':
      return SurveyAnswerType.scale;
    default:
      return SurveyAnswerType.unknown;
  }
}

SurveyInputType _inputType(String? raw) {
  switch (raw) {
    case 'text':
      return SurveyInputType.text;
    case 'number':
      return SurveyInputType.number;
    case 'date':
      return SurveyInputType.date;
    default:
      return SurveyInputType.unknown;
  }
}

Map<String, dynamic>? _first(dynamic list) {
  if (list is List && list.isNotEmpty) {
    return list.first as Map<String, dynamic>;
  }
  return null;
}
