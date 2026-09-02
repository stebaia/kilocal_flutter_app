import 'package:flutter_test/flutter_test.dart';
import 'package:kilocal_flutter_app/features/diary/domain/diary_repository.dart';
import 'package:kilocal_flutter_app/features/diary/domain/entities/diary_activity.dart';
import 'package:kilocal_flutter_app/features/diary/domain/entities/diary_goal.dart';
import 'package:kilocal_flutter_app/features/diary/presentation/cubit/diary_goals_cubit.dart';
import 'package:kilocal_flutter_app/features/survey/domain/survey_repository.dart';
import 'package:kilocal_flutter_app/features/survey/domain/entities/survey_answer.dart';
import 'package:mocktail/mocktail.dart';

class MockDiaryRepository extends Mock implements DiaryRepository {}

class MockSurveyRepository extends Mock implements SurveyRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(const DiaryGoalInput(content: '', category: '1'));
  });

  group('DiaryGoalsCubit', () {
    late MockDiaryRepository repository;
    late MockSurveyRepository surveyRepository;
    late DiaryGoalsCubit cubit;

    const personal = DiaryGoal(
      id: 'p1',
      kind: DiaryGoalKind.personal,
      content: 'Personal goal',
      category: '4',
    );
    const kilocal = DiaryGoal(
      id: 'k1',
      kind: DiaryGoalKind.kilocal,
      content: 'Kilocal goal',
      relatedGoal: '9',
    );
    final completed = DiaryGoal(
      id: 'c1',
      kind: DiaryGoalKind.personal,
      content: 'Done goal',
      category: '4',
      completedAt: DateTime(2026, 6, 1),
    );

    setUp(() {
      repository = MockDiaryRepository();
      surveyRepository = MockSurveyRepository();
      // load() also fetches categories for the create picker.
      when(
        () => repository.fetchCategories(),
      ).thenAnswer((_) async => const []);
      when(
        () => surveyRepository.fetchMonthEndStatus(),
      ).thenAnswer((_) async => null);
      cubit = DiaryGoalsCubit(
        repository: repository,
        surveyRepository: surveyRepository,
      );
    });

    test('load emits loaded goals on success', () async {
      when(
        () => repository.fetchGoals(),
      ).thenAnswer((_) async => [personal, kilocal, completed]);

      await cubit.load();

      expect(cubit.state.status, DiaryGoalsStatus.loaded);
      expect(cubit.state.goals, hasLength(3));
    });

    // The month-end check runs the goals reconcile and refreshes the pending
    // survey state, so load() keeps it ahead of the list fetch.
    test('load triggers the month-end check before fetching goals', () async {
      when(() => repository.fetchGoals()).thenAnswer((_) async => [kilocal]);

      await cubit.load();

      verifyInOrder([
        () => surveyRepository.fetchMonthEndStatus(),
        () => repository.fetchGoals(),
      ]);
    });

    test('load stores pending month-end survey for the CTA', () async {
      const pending = SurveyMonthEndPending(
        month: 1,
        internalName: 'month_end_survey_1',
        goalInternalName: 'traguardo_mese_1',
      );
      when(
        () => surveyRepository.fetchMonthEndStatus(),
      ).thenAnswer((_) async => pending);
      when(() => repository.fetchGoals()).thenAnswer((_) async => [kilocal]);

      await cubit.load();

      expect(cubit.state.monthEndPending, pending);
    });

    test('load still lists goals when the month-end check fails', () async {
      when(
        () => surveyRepository.fetchMonthEndStatus(),
      ).thenThrow(Exception('boom'));
      when(
        () => repository.fetchGoals(),
      ).thenAnswer((_) async => [personal, kilocal]);

      await cubit.load();

      expect(cubit.state.status, DiaryGoalsStatus.loaded);
      expect(cubit.state.goals, hasLength(2));
    });

    test('load emits error on failure', () async {
      when(() => repository.fetchGoals()).thenThrow(Exception('boom'));

      await cubit.load();

      expect(cubit.state.status, DiaryGoalsStatus.error);
    });

    test('filter is applied client-side to visibleGoals', () async {
      when(
        () => repository.fetchGoals(),
      ).thenAnswer((_) async => [personal, kilocal, completed]);
      await cubit.load();

      cubit.setFilter(GoalFilter.personal);
      expect(
        cubit.state.visibleGoals.map((g) => g.id),
        containsAll(['p1', 'c1']),
      );

      cubit.setFilter(GoalFilter.kilocal);
      expect(cubit.state.visibleGoals.map((g) => g.id), ['k1']);

      cubit.setFilter(GoalFilter.completed);
      expect(cubit.state.visibleGoals.map((g) => g.id), ['c1']);

      cubit.setFilter(GoalFilter.all);
      expect(cubit.state.visibleGoals, hasLength(3));
    });

    test('toggleCompleted updates completion optimistically', () async {
      when(() => repository.fetchGoals()).thenAnswer((_) async => [personal]);
      when(
        () => repository.updateGoalCompletion(
          id: any(named: 'id'),
          completed: any(named: 'completed'),
        ),
      ).thenAnswer((_) async {});
      await cubit.load();

      final ok = await cubit.toggleCompleted(personal);

      expect(ok, isTrue);
      expect(cubit.state.goals.single.isCompleted, isTrue);
      verify(
        () => repository.updateGoalCompletion(id: 'p1', completed: true),
      ).called(1);
    });

    // Regression: a failed PATCH used to trigger a full reload() via load(),
    // and a subsequent fetchGoals() that omitted the goal made it vanish from
    // state.goals entirely (so from every filter, including "Tutti"). The fix
    // reverts locally instead of reloading, so the goal always stays.
    test(
      'toggleCompleted on a Kilocal goal reverts locally on failure without reloading',
      () async {
        when(() => repository.fetchGoals()).thenAnswer((_) async => [kilocal]);
        when(
          () => repository.updateGoalCompletion(
            id: any(named: 'id'),
            completed: any(named: 'completed'),
          ),
        ).thenThrow(Exception('boom'));
        await cubit.load();

        final ok = await cubit.toggleCompleted(kilocal);

        expect(ok, isFalse);
        // Goal is still present, unchanged, and visible under "Tutti".
        expect(cubit.state.goals, [kilocal]);
        expect(cubit.state.visibleGoals, [kilocal]);
        // fetchGoals was only called once, by the initial load() — no reload.
        verify(() => repository.fetchGoals()).called(1);
      },
    );

    test('deleteGoal removes goal and rolls back on failure', () async {
      when(
        () => repository.fetchGoals(),
      ).thenAnswer((_) async => [personal, kilocal]);
      when(() => repository.deleteGoal(any())).thenThrow(Exception('fail'));
      await cubit.load();

      await cubit.deleteGoal(personal);

      // rolled back: both goals present again, status error
      expect(cubit.state.goals, hasLength(2));
      expect(cubit.state.status, DiaryGoalsStatus.error);
    });

    test('createGoal prepends the created goal', () async {
      when(() => repository.fetchGoals()).thenAnswer((_) async => [kilocal]);
      when(
        () => repository.createGoal(any()),
      ).thenAnswer((_) async => personal);
      await cubit.load();

      await cubit.createGoal(
        const DiaryGoalInput(content: 'Personal goal', category: '4'),
      );

      expect(cubit.state.goals.first.id, 'p1');
      expect(cubit.state.goals, hasLength(2));
    });
  });

  // Sanity: DiaryArea maps backend internal names to the fixed enum.
  test('DiaryArea.fromInternalName maps known roots and falls back', () {
    expect(
      DiaryArea.fromInternalName('alimentazione'),
      DiaryArea.alimentazione,
    );
    expect(DiaryArea.fromInternalName('nope'), DiaryArea.unknown);
    expect(DiaryArea.fromInternalName(null), DiaryArea.unknown);
  });
}
