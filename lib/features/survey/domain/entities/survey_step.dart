import 'package:equatable/equatable.dart';

/// Domain entities for the CMS-driven survey/onboarding flow.
///
/// These mirror the Directus `surveys` → `survey_sections` → `survey_question`
/// → `survey_question_options` model (read via GraphQL, verified against
/// staging). See `wiki/survey.md`. Nothing here is mocked: every field maps to a
/// real CMS column.

/// A whole survey addressed by its CMS `internal_name` (e.g. `type_survey`).
class Survey extends Equatable {
  const Survey({
    required this.id,
    required this.internalName,
    required this.sections,
  });

  final String id;
  final String internalName;

  /// Ordered sections (by `sort`).
  final List<SurveySection> sections;

  @override
  List<Object?> get props => [id, internalName, sections];
}

/// The kind of screen a section renders, derived from the CMS shape rather than
/// stored explicitly. See [SurveySection.kind].
enum SurveySectionKind {
  /// No `possible_answer` and no custom CTA — plain informational copy.
  info,

  /// No `possible_answer` but `use_custom_cta` — result/intro screens with
  /// templated copy (`{{name}}`, `{{type}}`, `{{product}}`).
  result,

  /// A question with a `possible_answer` (radio/checkbox/input/scale).
  question,
}

/// The answer widget for a question section.
enum SurveyAnswerType { radio, checkbox, input, scale, unknown }

/// The text-input keyboard/parsing hint for `input` questions.
enum SurveyInputType { text, number, date, unknown }

/// One survey section: a single screen in the wizard.
class SurveySection extends Equatable {
  const SurveySection({
    required this.id,
    required this.sort,
    required this.conditionAction,
    required this.useCustomCta,
    required this.storeInUserData,
    required this.showAsDropdown,
    required this.singleProductBarcodeCheck,
    required this.showSingleProductCta,
    required this.loadKilocalPoints,
    required this.isDobQuestion,
    required this.isGenderQuestion,
    required this.isMenopausaQuestion,
    required this.conditions,
    this.userDataFieldName,
    this.smallNotificationText,
    this.title,
    this.subtitle,
    this.content,
    this.ctaLabel,
    this.question,
  });

  final String id;
  final int sort;

  /// `"show"` (default) or `"hide"` — how [conditions] gate this section.
  final String conditionAction;

  final bool useCustomCta;

  /// When true the answer is persisted server-side to `user_details`
  /// ([userDataFieldName]).
  final bool storeInUserData;
  final String? userDataFieldName;

  final bool showAsDropdown;
  final bool singleProductBarcodeCheck;
  final bool showSingleProductCta;
  final bool loadKilocalPoints;

  /// Semantic flags the CMS sets for the fixed onboarding questions.
  final bool isDobQuestion;
  final bool isGenderQuestion;
  final bool isMenopausaQuestion;

  final String? smallNotificationText;

  /// Localized copy (HTML). [title] is always shown; [subtitle]/[content] are
  /// supporting copy when present.
  final String? title;
  final String? subtitle;
  final String? content;

  /// Localized default CTA label (`"Avanti"`, `"Inizia"`, …).
  final String? ctaLabel;

  /// Null for [SurveySectionKind.info] / [SurveySectionKind.result] sections.
  final SurveyQuestion? question;

  /// Conditions that gate visibility of this section (evaluated against prior
  /// answers together with [conditionAction]).
  final List<SurveyCondition> conditions;

  SurveySectionKind get kind {
    if (question != null) return SurveySectionKind.question;
    if (useCustomCta) return SurveySectionKind.result;
    return SurveySectionKind.info;
  }

  @override
  List<Object?> get props => [id, sort, question, conditions, title];
}

/// A gate on a section's visibility. Currently the CMS only expresses equality
/// against selected option ids (e.g. show "menopausa" only if gender == female).
class SurveyCondition extends Equatable {
  const SurveyCondition({
    required this.condition,
    this.simpleValue,
    this.valueOptionId,
    this.valueOptionIds = const [],
  });

  /// Directus operator, e.g. `_eq`.
  final String condition;
  final String? simpleValue;

  /// Single option id the condition compares against.
  final String? valueOptionId;

  /// Multiple option ids (`values` M2M), when the condition is a set.
  final List<String> valueOptionIds;

  @override
  List<Object?> get props => [
    condition,
    simpleValue,
    valueOptionId,
    valueOptionIds,
  ];
}

/// The answerable part of a section.
class SurveyQuestion extends Equatable {
  const SurveyQuestion({
    required this.id,
    required this.type,
    required this.inputType,
    required this.required,
    required this.options,
    this.placeholder,
    this.otherValidations,
    this.scaleFrom,
    this.scaleTo,
    this.scaleInitialLabel,
    this.scaleFinalLabel,
    this.resultValue,
  });

  final String id;
  final SurveyAnswerType type;
  final SurveyInputType inputType;
  final bool required;

  /// Localized placeholder for `input` questions.
  final String? placeholder;

  /// Zod-style validation string (e.g. `number|int|gte:100|lte:300`) for
  /// `input` questions.
  final String? otherValidations;

  /// `scale` bounds and endpoint labels.
  final int? scaleFrom;
  final int? scaleTo;
  final String? scaleInitialLabel;
  final String? scaleFinalLabel;

  final String? resultValue;

  /// Options for `radio` / `checkbox` (empty otherwise).
  final List<SurveyOption> options;

  @override
  List<Object?> get props => [id, type, inputType, options];
}

/// The two `result_value` markers a CMS option can carry, gating whether the
/// wizard may continue past it. Any other value (including null) is a plain
/// biotype score and has no effect on navigation.
enum SurveyResultAction {
  /// `#stop#` — the user cannot proceed; the wizard jumps to the survey's
  /// last section and shows dedicated copy instead of continuing.
  stop,

  /// `#alert#` — the user is warned via [SurveyAlertModal] but may confirm
  /// and continue.
  alert,
}

/// CMS copy (title/content) for the confirmation dialog shown when an
/// `#alert#` option is selected (`alert_survey_risky_selection_modal`).
class SurveyAlertModal extends Equatable {
  const SurveyAlertModal({required this.title, required this.content});

  final String? title;
  final String? content;

  @override
  List<Object?> get props => [title, content];
}

/// A selectable answer option.
class SurveyOption extends Equatable {
  const SurveyOption({
    required this.id,
    required this.sort,
    required this.isOther,
    required this.deselectOthers,
    this.text,
    this.valueToStore,
    this.resultValue,
    this.warningWhenSelected,
  });

  final String id;
  final int sort;

  /// When selected, prompts the user for a free-text value.
  final bool isOther;

  /// When selected in a checkbox question, clears the other options
  /// (e.g. "Nessuna").
  final bool deselectOthers;

  final String? text;

  /// Value persisted server-side when this option is chosen.
  final String? valueToStore;
  final String? resultValue;

  /// Warning surfaced to the user when this option is selected.
  final String? warningWhenSelected;

  /// `resultValue` parsed as a gating marker (`#stop#` / `#alert#`), or `null`
  /// when it is a plain biotype score (or absent).
  SurveyResultAction? get resultAction {
    switch (resultValue) {
      case '#stop#':
        return SurveyResultAction.stop;
      case '#alert#':
        return SurveyResultAction.alert;
      default:
        return null;
    }
  }

  @override
  List<Object?> get props => [id, text, valueToStore];
}
