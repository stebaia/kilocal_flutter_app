import 'package:flutter_test/flutter_test.dart';
import 'package:kilocal_flutter_app/core/monitoring/analytics_events.dart';
import 'package:kilocal_flutter_app/core/network/api_exception.dart';
import 'package:kilocal_flutter_app/features/path/domain/entities/barcode_product.dart';
import 'package:kilocal_flutter_app/features/path/domain/program_unlock_repository.dart';
import 'package:kilocal_flutter_app/features/survey/domain/entities/survey_answer.dart';
import 'package:kilocal_flutter_app/features/survey/domain/entities/survey_outcome.dart';
import 'package:kilocal_flutter_app/features/survey/domain/entities/survey_step.dart';
import 'package:kilocal_flutter_app/features/survey/domain/survey_repository.dart';
import 'package:kilocal_flutter_app/features/survey/presentation/cubit/survey_cubit.dart';
import 'package:kilocal_flutter_app/features/user/presentation/cubit/user_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockSurveyRepository extends Mock implements SurveyRepository {}

class MockAnalyticsEvents extends Mock implements AnalyticsEvents {}

class MockProgramUnlockRepository extends Mock
    implements ProgramUnlockRepository {}

class MockUserCubit extends Mock implements UserCubit {}

/// Guards when `type_survey` is submitted relative to its result section.
///
/// In the CMS the result section (id 9) is the **last visible step**, not a
/// screen after the wizard. Submitting on the way *out* of it therefore left
/// the user staring at a result screen with no outcome — the data only arrived
/// as they navigated away. It must be sent when advancing *into* it.
void main() {
  late MockSurveyRepository repository;
  late MockAnalyticsEvents analytics;
  late MockProgramUnlockRepository unlockRepository;
  late MockUserCubit userCubit;

  // Verbatim from a live submit: the profile is a reference, not the copy.
  const submitResult = SurveySubmitResult(
    surveySubmitId: 'sub-1',
    profileStatus: 'starter_kit',
    outcome: {
      'id': 2,
      'majority_of_values': '2',
      'profile': {'id': 4, 'kit_slug': 'kit-tipo-2'},
    },
  );

  // What the follow-up `profiles` read adds.
  const hydrated = SurveyOutcome(
    id: 4,
    kitSlug: 'kit-tipo-2',
    typeLabel: 'Tipo 2',
    denomination: 'Mela',
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
    // mocktail needs fallbacks for the non-primitive `any()` arguments.
    registerFallbackValue(
      const Survey(id: '0', internalName: 'fallback', sections: []),
    );
    registerFallbackValue(const SurveyOutcome(id: 0));
  });

  setUp(() {
    repository = MockSurveyRepository();
    analytics = MockAnalyticsEvents();
    unlockRepository = MockProgramUnlockRepository();
    userCubit = MockUserCubit();
    when(
      () => unlockRepository.fetchBarcodeProducts(),
    ).thenAnswer((_) async => const <BarcodeProduct>[]);
    when(() => userCubit.state).thenReturn(const UserState());

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
    when(
      () => repository.fetchOutcomeProfile(any(), gender: any(named: 'gender')),
    ).thenAnswer((_) async => hydrated);
  });

  SurveyCubit build() => SurveyCubit(
    repository: repository,
    analytics: analytics,
    unlockRepository: unlockRepository,
    userCubit: userCubit,
  );

  test(
    'submits when advancing into the result section, not on leaving',
    () async {
      final cubit = build();
      await cubit.start('type_survey');

      await cubit.next();

      // The outcome is available, and hydrated, while the result is on screen.
      expect(cubit.state.currentSection?.kind, SurveySectionKind.result);
      expect(cubit.state.status, SurveyStatus.inProgress);
      expect(cubit.state.submitResult, submitResult);
      // The submit alone cannot fill {{type}} — only the hydrated profile can.
      expect(cubit.state.submitResult?.biotype?.typeDisplay, isNull);
      expect(cubit.state.outcomeProfile?.typeDisplay, 'Tipo 2 - Mela');
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

  test('still shows the result when hydrating the profile fails', () async {
    when(
      () => repository.fetchOutcomeProfile(any(), gender: any(named: 'gender')),
    ).thenThrow(
      const ApiException(type: ApiErrorType.unknown, statusCode: 500),
    );

    final cubit = build();
    await cubit.start('type_survey');
    await cubit.next();

    // The submit already succeeded server-side, so losing the copy must not
    // block the user on the last question.
    expect(cubit.state.currentSection?.kind, SurveySectionKind.result);
    expect(cubit.state.outcomeProfile?.id, 4);
    expect(cubit.state.outcomeProfile?.typeDisplay, isNull);
  });

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
