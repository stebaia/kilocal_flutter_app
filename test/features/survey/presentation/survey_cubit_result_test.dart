import 'package:flutter_test/flutter_test.dart';
import 'package:kilocal_flutter_app/core/monitoring/analytics_events.dart';
import 'package:kilocal_flutter_app/core/network/api_exception.dart';
import 'package:kilocal_flutter_app/features/survey/domain/entities/survey_answer.dart';
import 'package:kilocal_flutter_app/features/survey/domain/entities/survey_step.dart';
import 'package:kilocal_flutter_app/features/survey/domain/survey_repository.dart';
import 'package:kilocal_flutter_app/features/survey/presentation/cubit/survey_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockSurveyRepository extends Mock implements SurveyRepository {}

class MockAnalyticsEvents extends Mock implements AnalyticsEvents {}

/// Guards when `type_survey` is submitted relative to its result section.
///
/// In the CMS the result section (id 9) is the **last visible step**, not a
/// screen after the wizard. Submitting on the way *out* of it therefore left
/// the user staring at a result screen with no outcome — the data only arrived
/// as they navigated away. It must be sent when advancing *into* it.
void main() {
  late MockSurveyRepository repository;
  late MockAnalyticsEvents analytics;

  const submitResult = SurveySubmitResult(
    surveySubmitId: 'sub-1',
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

  SurveySection section(String id, {required bool isResult}) {
    return SurveySection(
      id: id,
      sort: int.parse(id),
      conditionAction: 'show',
      // A result section is one with a custom CTA and no question.
      useCustomCta: isResult,
      storeInUserData: false,
      showAsDropdown: false,
      singleProductBarcodeCheck: false,
      showSingleProductCta: false,
      loadKilocalPoints: false,
      isDobQuestion: false,
      isGenderQuestion: false,
      isMenopausaQuestion: false,
      conditions: const [],
      question: isResult
          ? null
          : SurveyQuestion(
              id: 'q$id',
              type: SurveyAnswerType.input,
              inputType: SurveyInputType.text,
              required: false,
              options: const [],
            ),
    );
  }

  // Mirrors the real shape: a question, then the result section last.
  final survey = Survey(
    id: '1',
    internalName: 'type_survey',
    sections: [section('1', isResult: false), section('2', isResult: true)],
  );

  setUpAll(() {
    // mocktail needs a fallback for the non-primitive `any(named: 'survey')`.
    registerFallbackValue(
      const Survey(id: '0', internalName: 'fallback', sections: []),
    );
  });

  setUp(() {
    repository = MockSurveyRepository();
    analytics = MockAnalyticsEvents();

    when(() => repository.ensureDetails()).thenAnswer((_) async {});
    when(() => repository.fetchSurvey(any())).thenAnswer((_) async => survey);
    when(() => analytics.onboardingStarted()).thenAnswer((_) async {});
    when(() => analytics.onboardingCompleted()).thenAnswer((_) async {});
    when(() => analytics.surveySubmitted(any())).thenAnswer((_) async {});
    when(
      () => repository.submit(
        internalName: any(named: 'internalName'),
        answers: any(named: 'answers'),
        survey: any(named: 'survey'),
        pharmacy: any(named: 'pharmacy'),
      ),
    ).thenAnswer((_) async => submitResult);
  });

  SurveyCubit build() =>
      SurveyCubit(repository: repository, analytics: analytics);

  test(
    'submits when advancing into the result section, not on leaving',
    () async {
      final cubit = build();
      await cubit.start('type_survey');

      await cubit.next();

      // The outcome is available while the result section is on screen.
      expect(cubit.state.currentSection?.kind, SurveySectionKind.result);
      expect(cubit.state.status, SurveyStatus.inProgress);
      expect(cubit.state.submitResult, submitResult);
      expect(
        cubit.state.submitResult?.biotype?.typeDisplay,
        'Tipo 3 - Peperone',
      );
      verify(
        () => repository.submit(
          internalName: any(named: 'internalName'),
          answers: any(named: 'answers'),
          survey: any(named: 'survey'),
          pharmacy: any(named: 'pharmacy'),
        ),
      ).called(1);
    },
  );

  test(
    'completes without re-submitting when leaving the result section',
    () async {
      final cubit = build();
      await cubit.start('type_survey');

      await cubit.next(); // into the result
      await cubit.next(); // "Fine"

      expect(cubit.state.status, SurveyStatus.completed);
      // Still exactly one submit — the second next() must not send again.
      verify(
        () => repository.submit(
          internalName: any(named: 'internalName'),
          answers: any(named: 'answers'),
          survey: any(named: 'survey'),
          pharmacy: any(named: 'pharmacy'),
        ),
      ).called(1);
    },
  );

  test('stays on the last question when the submit fails', () async {
    when(
      () => repository.submit(
        internalName: any(named: 'internalName'),
        answers: any(named: 'answers'),
        survey: any(named: 'survey'),
        pharmacy: any(named: 'pharmacy'),
      ),
    ).thenThrow(
      const ApiException(type: ApiErrorType.unknown, statusCode: 500),
    );

    final cubit = build();
    await cubit.start('type_survey');
    await cubit.next();

    // Must not advance onto a result screen that has no outcome to show.
    expect(cubit.state.currentIndex, 0);
    expect(cubit.state.status, SurveyStatus.inProgress);
    expect(cubit.state.errorMessage, isNotNull);
  });
}
