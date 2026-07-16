import 'package:flutter_test/flutter_test.dart';
import 'package:kilocal_flutter_app/features/survey/domain/entities/survey_answer.dart';
import 'package:kilocal_flutter_app/features/survey/domain/entities/survey_outcome.dart';

/// Guards the parsing of `outcome.profile` from `POST /survey/submit/…`.
///
/// Backend confirmed the biotype result lives at `outcome.profile` but not the
/// shape of the value, so all three plausible encodings are covered here. The
/// result screen's `{{type}}` / `{{outcome_profile}}` placeholders depend on
/// this: before the fix they were resolved against the response's own top-level
/// keys, never matched, and got stripped — leaving "Ottimo , risulti essere un".
void main() {
  group('SurveyOutcome.fromJson', () {
    test('returns null when outcome is absent or carries no profile', () {
      expect(SurveyOutcome.fromJson(null), isNull);
      expect(SurveyOutcome.fromJson(const {}), isNull);
      expect(SurveyOutcome.fromJson(const {'profile': null}), isNull);
    });

    test('parses an expanded profiles row', () {
      final outcome = SurveyOutcome.fromJson(const {
        'profile': {
          'id': 5,
          'title': 'tipo-3-m',
          'kit': {'id': 8},
          'icon': '74cb665e-8474-4857-bbeb-958d622ae1dd',
          'translations': [
            {
              'title': 'Tipo 3',
              'name': 'Peperone',
              'content': '<p>Tendi ad avere un accumulo omogeneo…</p>',
            },
          ],
        },
      });

      expect(outcome, isNotNull);
      expect(outcome!.profileId, 5);
      expect(outcome.typeLabel, 'Tipo 3');
      expect(outcome.denomination, 'Peperone');
      expect(
        outcome.description,
        '<p>Tendi ad avere un accumulo omogeneo…</p>',
      );
      expect(outcome.kitImageId, '8');
      expect(outcome.iconId, '74cb665e-8474-4857-bbeb-958d622ae1dd');
      expect(outcome.isEmpty, isFalse);
    });

    test('falls back to content_f when content is absent', () {
      final outcome = SurveyOutcome.fromJson(const {
        'profile': {
          'id': 4,
          'translations': [
            {'title': 'Tipo 4', 'content_f': '<p>Copy femminile</p>'},
          ],
        },
      });

      expect(outcome!.description, '<p>Copy femminile</p>');
    });

    test('parses a bare profile id', () {
      final outcome = SurveyOutcome.fromJson(const {'profile': 5});

      expect(outcome!.profileId, 5);
      // Nothing else is knowable from an id alone — the caller hydrates it.
      expect(outcome.typeLabel, isNull);
      expect(outcome.isEmpty, isTrue);
    });

    test('parses pre-rendered HTML copy', () {
      final outcome = SurveyOutcome.fromJson(const {
        'profile': '<p>Tendi ad avere un accumulo…</p>',
      });

      expect(outcome!.description, '<p>Tendi ad avere un accumulo…</p>');
      expect(outcome.profileId, isNull);
      expect(outcome.isEmpty, isFalse);
    });

    test('treats blank HTML copy as no outcome', () {
      expect(SurveyOutcome.fromJson(const {'profile': '   '}), isNull);
    });
  });

  group('typeDisplay', () {
    test('joins the label and denomination for {{type}}', () {
      const outcome = SurveyOutcome(typeLabel: 'Tipo 3', denomination: 'Pera');
      expect(outcome.typeDisplay, 'Tipo 3 - Pera');
    });

    test('falls back to whichever half exists', () {
      expect(const SurveyOutcome(typeLabel: 'Tipo 3').typeDisplay, 'Tipo 3');
      expect(const SurveyOutcome(denomination: 'Pera').typeDisplay, 'Pera');
      expect(const SurveyOutcome().typeDisplay, isNull);
    });
  });

  test('SurveySubmitResult exposes the parsed biotype', () {
    const result = SurveySubmitResult(
      surveySubmitId: '1',
      profileStatus: 'starter_kit',
      outcome: {
        'profile': {
          'id': 5,
          'translations': [
            {'title': 'Tipo 3', 'name': 'Peperone'},
          ],
        },
      },
    );

    expect(result.biotype?.typeDisplay, 'Tipo 3 - Peperone');
  });
}
