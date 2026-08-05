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

/// `#stop#`/`#alert#` are CMS `result_value` markers on an answer option
/// (e.g. the "sei in gravidanza" → "Sì" option): `#stop#` blocks the survey
/// outright, `#alert#` requires confirming a CMS dialog before continuing.
/// Neither is question-specific — any option carrying the marker gates the
/// same way.
void main() {
  late MockSurveyRepository repository;
  late MockAnalyticsEvents analytics;
  late MockProgramUnlockRepository unlockRepository;
  late MockUserCubit userCubit;

  const yesOptionStop = SurveyOption(
    id: 'opt-yes',
    sort: 0,
    isOther: false,
    deselectOthers: false,
    text: 'Sì',
    resultValue: '#stop#',
  );
  const noOption = SurveyOption(
    id: 'opt-no',
    sort: 1,
    isOther: false,
    deselectOthers: false,
    text: 'No',
    resultValue: '5',
  );
  const alertOption = SurveyOption(
    id: 'opt-alert',
    sort: 0,
    isOther: false,
    deselectOthers: false,
    text: 'Opzione rischiosa',
    resultValue: '#alert#',
  );

  SurveySection questionSection({
    required String id,
    required List<SurveyOption> options,
  }) => SurveySection(
    id: id,
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
    conditions: const [],
    question: SurveyQuestion(
      id: 'q-$id',
      type: SurveyAnswerType.radio,
      inputType: SurveyInputType.unknown,
      required: true,
      options: options,
    ),
  );

  const closingSection = SurveySection(
    id: 'closing',
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
    title: 'Ultima sezione del survey',
    subtitle: 'Sottotitolo CMS',
    content: 'Contenuto CMS',
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
  });

  SurveyCubit build() => SurveyCubit(
    repository: repository,
    analytics: analytics,
    unlockRepository: unlockRepository,
    userCubit: userCubit,
  );

  group('#stop#', () {
    Survey survey() => Survey(
      id: '1',
      internalName: 'type_survey',
      sections: [
        questionSection(id: 'pregnancy', options: [yesOptionStop, noOption]),
        // A section between the risky question and the closing one, so
        // `previous()` from the stop screen must skip back over it rather
        // than merely decrementing — this is what the real survey looks
        // like ("sei in gravidanza" is not the second-to-last question).
        questionSection(id: 'unrelated', options: [noOption]),
        closingSection,
      ],
    );

    test('jumps to the last section without submitting', () async {
      when(
        () => repository.fetchSurvey(any()),
      ).thenAnswer((_) async => survey());
      final cubit = build();
      await cubit.start('type_survey');

      cubit.selectRadio(yesOptionStop);
      await cubit.next();

      expect(cubit.state.blockedByStop, isTrue);
      expect(cubit.state.currentIndex, cubit.state.visibleSections.length - 1);
      expect(cubit.state.currentSection?.id, 'closing');
      verifyNever(
        () => repository.submit(
          internalName: any(named: 'internalName'),
          answers: any(named: 'answers'),
          survey: any(named: 'survey'),
          pharmacy: any(named: 'pharmacy'),
        ),
      );
    });

    test(
      'leaves the CTA (CMS "Chiudi") enabled on the blocked screen',
      () async {
        when(
          () => repository.fetchSurvey(any()),
        ).thenAnswer((_) async => survey());
        final cubit = build();
        await cubit.start('type_survey');

        cubit.selectRadio(yesOptionStop);
        await cubit.next();

        expect(cubit.state.canLeaveCurrentStep, isTrue); // no required question
        expect(cubit.state.blockedByStop, isTrue);
      },
    );

    test(
      'pressing the CTA on the blocked screen restarts the wizard from the '
      'first step without submitting',
      () async {
        when(
          () => repository.fetchSurvey(any()),
        ).thenAnswer((_) async => survey());
        final cubit = build();
        await cubit.start('type_survey');

        cubit.selectRadio(yesOptionStop);
        await cubit.next();
        expect(cubit.state.blockedByStop, isTrue);

        await cubit.next();

        expect(cubit.state.blockedByStop, isFalse);
        expect(cubit.state.currentIndex, 0);
        expect(cubit.state.currentSection?.id, 'pregnancy');
        expect(cubit.state.answers, isEmpty);
        expect(cubit.state.status, SurveyStatus.inProgress);
        verifyNever(
          () => repository.submit(
            internalName: any(named: 'internalName'),
            answers: any(named: 'answers'),
            survey: any(named: 'survey'),
            pharmacy: any(named: 'pharmacy'),
          ),
        );
      },
    );

    test('going back returns straight to the risky question, skipping '
        'unrelated sections in between, and un-pins the block', () async {
      when(
        () => repository.fetchSurvey(any()),
      ).thenAnswer((_) async => survey());
      final cubit = build();
      await cubit.start('type_survey');

      cubit.selectRadio(yesOptionStop);
      await cubit.next();
      expect(cubit.state.blockedByStop, isTrue);

      cubit.previous();
      expect(cubit.state.blockedByStop, isFalse);
      expect(cubit.state.currentSection?.id, 'pregnancy');

      cubit.selectRadio(noOption);
      expect(cubit.state.blockedByStop, isFalse);
      await cubit.next(); // -> unrelated
      cubit.selectRadio(noOption);
      await cubit.next(); // -> closing

      expect(cubit.state.blockedByStop, isFalse);
      expect(cubit.state.currentSection?.id, 'closing');
    });
  });

  group('#alert#', () {
    Survey survey() => Survey(
      id: '1',
      internalName: 'type_survey',
      sections: [
        questionSection(id: 'risky', options: [alertOption, noOption]),
        closingSection,
      ],
    );

    const modal = SurveyAlertModal(title: 'Attenzione', content: 'Sei sicuro?');

    test('shows the CMS dialog and does not advance until confirmed', () async {
      when(
        () => repository.fetchSurvey(any()),
      ).thenAnswer((_) async => survey());
      when(() => repository.fetchAlertModal()).thenAnswer((_) async => modal);
      final cubit = build();
      await cubit.start('type_survey');

      cubit.selectRadio(alertOption);
      await cubit.next();

      expect(cubit.state.pendingAlert, modal);
      expect(cubit.state.currentIndex, 0); // did not advance
    });

    test('confirming the dialog advances past the step', () async {
      when(
        () => repository.fetchSurvey(any()),
      ).thenAnswer((_) async => survey());
      when(() => repository.fetchAlertModal()).thenAnswer((_) async => modal);
      final cubit = build();
      await cubit.start('type_survey');

      cubit.selectRadio(alertOption);
      await cubit.next();
      await cubit.confirmAlert();

      expect(cubit.state.pendingAlert, isNull);
      expect(cubit.state.currentIndex, 1);
      expect(cubit.state.currentSection?.id, 'closing');
    });

    test('dismissing the dialog keeps the user on the step', () async {
      when(
        () => repository.fetchSurvey(any()),
      ).thenAnswer((_) async => survey());
      when(() => repository.fetchAlertModal()).thenAnswer((_) async => modal);
      final cubit = build();
      await cubit.start('type_survey');

      cubit.selectRadio(alertOption);
      await cubit.next();
      cubit.dismissAlert();

      expect(cubit.state.pendingAlert, isNull);
      expect(cubit.state.currentIndex, 0);
    });

    test('re-confirming the same answer does not re-fetch the modal', () async {
      when(
        () => repository.fetchSurvey(any()),
      ).thenAnswer((_) async => survey());
      when(() => repository.fetchAlertModal()).thenAnswer((_) async => modal);
      final cubit = build();
      await cubit.start('type_survey');

      cubit.selectRadio(alertOption);
      await cubit.next();
      await cubit.confirmAlert();

      cubit.previous();
      expect(cubit.state.currentSection?.id, 'risky');
      await cubit.next(); // already confirmed for this exact answer

      verify(() => repository.fetchAlertModal()).called(1);
      expect(cubit.state.currentSection?.id, 'closing');
    });

    test(
      'a missing CMS modal degrades to letting the user through unblocked',
      () async {
        when(
          () => repository.fetchSurvey(any()),
        ).thenAnswer((_) async => survey());
        when(() => repository.fetchAlertModal()).thenAnswer((_) async => null);
        final cubit = build();
        await cubit.start('type_survey');

        cubit.selectRadio(alertOption);
        await cubit.next();

        expect(cubit.state.pendingAlert, isNull);
        expect(cubit.state.currentSection?.id, 'closing');
      },
    );
  });
}
