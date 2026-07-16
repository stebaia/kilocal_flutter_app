import 'package:flutter_test/flutter_test.dart';
import 'package:kilocal_flutter_app/features/survey/data/survey_mapper.dart';
import 'package:kilocal_flutter_app/features/survey/domain/entities/survey_answer.dart';
import 'package:kilocal_flutter_app/features/survey/domain/entities/survey_outcome.dart';

/// Guards the biotype outcome of `POST /survey/submit/type_survey`.
///
/// Fixtures are verbatim from a live staging submit (2026-07-16): the response
/// references the profile by id only, and the display copy comes from a
/// separate `profiles` read. The result screen's `{{type}}` /
/// `{{outcome_profile}}` placeholders depend on both halves.
void main() {
  group('SurveyOutcome.fromJson', () {
    test('reads the profile reference from a real outcome', () {
      // Verbatim from the live submit response.
      final outcome = SurveyOutcome.fromJson(const {
        'id': 2,
        'majority_of_values': '2',
        'profile': {'id': 4, 'kit_slug': 'kit-tipo-2'},
      });

      expect(outcome, isNotNull);
      expect(outcome!.id, 4);
      expect(outcome.kitSlug, 'kit-tipo-2');
      // The submit carries no copy, so the type is not displayable yet.
      expect(outcome.typeDisplay, isNull);
      expect(outcome.isEmpty, isTrue);
    });

    test('returns null when there is no usable profile', () {
      expect(SurveyOutcome.fromJson(null), isNull);
      expect(SurveyOutcome.fromJson(const {}), isNull);
      expect(SurveyOutcome.fromJson(const {'profile': null}), isNull);
      expect(SurveyOutcome.fromJson(const {'profile': {}}), isNull);
    });
  });

  group('mapOutcomeProfile', () {
    // Verbatim from the live `profiles` GraphQL read for id 4.
    const row = {
      'id': '4',
      'icon': {'id': 'b0847b75-65ad-462d-9643-39cb8a609cb2'},
      'kit': {
        'asset': {
          'default_asset': {'id': '240399e5-339b-4cd2-a51a-bfca1a4ff7f6'},
        },
      },
      'translations': [
        {
          'title': 'Tipo 2',
          'name': 'Mela',
          'content': '<h3>Piano Proteico</h3>',
          'content_f': '<h3><strong>Piano Proteico</strong></h3>',
        },
      ],
    };

    const reference = SurveyOutcome(id: 4, kitSlug: 'kit-tipo-2');

    test('fills the copy and keeps the reference', () {
      final outcome = mapOutcomeProfile(reference, row, gender: 'm');

      expect(outcome.id, 4);
      expect(outcome.kitSlug, 'kit-tipo-2');
      expect(outcome.typeLabel, 'Tipo 2');
      expect(outcome.denomination, 'Mela');
      expect(outcome.typeDisplay, 'Tipo 2 - Mela');
      expect(outcome.isEmpty, isFalse);
    });

    test('resolves the kit image from kit.asset.default_asset', () {
      final outcome = mapOutcomeProfile(reference, row);

      expect(outcome.kitImageId, '240399e5-339b-4cd2-a51a-bfca1a4ff7f6');
      expect(outcome.iconId, 'b0847b75-65ad-462d-9643-39cb8a609cb2');
    });

    test('picks content for male and content_f for female profiles', () {
      expect(
        mapOutcomeProfile(reference, row, gender: 'm').description,
        '<h3>Piano Proteico</h3>',
      );
      expect(
        mapOutcomeProfile(reference, row, gender: 'f').description,
        '<h3><strong>Piano Proteico</strong></h3>',
      );
      // Unknown gender is treated as non-female, matching BiotypeDto.
      expect(
        mapOutcomeProfile(reference, row).description,
        '<h3>Piano Proteico</h3>',
      );
    });

    test('falls back to content when a female variant is missing', () {
      final outcome = mapOutcomeProfile(reference, const {
        'translations': [
          {'title': 'Tipo 2', 'content': '<p>Solo neutro</p>'},
        ],
      }, gender: 'f');

      expect(outcome.description, '<p>Solo neutro</p>');
    });

    test('degrades to the reference when the row has no copy', () {
      final outcome = mapOutcomeProfile(reference, const {'id': '4'});

      expect(outcome.id, 4);
      expect(outcome.typeDisplay, isNull);
      expect(outcome.kitImageId, isNull);
    });
  });

  group('typeDisplay', () {
    test('joins the label and denomination for {{type}}', () {
      const outcome = SurveyOutcome(
        id: 4,
        typeLabel: 'Tipo 2',
        denomination: 'Mela',
      );
      expect(outcome.typeDisplay, 'Tipo 2 - Mela');
    });

    test('falls back to whichever half exists', () {
      expect(
        const SurveyOutcome(id: 4, typeLabel: 'Tipo 2').typeDisplay,
        'Tipo 2',
      );
      expect(
        const SurveyOutcome(id: 4, denomination: 'Mela').typeDisplay,
        'Mela',
      );
      expect(const SurveyOutcome(id: 4).typeDisplay, isNull);
    });
  });

  test('SurveySubmitResult exposes the profile reference', () {
    const result = SurveySubmitResult(
      surveySubmitId: '1390',
      profileStatus: 'starter_kit',
      outcome: {
        'id': 2,
        'majority_of_values': '2',
        'profile': {'id': 4, 'kit_slug': 'kit-tipo-2'},
      },
    );

    expect(result.biotype?.id, 4);
  });
}
