import 'package:flutter_test/flutter_test.dart';
import 'package:kilocal_flutter_app/core/monitoring/analytics_events.dart';
import 'package:kilocal_flutter_app/core/network/api_exception.dart';
import 'package:kilocal_flutter_app/features/path/domain/entities/barcode_product.dart';
import 'package:kilocal_flutter_app/features/path/domain/program_unlock_repository.dart';
import 'package:kilocal_flutter_app/features/survey/domain/entities/survey_answer.dart';
import 'package:kilocal_flutter_app/features/survey/domain/entities/survey_step.dart';
import 'package:kilocal_flutter_app/features/survey/domain/survey_repository.dart';
import 'package:kilocal_flutter_app/features/survey/presentation/cubit/survey_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockSurveyRepository extends Mock implements SurveyRepository {}

class MockAnalyticsEvents extends Mock implements AnalyticsEvents {}

class MockProgramUnlockRepository extends Mock
    implements ProgramUnlockRepository {}

/// Guards the *whole* survey at submit time, not just the step being left.
///
/// Reported: pressing "Fine" entered the app even though the proof of purchase
/// was not satisfied. next() only validated the current step, so the barcode
/// was checked when walking past it and never again — going back, or editing
/// the answer afterwards, reached the submit unchecked.
void main() {
  late MockSurveyRepository repository;
  late MockAnalyticsEvents analytics;
  late MockProgramUnlockRepository unlockRepository;

  const validCode = 'A947328593';
  final catalogue = [
    const BarcodeProduct(id: '1', title: 'Kilocal', codes: {validCode}),
  ];

  const submitResult = SurveySubmitResult(
    surveySubmitId: '1',
    profileStatus: 'active',
  );

  SurveySection barcodeSection() => const SurveySection(
    id: '11',
    sort: 1,
    conditionAction: 'show',
    useCustomCta: false,
    storeInUserData: false,
    showAsDropdown: false,
    singleProductBarcodeCheck: false,
    showSingleProductCta: true,
    loadKilocalPoints: false,
    isDobQuestion: false,
    isGenderQuestion: false,
    isMenopausaQuestion: false,
    conditions: [],
    question: SurveyQuestion(
      id: '6',
      type: SurveyAnswerType.input,
      inputType: SurveyInputType.text,
      required: true,
      otherValidations: 'barcode',
      options: [],
    ),
  );

  // starter_kit's real shape: the CAP question, then a plain closing step.
  SurveySection capSection() => const SurveySection(
    id: '94',
    sort: 2,
    conditionAction: 'show',
    useCustomCta: false,
    storeInUserData: false,
    showAsDropdown: false,
    singleProductBarcodeCheck: false,
    showSingleProductCta: false,
    loadKilocalPoints: false,
    isDobQuestion: false,
    isGenderQuestion: false,
    isMenopausaQuestion: false,
    conditions: [],
    question: SurveyQuestion(
      id: '34',
      type: SurveyAnswerType.input,
      inputType: SurveyInputType.text,
      required: true,
      otherValidations: 'zip_code',
      options: [],
    ),
  );

  SurveySection closingSection() => const SurveySection(
    id: '10',
    sort: 3,
    conditionAction: 'show',
    useCustomCta: false,
    storeInUserData: false,
    showAsDropdown: false,
    singleProductBarcodeCheck: false,
    showSingleProductCta: false,
    loadKilocalPoints: false,
    isDobQuestion: false,
    isGenderQuestion: false,
    isMenopausaQuestion: false,
    conditions: [],
    title: 'Hai completato il profilo!',
  );

  final survey = Survey(
    id: '2',
    internalName: 'starter_kit',
    sections: [barcodeSection(), capSection(), closingSection()],
  );

  setUpAll(() {
    registerFallbackValue(
      const Survey(id: '0', internalName: 'fallback', sections: []),
    );
  });

  setUp(() {
    repository = MockSurveyRepository();
    analytics = MockAnalyticsEvents();
    unlockRepository = MockProgramUnlockRepository();

    when(() => repository.ensureDetails()).thenAnswer((_) async {});
    when(() => repository.fetchSurvey(any())).thenAnswer((_) async => survey);
    when(() => analytics.onboardingStarted()).thenAnswer((_) async {});
    when(() => analytics.onboardingCompleted()).thenAnswer((_) async {});
    when(() => analytics.surveySubmitted(any())).thenAnswer((_) async {});
    when(
      () => unlockRepository.fetchBarcodeProducts(),
    ).thenAnswer((_) async => catalogue);
    when(
      () => repository.submit(
        internalName: any(named: 'internalName'),
        answers: any(named: 'answers'),
        survey: any(named: 'survey'),
        pharmacy: any(named: 'pharmacy'),
      ),
    ).thenAnswer((_) async => submitResult);
  });

  SurveyCubit build() => SurveyCubit(
    repository: repository,
    analytics: analytics,
    unlockRepository: unlockRepository,
  );

  void verifyNoSubmit() {
    verifyNever(
      () => repository.submit(
        internalName: any(named: 'internalName'),
        answers: any(named: 'answers'),
        survey: any(named: 'survey'),
        pharmacy: any(named: 'pharmacy'),
      ),
    );
  }

  /// Walks the whole survey with valid answers and presses the final CTA.
  Future<SurveyCubit> walkToEndAndFinish() async {
    final cubit = build();
    await cubit.start('starter_kit');
    cubit.setText(validCode);
    await cubit.next();
    cubit.setText('20121');
    await cubit.next();
    await cubit.next(); // "Fine"
    return cubit;
  }

  test('submits when every step is satisfied', () async {
    final cubit = await walkToEndAndFinish();

    expect(cubit.state.status, SurveyStatus.completed);
  });

  test(
    'refuses to submit when the barcode was edited to junk afterwards',
    () async {
      final cubit = build();
      await cubit.start('starter_kit');

      // Pass the barcode step legitimately…
      cubit.setText(validCode);
      await cubit.next();
      cubit.setText('20121');
      await cubit.next();

      // …then go back and replace it with junk.
      cubit.previous();
      cubit.previous();
      cubit.setText('QUALSIASI-COSA');

      // Walk forward and press "Fine".
      await cubit.next();
      await cubit.next();
      await cubit.next();

      expect(cubit.state.status, isNot(SurveyStatus.completed));
      verifyNoSubmit();
    },
  );

  test('sends the user back to the offending step with a reason', () async {
    final cubit = build();
    await cubit.start('starter_kit');

    cubit.setText(validCode);
    await cubit.next();
    cubit.setText('20121');
    await cubit.next();

    cubit.previous();
    cubit.previous();
    cubit.setText('SBAGLIATO');
    await cubit.next();

    // The barcode step is index 0 — the user must land back on it.
    expect(cubit.state.currentIndex, 0);
    expect(cubit.state.errorMessage, contains('non riconosciuto'));
  });

  test(
    'does not submit when the catalogue cannot be read at submit time',
    () async {
      final cubit = build();
      await cubit.start('starter_kit');
      cubit.setText(validCode);
      await cubit.next();
      cubit.setText('20121');
      await cubit.next();

      // The code was accepted on the way through, but the catalogue is now
      // unreachable: failing open here would let the gate through.
      when(() => unlockRepository.fetchBarcodeProducts()).thenThrow(
        const ApiException(type: ApiErrorType.network, statusCode: 0),
      );
      await cubit.next();

      expect(cubit.state.status, isNot(SurveyStatus.completed));
      verifyNoSubmit();
    },
  );
}
