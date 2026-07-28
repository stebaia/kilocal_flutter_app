import 'package:flutter_test/flutter_test.dart';
import 'package:kilocal_flutter_app/core/monitoring/analytics_events.dart';
import 'package:kilocal_flutter_app/core/network/api_exception.dart';
import 'package:kilocal_flutter_app/features/path/domain/entities/barcode_product.dart';
import 'package:kilocal_flutter_app/features/path/domain/program_unlock_repository.dart';
import 'package:kilocal_flutter_app/features/survey/domain/entities/survey_step.dart';
import 'package:kilocal_flutter_app/features/survey/domain/survey_repository.dart';
import 'package:kilocal_flutter_app/features/survey/presentation/cubit/survey_cubit.dart';
import 'package:kilocal_flutter_app/features/user/domain/user_details.dart';
import 'package:kilocal_flutter_app/features/user/presentation/cubit/user_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockSurveyRepository extends Mock implements SurveyRepository {}

class MockAnalyticsEvents extends Mock implements AnalyticsEvents {}

class MockProgramUnlockRepository extends Mock
    implements ProgramUnlockRepository {}

class MockUserCubit extends Mock implements UserCubit {}

/// Guards the starter kit's proof of purchase.
///
/// `other_validations: "barcode"` (question id 6, starter_kit sort 1) used to
/// be parsed and ignored, so any text was accepted — the mandatory proof of
/// purchase let anyone through. `single_product_barcode_check == false` (this
/// section) means it must match a product from the user's own kit
/// (`fetchKitBarcodeProducts`), confirmed by backend 2026-07-28 — the generic
/// `use_for_barcode_check` catalogue belongs to other flows (e.g. the
/// restricted-access unlock sheet), not this one.
void main() {
  late MockSurveyRepository repository;
  late MockAnalyticsEvents analytics;
  late MockProgramUnlockRepository unlockRepository;
  late MockUserCubit userCubit;

  // A real staging code.
  const validCode = 'A947328593';
  const kitBiotype = Biotype(
    id: 4,
    displayName: 'Tipo 2',
    kit: BiotypeKit(id: 'kit-3'),
  );
  final kitProducts = [
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
    userCubit = MockUserCubit();

    when(() => repository.ensureDetails()).thenAnswer((_) async {});
    when(() => repository.fetchSurvey(any())).thenAnswer((_) async => survey);
    when(() => analytics.onboardingStarted()).thenAnswer((_) async {});
    when(
      () => userCubit.state,
    ).thenReturn(const UserState(details: UserDetails(biotype: kitBiotype)));
    when(
      () => repository.fetchKitBarcodeProducts(any()),
    ).thenAnswer((_) async => kitProducts);
  });

  Future<SurveyCubit> startedCubit() async {
    final cubit = SurveyCubit(
      repository: repository,
      analytics: analytics,
      unlockRepository: unlockRepository,
      userCubit: userCubit,
    );
    await cubit.start('starter_kit');
    // fetchKitBarcodeProduct runs unawaited off start(); let it settle.
    await Future<void>.delayed(Duration.zero);
    return cubit;
  }

  test('rejects a random barcode and stays on the step', () async {
    final cubit = await startedCubit();
    cubit.setText('QUALSIASI-COSA');

    await cubit.next();

    expect(cubit.state.currentIndex, 0, reason: 'must not advance');
    expect(cubit.state.errorMessage, contains('non riconosciuto'));
  });

  test('accepts a code from the user\'s kit', () async {
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

  test('does not advance when the kit products cannot be read', () async {
    when(
      () => repository.fetchKitBarcodeProducts(any()),
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
    // This section's check is single_product_barcode_check == false, so it
    // must never touch the generic use_for_barcode_check catalogue.
    verifyNever(() => unlockRepository.fetchBarcodeProducts());
  });
}
