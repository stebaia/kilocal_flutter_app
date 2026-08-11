import 'package:flutter_test/flutter_test.dart';
import 'package:kilocal_flutter_app/core/monitoring/analytics_events.dart';
import 'package:kilocal_flutter_app/features/path/domain/program_unlock_repository.dart';
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

/// The patologie question (`survey_question` id 17 on staging) is the one
/// Anna flagged as "deve essere bloccante". Unlike the gravidanza question
/// (id 30, radio, single answer), it is a **checkbox**: the user can tick
/// several conditions at once, mixing plain, `#alert#` and `#stop#` options,
/// plus an exclusive "Nessuna" (`deselect_others`).
///
/// The existing gate tests only ever exercise `selectRadio`, so none of the
/// multi-select combinations below were covered. Options mirror the real CMS
/// rows (ids kept) so the fixture stays recognisable against the live data.
void main() {
  late MockSurveyRepository repository;
  late MockAnalyticsEvents analytics;
  late MockProgramUnlockRepository unlockRepository;
  late MockUserCubit userCubit;

  // "Nessuna" — the exclusive option, no marker.
  const nessuna = SurveyOption(
    id: '54',
    sort: 0,
    isOther: false,
    deselectOthers: true,
    text: 'Nessuna',
  );
  // `#alert#` — warn, but let the user confirm and continue.
  const diabete = SurveyOption(
    id: '44',
    sort: 1,
    isOther: false,
    deselectOthers: false,
    text: 'Diabete',
    resultValue: '#alert#',
  );
  const ipertensione = SurveyOption(
    id: '48',
    sort: 2,
    isOther: false,
    deselectOthers: false,
    text: 'Ipertensione (pressione alta)',
    resultValue: '#alert#',
  );
  // `#stop#` — block outright.
  const insufficienzaRenale = SurveyOption(
    id: '50',
    sort: 3,
    isOther: false,
    deselectOthers: false,
    text: 'Insufficienza renale',
    resultValue: '#stop#',
  );
  const patologieOncologiche = SurveyOption(
    id: '125',
    sort: 4,
    isOther: false,
    deselectOthers: false,
    text: 'Patologie oncologiche',
    resultValue: '#stop#',
  );

  SurveySection patologieSection() => const SurveySection(
    id: 'patologie',
    sort: 1,
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
      id: 'q-17',
      type: SurveyAnswerType.checkbox,
      inputType: SurveyInputType.unknown,
      required: true,
      options: [
        nessuna,
        diabete,
        ipertensione,
        insufficienzaRenale,
        patologieOncologiche,
      ],
    ),
  );

  const closingSection = SurveySection(
    id: 'closing',
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
    title:
        'Ci dispiace davvero, ma per tutelare la tua salute non possiamo '
        'proseguire con il percorso.',
    subtitle:
        'Se hai una patologia, sei in gravidanza o segui un trattamento '
        'medico, è importante che il tuo medico valuti direttamente quali '
        'integratori siano adatti a te.',
  );

  // A section after the patologie question, so a `#stop#` jump has something
  // to skip over — as in the real survey, where patologie is not the last step.
  const followUpSection = SurveySection(
    id: 'unrelated',
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
    title: 'Domanda successiva',
  );

  Survey survey() => Survey(
    id: '1',
    internalName: 'type_survey',
    sections: [patologieSection(), followUpSection, closingSection],
  );

  const modal = SurveyAlertModal(
    title: 'Attenzione',
    content: '<p>Ti consigliamo di confrontarti con il tuo medico.</p>',
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
    userCubit = MockUserCubit();

    when(() => repository.ensureDetails()).thenAnswer((_) async {});
    when(() => analytics.onboardingStarted()).thenAnswer((_) async {});
    when(() => userCubit.state).thenReturn(const UserState());
    when(() => repository.fetchSurvey(any())).thenAnswer((_) async => survey());
    when(() => repository.fetchAlertModal()).thenAnswer((_) async => modal);
  });

  SurveyCubit build() => SurveyCubit(
    repository: repository,
    analytics: analytics,
    unlockRepository: unlockRepository,
    userCubit: userCubit,
  );

  Future<SurveyCubit> started() async {
    final cubit = build();
    await cubit.start('type_survey');
    return cubit;
  }

  void expectNotSubmitted() {
    verifyNever(
      () => repository.submit(
        internalName: any(named: 'internalName'),
        answers: any(named: 'answers'),
        survey: any(named: 'survey'),
        pharmacy: any(named: 'pharmacy'),
      ),
    );
  }

  group('#stop# on the checkbox patologie question', () {
    test('a single #stop# condition blocks the survey', () async {
      final cubit = await started();

      cubit.toggleCheckbox(insufficienzaRenale);
      await cubit.next();

      expect(cubit.state.blockedByStop, isTrue);
      expect(cubit.state.currentSection?.id, 'closing');
      expectNotSubmitted();
    });

    test('two #stop# conditions ticked together still block', () async {
      final cubit = await started();

      cubit.toggleCheckbox(insufficienzaRenale);
      cubit.toggleCheckbox(patologieOncologiche);
      await cubit.next();

      expect(cubit.state.blockedByStop, isTrue);
      expect(cubit.state.currentSection?.id, 'closing');
      expectNotSubmitted();
    });

    // The multi-select case that has no equivalent on a radio question: the
    // stricter marker must win, and the #alert# dialog must never be offered
    // as a way past a #stop# answer.
    test('#stop# wins over #alert# when both are ticked', () async {
      final cubit = await started();

      cubit.toggleCheckbox(diabete); // #alert#
      cubit.toggleCheckbox(insufficienzaRenale); // #stop#
      await cubit.next();

      expect(cubit.state.blockedByStop, isTrue);
      expect(cubit.state.pendingAlert, isNull);
      expect(cubit.state.currentSection?.id, 'closing');
      verifyNever(() => repository.fetchAlertModal());
      expectNotSubmitted();
    });

    test('the order the options are ticked in does not matter', () async {
      final cubit = await started();

      cubit.toggleCheckbox(insufficienzaRenale); // #stop# first
      cubit.toggleCheckbox(diabete); // #alert# second
      await cubit.next();

      expect(cubit.state.blockedByStop, isTrue);
      expect(cubit.state.pendingAlert, isNull);
    });

    // Un-ticking the blocking condition must release the gate. It does not by
    // itself let the user advance: the question is `required`, so an empty
    // selection keeps the CTA disabled until they tick something else.
    test('un-ticking the #stop# option releases the block', () async {
      final cubit = await started();

      cubit.toggleCheckbox(insufficienzaRenale);
      await cubit.next();
      expect(cubit.state.blockedByStop, isTrue);

      cubit.previous();
      expect(cubit.state.currentSection?.id, 'patologie');

      cubit.toggleCheckbox(insufficienzaRenale); // untick
      expect(cubit.state.blockedByStop, isFalse);
      expect(cubit.state.canLeaveCurrentStep, isFalse); // nothing selected

      cubit.toggleCheckbox(nessuna);
      await cubit.next();
      expect(cubit.state.blockedByStop, isFalse);
      expect(cubit.state.currentSection?.id, 'unrelated');
    });

    // "Nessuna" is `deselect_others`, so ticking it clears the #stop# option.
    test('switching to the exclusive "Nessuna" clears the block', () async {
      final cubit = await started();

      cubit.toggleCheckbox(patologieOncologiche);
      await cubit.next();
      expect(cubit.state.blockedByStop, isTrue);

      cubit.previous();
      cubit.toggleCheckbox(nessuna);

      expect(cubit.state.currentAnswer?.selectedOptionIds, ['54']);
      expect(cubit.state.blockedByStop, isFalse);

      await cubit.next();
      expect(cubit.state.currentSection?.id, 'unrelated');
    });
  });

  group('#alert# on the checkbox patologie question', () {
    test('a single #alert# condition asks for confirmation', () async {
      final cubit = await started();

      cubit.toggleCheckbox(diabete);
      await cubit.next();

      expect(cubit.state.pendingAlert, modal);
      expect(cubit.state.currentSection?.id, 'patologie'); // did not advance
    });

    test('confirming lets the user continue', () async {
      final cubit = await started();

      cubit.toggleCheckbox(diabete);
      await cubit.next();
      await cubit.confirmAlert();

      expect(cubit.state.pendingAlert, isNull);
      expect(cubit.state.currentSection?.id, 'unrelated');
    });

    test('two #alert# conditions prompt once, not once per option', () async {
      final cubit = await started();

      cubit.toggleCheckbox(diabete);
      cubit.toggleCheckbox(ipertensione);
      await cubit.next();
      expect(cubit.state.pendingAlert, modal);

      await cubit.confirmAlert();

      expect(cubit.state.currentSection?.id, 'unrelated');
      verify(() => repository.fetchAlertModal()).called(1);
    });

    // Confirmation is keyed on the exact selection, so adding a condition
    // after confirming must re-prompt rather than ride the old confirmation.
    test('adding another condition after confirming re-prompts', () async {
      final cubit = await started();

      cubit.toggleCheckbox(diabete);
      await cubit.next();
      await cubit.confirmAlert();
      expect(cubit.state.currentSection?.id, 'unrelated');

      cubit.previous();
      cubit.toggleCheckbox(ipertensione); // selection changed
      await cubit.next();

      expect(cubit.state.pendingAlert, modal);
      expect(cubit.state.currentSection?.id, 'patologie');
    });

    test('"Nessuna" alone passes with no dialog at all', () async {
      final cubit = await started();

      cubit.toggleCheckbox(nessuna);
      await cubit.next();

      expect(cubit.state.pendingAlert, isNull);
      expect(cubit.state.blockedByStop, isFalse);
      expect(cubit.state.currentSection?.id, 'unrelated');
      verifyNever(() => repository.fetchAlertModal());
    });
  });
}
