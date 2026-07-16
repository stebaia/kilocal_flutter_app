/// Evaluates the CMS `survey_question.other_validations` grammar.
///
/// The rule is a `|`-separated list of tokens, e.g.
/// `number|int|gte:100|lte:300`. Verified live (2026-07-16) — the CMS only ever
/// uses these six rules:
///
/// | Rule | Question |
/// |------|----------|
/// | `number\|int\|gte:100\|lte:300` | height (cm) |
/// | `number\|lte:300\|gte:30\|bmi:17.5` | weight (kg) |
/// | `date\|max:{-18years}\|min:1900-01-01` | date of birth |
/// | `zip_code` | CAP |
/// | `phone` | phone number |
/// | `barcode` | starter kit proof of purchase |
///
/// `barcode` is **not** handled here: it means "matches a code in the products
/// catalogue", which needs a network read — see `SurveyBarcodeValidator`.
///
/// Unknown tokens are ignored on purpose: a rule we cannot interpret must never
/// block the user.
library;

/// The outcome of validating one answer.
enum SurveyValidationError {
  notANumber,
  notAnInteger,
  tooSmall,
  tooLarge,
  notADate,
  dateTooLate,
  dateTooEarly,
  bmiTooLow,
  invalidZipCode,
  invalidPhone,
}

/// A parsed `other_validations` rule.
class SurveyValidationRule {
  const SurveyValidationRule({
    this.isNumber = false,
    this.isInt = false,
    this.isDate = false,
    this.isZipCode = false,
    this.isPhone = false,
    this.isBarcode = false,
    this.gte,
    this.lte,
    this.minDate,
    this.maxAgeYears,
    this.minBmi,
  });

  final bool isNumber;
  final bool isInt;
  final bool isDate;
  final bool isZipCode;
  final bool isPhone;

  /// Requires an async catalogue check; see `SurveyBarcodeValidator`.
  final bool isBarcode;

  final num? gte;
  final num? lte;
  final DateTime? minDate;

  /// From `max:{-18years}` — the value must be at least this many years ago.
  final int? maxAgeYears;

  /// From `bmi:17.5` — the resulting BMI must not fall below this.
  final num? minBmi;

  static const empty = SurveyValidationRule();

  bool get isEmpty =>
      !isNumber &&
      !isInt &&
      !isDate &&
      !isZipCode &&
      !isPhone &&
      !isBarcode &&
      gte == null &&
      lte == null &&
      minDate == null &&
      maxAgeYears == null &&
      minBmi == null;

  /// Parses a raw `other_validations` string. Unknown tokens are skipped.
  factory SurveyValidationRule.parse(String? raw) {
    if (raw == null || raw.trim().isEmpty) return empty;

    var isNumber = false;
    var isInt = false;
    var isDate = false;
    var isZipCode = false;
    var isPhone = false;
    var isBarcode = false;
    num? gte;
    num? lte;
    DateTime? minDate;
    int? maxAgeYears;
    num? minBmi;

    for (final token in raw.split('|')) {
      final t = token.trim();
      if (t.isEmpty) continue;

      switch (t) {
        case 'number':
          isNumber = true;
          continue;
        case 'int':
          isInt = true;
          continue;
        case 'date':
          isDate = true;
          continue;
        case 'zip_code':
          isZipCode = true;
          continue;
        case 'phone':
          isPhone = true;
          continue;
        case 'barcode':
          isBarcode = true;
          continue;
      }

      final sep = t.indexOf(':');
      if (sep < 0) continue;
      final key = t.substring(0, sep);
      final value = t.substring(sep + 1);

      switch (key) {
        case 'gte':
          gte = num.tryParse(value);
        case 'lte':
          lte = num.tryParse(value);
        case 'bmi':
          minBmi = num.tryParse(value);
        case 'min':
          minDate = DateTime.tryParse(value);
        case 'max':
          // Only the relative `{-18years}` form appears in the CMS.
          final years = RegExp(r'^\{-(\d+)years\}$').firstMatch(value);
          if (years != null) maxAgeYears = int.tryParse(years.group(1)!);
      }
    }

    return SurveyValidationRule(
      isNumber: isNumber,
      isInt: isInt,
      isDate: isDate,
      isZipCode: isZipCode,
      isPhone: isPhone,
      isBarcode: isBarcode,
      gte: gte,
      lte: lte,
      minDate: minDate,
      maxAgeYears: maxAgeYears,
      minBmi: minBmi,
    );
  }

  /// Validates [value], or returns `null` when it satisfies the rule.
  ///
  /// An empty [value] is always accepted here — "answer required" is a separate
  /// concern ([SurveyQuestion.required]) and reporting a format error on a
  /// field the user has not filled yet would be noise.
  ///
  /// [heightCm] supplies the other half of the `bmi` rule; without it the BMI
  /// bound is skipped rather than guessed.
  /// [now] is injectable so the age bound is testable.
  SurveyValidationError? validate(
    String? value, {
    double? heightCm,
    DateTime? now,
  }) {
    final raw = value?.trim() ?? '';
    if (raw.isEmpty) return null;

    if (isDate) return _validateDate(raw, now ?? DateTime.now());
    if (isZipCode) {
      // Italian CAP: exactly five digits.
      return RegExp(r'^\d{5}$').hasMatch(raw)
          ? null
          : SurveyValidationError.invalidZipCode;
    }
    if (isPhone) {
      // Permissive on purpose: digits, with optional +/spaces/dashes.
      final digits = raw.replaceAll(RegExp(r'[\s\-.()]'), '');
      return RegExp(r'^\+?\d{8,15}$').hasMatch(digits)
          ? null
          : SurveyValidationError.invalidPhone;
    }
    if (isNumber || isInt || gte != null || lte != null) {
      return _validateNumber(raw, heightCm: heightCm);
    }
    return null;
  }

  SurveyValidationError? _validateNumber(String raw, {double? heightCm}) {
    // The CMS uses `.`; users type either separator.
    final parsed = num.tryParse(raw.replaceAll(',', '.'));
    if (parsed == null) return SurveyValidationError.notANumber;
    if (isInt && parsed != parsed.roundToDouble()) {
      return SurveyValidationError.notAnInteger;
    }
    if (gte != null && parsed < gte!) return SurveyValidationError.tooSmall;
    if (lte != null && parsed > lte!) return SurveyValidationError.tooLarge;

    // `bmi:17.5` guards against an underweight target: weight / height(m)^2.
    if (minBmi != null && heightCm != null && heightCm > 0) {
      final m = heightCm / 100.0;
      if (parsed / (m * m) < minBmi!) return SurveyValidationError.bmiTooLow;
    }
    return null;
  }

  SurveyValidationError? _validateDate(String raw, DateTime now) {
    final date = DateTime.tryParse(raw);
    if (date == null) return SurveyValidationError.notADate;
    if (minDate != null && date.isBefore(minDate!)) {
      return SurveyValidationError.dateTooEarly;
    }
    if (maxAgeYears != null) {
      // `max:{-18years}` → must be born on or before this day.
      final latest = DateTime(now.year - maxAgeYears!, now.month, now.day);
      if (date.isAfter(latest)) return SurveyValidationError.dateTooLate;
    }
    return null;
  }
}
