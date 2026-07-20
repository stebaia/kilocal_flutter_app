import 'package:flutter_test/flutter_test.dart';
import 'package:kilocal_flutter_app/core/monitoring/analytics_events.dart';
import 'package:kilocal_flutter_app/core/network/api_exception.dart';
import 'package:kilocal_flutter_app/features/path/domain/entities/barcode_product.dart';
import 'package:kilocal_flutter_app/features/path/domain/program_unlock_repository.dart';
import 'package:kilocal_flutter_app/features/survey/domain/entities/survey_step.dart';
import 'package:kilocal_flutter_app/features/survey/domain/survey_repository.dart';
import 'package:kilocal_flutter_app/features/survey/presentation/cubit/survey_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockSurveyRepository extends Mock implements SurveyRepository {}

class MockAnalyticsEvents extends Mock implements AnalyticsEvents {}

class MockProgramUnlockRepository extends Mock
    implements ProgramUnlockRepository {}

/// Guards the starter kit's proof of purchase.
///
/// `other_validations: "barcode"` (question id 6, starter_kit sort 1) used to
/// be parsed and ignored, so any text was accepted — the mandatory proof of
/// purchase let anyone through. It must match the `use_for_barcode_check`
/// catalogue, the same rule the restricted-access unlock sheet applies.
void main() {
  late MockSurveyRepository repository;
  late MockAnalyticsEvents analytics;
  late MockProgramUnlockRepository unlockRepository;

  // A real staging code.
  const validCode = 'A947328593';
  final catalogue = [
    const BarcodeProduct(
      id: '1',
      title: 'Kilocal Brucia Grassi Urto',
      codes: {validCode},
    ),
  ];

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

  // A plain second step, so advancing off the barcode is observable.
  SurveySection plainSection() => const SurveySection(
    id: '6',
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
    title: 'sei all\'inizio del tuo percorso!',
  );

  final survey = Survey(
    id: '2',
    internalName: 'starter_kit',
    sections: [barcodeSection(), plainSection()],
  );

  setUp(() {
    repository = MockSurveyRepository();
    analytics = MockAnalyticsEvents();
    unlockRepository = MockProgramUnlockRepository();

    when(() => repository.ensureDetails()).thenAnswer((_) async {});
    when(() => repository.fetchSurvey(any())).thenAnswer((_) async => survey);
    when(() => analytics.onboardingStarted()).thenAnswer((_) async {});
    when(
      () => unlockRepository.fetchBarcodeProducts(),
    ).thenAnswer((_) async => catalogue);
  });

  Future<SurveyCubit> startedCubit() async {
    final cubit = SurveyCubit(
      repository: repository,
      analytics: analytics,
      unlockRepository: unlockRepository,
    );
    await cubit.start('starter_kit');
    return cubit;
  }

  test('rejects a random barcode and stays on the step', () async {
    final cubit = await startedCubit();
    cubit.setText('QUALSIASI-COSA');

    await cubit.next();

    expect(cubit.state.currentIndex, 0, reason: 'must not advance');
    expect(cubit.state.errorMessage, contains('non riconosciuto'));
  });

  test('accepts a code from the catalogue', () async {
    final cubit = await startedCubit();
    cubit.setText(validCode);

    await cubit.next();

    expect(cubit.state.currentIndex, 1);
    expect(cubit.state.errorMessage, isNull);
  });

  test('accepts a valid code regardless of case and padding', () async {
    final cubit = await startedCubit();
    cubit.setText('  a947328593  ');

    await cubit.next();

    expect(cubit.state.currentIndex, 1);
  });

  test('clears a previous error once a valid code is entered', () async {
    final cubit = await startedCubit();

    cubit.setText('SBAGLIATO');
    await cubit.next();
    expect(cubit.state.errorMessage, isNotNull);

    cubit.setText(validCode);
    await cubit.next();
    expect(cubit.state.errorMessage, isNull);
    expect(cubit.state.currentIndex, 1);
  });

  test('does not advance when the catalogue cannot be read', () async {
    when(
      () => unlockRepository.fetchBarcodeProducts(),
    ).thenThrow(const ApiException(type: ApiErrorType.network, statusCode: 0));

    final cubit = await startedCubit();
    cubit.setText(validCode);

    await cubit.next();

    // Failing open would let an unverified code through the gate.
    expect(cubit.state.currentIndex, 0);
    expect(cubit.state.errorMessage, isNotNull);
  });

  test('leaves an empty answer to the required check', () async {
    final cubit = await startedCubit();

    await cubit.next();

    expect(cubit.state.currentIndex, 0);
    // No barcode error: the field is simply not filled in yet.
    expect(cubit.state.errorMessage, isNull);
    verifyNever(() => unlockRepository.fetchBarcodeProducts());
  });
}
