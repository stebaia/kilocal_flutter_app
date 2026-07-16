import 'package:flutter_test/flutter_test.dart';
import 'package:kilocal_flutter_app/features/survey/domain/survey_validation.dart';

/// Guards the `other_validations` grammar.
///
/// Every rule string here is verbatim from the live CMS (2026-07-16) — these
/// are the only six that exist. Before this the field was parsed but never
/// enforced, so any text was accepted for height, weight, CAP and phone.
void main() {
  // Verbatim CMS rules.
  const heightRule = 'number|int|gte:100|lte:300';
  const weightRule = 'number|lte:300|gte:30|bmi:17.5';
  const dobRule = 'date|max:{-18years}|min:1900-01-01';

  group('height — $heightRule', () {
    final rule = SurveyValidationRule.parse(heightRule);

    test('accepts a plausible height', () {
      expect(rule.validate('186'), isNull);
      expect(rule.validate('100'), isNull);
      expect(rule.validate('300'), isNull);
    });

    test('rejects out-of-range values', () {
      expect(rule.validate('99'), SurveyValidationError.tooSmall);
      expect(rule.validate('301'), SurveyValidationError.tooLarge);
    });

    test('rejects non-numbers and decimals', () {
      expect(rule.validate('abc'), SurveyValidationError.notANumber);
      expect(rule.validate('186.5'), SurveyValidationError.notAnInteger);
    });

    test('accepts an empty answer (required is a separate concern)', () {
      expect(rule.validate(''), isNull);
      expect(rule.validate(null), isNull);
      expect(rule.validate('   '), isNull);
    });
  });

  group('weight — $weightRule', () {
    final rule = SurveyValidationRule.parse(weightRule);

    test('accepts a plausible weight', () {
      expect(rule.validate('98', heightCm: 186), isNull);
      // 40kg at 150cm → BMI 17.8, over the bound.
      expect(rule.validate('40', heightCm: 150), isNull);
    });

    test('accepts a decimal weight (no int token)', () {
      expect(rule.validate('72.5', heightCm: 175), isNull);
      expect(rule.validate('72,5', heightCm: 175), isNull);
    });

    test('rejects out-of-range values', () {
      expect(
        rule.validate('29', heightCm: 175),
        SurveyValidationError.tooSmall,
      );
      expect(
        rule.validate('301', heightCm: 175),
        SurveyValidationError.tooLarge,
      );
    });

    test('rejects a weight whose BMI falls under 17.5', () {
      // 50kg at 186cm → BMI 14.5.
      expect(
        rule.validate('50', heightCm: 186),
        SurveyValidationError.bmiTooLow,
      );
      // 61kg at 186cm → BMI 17.6, just above the bound.
      expect(rule.validate('61', heightCm: 186), isNull);
    });

    test('skips the BMI bound when the height is unknown', () {
      // Better to accept than to guess a height and reject wrongly.
      expect(rule.validate('50'), isNull);
    });
  });

  group('date of birth — $dobRule', () {
    final rule = SurveyValidationRule.parse(dobRule);
    final now = DateTime(2026, 7, 16);

    test('accepts an adult', () {
      expect(rule.validate('1996-01-01', now: now), isNull);
    });

    test('rejects an under-18', () {
      expect(
        rule.validate('2015-01-01', now: now),
        SurveyValidationError.dateTooLate,
      );
    });

    test('accepts exactly 18 today', () {
      expect(rule.validate('2008-07-16', now: now), isNull);
    });

    test('rejects one day short of 18', () {
      expect(
        rule.validate('2008-07-17', now: now),
        SurveyValidationError.dateTooLate,
      );
    });

    test('rejects a date before 1900', () {
      expect(
        rule.validate('1899-12-31', now: now),
        SurveyValidationError.dateTooEarly,
      );
    });

    test('rejects an unparseable date', () {
      expect(
        rule.validate('not-a-date', now: now),
        SurveyValidationError.notADate,
      );
    });
  });

  group('zip_code', () {
    final rule = SurveyValidationRule.parse('zip_code');

    test('accepts a five-digit CAP', () {
      expect(rule.validate('20121'), isNull);
      expect(rule.validate('00100'), isNull);
    });

    test('rejects anything else', () {
      expect(rule.validate('2012'), SurveyValidationError.invalidZipCode);
      expect(rule.validate('201211'), SurveyValidationError.invalidZipCode);
      expect(rule.validate('abcde'), SurveyValidationError.invalidZipCode);
    });
  });

  group('phone', () {
    final rule = SurveyValidationRule.parse('phone');

    test('accepts common formats', () {
      expect(rule.validate('3331234567'), isNull);
      expect(rule.validate('+39 333 123 4567'), isNull);
      expect(rule.validate('333-123-4567'), isNull);
    });

    test('rejects letters and too-short numbers', () {
      expect(rule.validate('abc'), SurveyValidationError.invalidPhone);
      expect(rule.validate('123'), SurveyValidationError.invalidPhone);
    });
  });

  group('parse', () {
    test('flags barcode for the async catalogue check', () {
      final rule = SurveyValidationRule.parse('barcode');
      expect(rule.isBarcode, isTrue);
      // The format itself is unconstrained; only the catalogue decides.
      expect(rule.validate('anything'), isNull);
    });

    test('is empty for null/blank rules', () {
      expect(SurveyValidationRule.parse(null).isEmpty, isTrue);
      expect(SurveyValidationRule.parse('').isEmpty, isTrue);
    });

    test('ignores unknown tokens instead of blocking the user', () {
      final rule = SurveyValidationRule.parse('number|wat:99|gte:10');
      expect(rule.validate('50'), isNull);
      expect(rule.validate('9'), SurveyValidationError.tooSmall);
    });
  });
}
