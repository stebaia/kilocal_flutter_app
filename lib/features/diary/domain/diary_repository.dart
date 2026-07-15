import 'entities/diary_activity.dart';
import 'entities/diary_goal.dart';
import 'entities/goal_category.dart';

/// Diary data source.
///
/// Two backing domains (see wiki [[diario]] / [[diario-attivita]]):
/// - **History** (Cronologia): read-only `user_activities` via GraphQL.
/// - **Goals** (Traguardi): CRUD over `/journal/goals` (REST).
abstract class DiaryRepository {
  /// Step history, most recent first — both started-only and completed entries.
  Future<List<DiaryActivity>> fetchActivities();

  /// Marks a started step completed via `POST /path/steps/{stepId}/complete`.
  /// [area] provides the required `percorsoInternalName`.
  Future<void> completeActivity({
    required String stepId,
    required DiaryArea area,
  });

  /// All diary goals (personal + Kilocal). Filtering is done client-side.
  Future<List<DiaryGoal>> fetchGoals();

  /// The `goal_categories` catalog used by the create-goal picker.
  Future<List<GoalCategory>> fetchCategories();

  Future<DiaryGoal> createGoal(DiaryGoalInput input);

  /// Marks a goal completed/uncompleted by setting/clearing `completed_at`.
  Future<void> updateGoalCompletion({
    required String id,
    required bool completed,
  });

  Future<void> deleteGoal(String id);
}
