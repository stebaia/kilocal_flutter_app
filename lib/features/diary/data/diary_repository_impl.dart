import 'package:dio/dio.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/graphql_client.dart';
import '../domain/diary_repository.dart';
import '../domain/entities/diary_activity.dart';
import '../domain/entities/diary_goal.dart';
import '../domain/entities/goal_category.dart';
import 'dto/diary_goal_dto.dart';

/// Diary data source.
///
/// - **Goals** (Traguardi): REST over `/journal/goals` (list/create/update/delete)
///   plus the `goal_categories` catalog via GraphQL.
/// - **History** (Cronologia): GraphQL read of `user_activities`; the linked
///   `percorsi_content` (title + path area) is read inline via the M2A union.
///
/// Shapes below are verified against staging (see docs/diario-api-analisi).
class DiaryRepositoryImpl implements DiaryRepository {
  DiaryRepositoryImpl({required Dio dio, required GraphqlClient graphqlClient})
    : _dio = dio,
      _graphqlClient = graphqlClient;

  final Dio _dio;
  final GraphqlClient _graphqlClient;

  static const _goalsPath = '/journal/goals';

  // `activity.item` is a typed M2A union (articles | percorsi_content |
  // percorsi_materials), so it must be selected with an inline fragment. The
  // step title + path root are read directly here — no second query needed.
  // Verified against staging (authenticated). No `completed_on` filter: the list
  // shows both started-only steps (no green check, completable from the sheet)
  // and completed ones. The collection is matched client-side because the nested
  // M2A filter returns nothing on this instance.
  static const _activitiesQuery = r'''
query GetDiaryActivities($lang: String!, $page: Int = 1) {
  user_activities(page: $page, sort: ["-started_on"]) {
    id
    started_on
    completed_on
    activity {
      collection
      item {
        __typename
        ... on percorsi_content {
          id
          used_in {
            percorsi_groups_id {
              percorso { root { internal_name } }
            }
          }
          translations(filter: { languages_code: { code: { _eq: $lang } } }) {
            title
          }
        }
      }
    }
  }
}
''';

  // Supplement intake, merged into the history client-side. `user_integratori`
  // is already scoped to the caller by the auth token (verified on staging: no
  // kit filter needed), and `took_dates` is a JSON array of `YYYY-MM-DD`
  // strings — date-only, so these entries carry no time of day.
  static const _intakeQuery = r'''
query GetSupplementIntake {
  user_integratori {
    id
    product { id title }
    took_dates
  }
}
''';

  static const _categoriesQuery = r'''
query GetGoalCategories($lang: String!) {
  goal_categories(sort: ["id"]) {
    id
    translations(filter: { languages_code: { code: { _eq: $lang } } }) {
      title
    }
  }
}
''';

  static const _stepsBasePath = '/path/steps';

  // --- History (GraphQL, read-only) ---------------------------------------

  @override
  Future<List<DiaryActivity>> fetchActivities() async {
    try {
      final result = await _graphqlClient.query(
        _activitiesQuery,
        variables: {'lang': _resolveLocale()},
      );
      final data = result['data'] as Map<String, dynamic>?;
      final rows = data?['user_activities'] as List<dynamic>? ?? const [];

      final activities = <DiaryActivity>[];
      for (final row in rows.cast<Map<String, dynamic>>()) {
        final content = _percorsiContentOf(row);
        // The diary lists path steps; skip activities linked to articles or
        // materials (those have no completable step here).
        if (content == null) continue;
        activities.add(
          DiaryActivity(
            id: row['id'].toString(),
            stepId: content['id']?.toString(),
            area: DiaryArea.fromInternalName(_areaOf(content)),
            title: _titleOf(content),
            startedOn: _parseDate(row['started_on'] as String?),
            completedOn: _parseDate(row['completed_on'] as String?),
          ),
        );
      }

      activities.addAll(await _fetchSupplementIntake());
      // Re-sort: the GraphQL `-started_on` ordering only covered the step rows.
      activities.sort((a, b) {
        final aDate = a.completedOn ?? a.startedOn;
        final bDate = b.completedOn ?? b.startedOn;
        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;
        return bDate.compareTo(aDate);
      });
      return activities;
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// One synthesised [DiaryActivity] per (product, day) in `took_dates`.
  ///
  /// These are always complete — an intake is recorded only once taken — and
  /// carry no `stepId`, so `canComplete` stays false and the diary renders them
  /// read-only. A failure here must not blank the whole history, so it degrades
  /// to an empty list.
  Future<List<DiaryActivity>> _fetchSupplementIntake() async {
    try {
      final result = await _graphqlClient.query(_intakeQuery);
      final data = result['data'] as Map<String, dynamic>?;
      final rows = data?['user_integratori'] as List<dynamic>? ?? const [];

      final entries = <DiaryActivity>[];
      for (final row in rows.cast<Map<String, dynamic>>()) {
        final product = row['product'] as Map<String, dynamic>?;
        final title = product?['title'] as String?;
        final dates = row['took_dates'] as List<dynamic>? ?? const [];
        for (final raw in dates) {
          final day = _parseDate(raw as String?);
          if (day == null) continue;
          entries.add(
            DiaryActivity(
              // `took_dates` rows have no id of their own; the tracking row id
              // plus the day is unique and stable across reloads.
              id: 'integratore-${row['id']}-${raw as String}',
              area: DiaryArea.integrazione,
              title: title,
              startedOn: day,
              completedOn: day,
            ),
          );
        }
      }
      return entries;
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<void> completeActivity({
    required String stepId,
    required DiaryArea area,
  }) async {
    // Steps are completed through the path endpoint (not a direct PATCH): it
    // also advances `percorso_*_curr_step` and the active timeframe, which a
    // raw `user_activities` write would leave inconsistent (see Swagger).
    try {
      await _dio.post<Map<String, dynamic>>(
        '$_stepsBasePath/$stepId/complete',
        data: <String, dynamic>{'percorsoInternalName': area.internalName},
      );
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// The `percorsi_content` item embedded in a `user_activities` row, or `null`
  /// if the activity links to a different collection (article/material).
  Map<String, dynamic>? _percorsiContentOf(Map<String, dynamic> row) {
    final links = row['activity'] as List<dynamic>?;
    for (final link in links ?? const []) {
      final map = link as Map<String, dynamic>;
      final item = map['item'] as Map<String, dynamic>?;
      if (item != null && item['__typename'] == 'percorsi_content') {
        return item;
      }
    }
    return null;
  }

  String? _titleOf(Map<String, dynamic> content) {
    final translations = content['translations'] as List<dynamic>?;
    return (translations?.firstOrNull as Map<String, dynamic>?)?['title']
        as String?;
  }

  /// Path root (`internal_name`) of the content. A content item can belong to
  /// several percorsi, but the root is stable — take the first non-null.
  String? _areaOf(Map<String, dynamic> content) {
    final usedIn = content['used_in'] as List<dynamic>?;
    for (final u in usedIn ?? const []) {
      final group =
          (u as Map<String, dynamic>)['percorsi_groups_id']
              as Map<String, dynamic>?;
      final percorso = group?['percorso'] as Map<String, dynamic>?;
      final root = percorso?['root'] as Map<String, dynamic>?;
      final name = root?['internal_name'] as String?;
      if (name != null) return name;
    }
    return null;
  }

  // --- Goals (REST, CRUD) --------------------------------------------------

  @override
  Future<List<DiaryGoal>> fetchGoals() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(_goalsPath);
      final dto = DiaryGoalsResponseDto.fromJson(response.data ?? const {});
      return dto.data.map(_mapGoal).toList();
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  @override
  Future<DiaryGoal> createGoal(DiaryGoalInput input) async {
    try {
      // POST returns only the new id (`{"data": 614}`), so reconstruct the goal
      // locally from the input rather than expecting a full object back.
      final response = await _dio.post<Map<String, dynamic>>(
        _goalsPath,
        data: <String, dynamic>{
          'content': input.content,
          if (input.dueDate != null) 'due_date': _formatDate(input.dueDate!),
          if (input.category != null) 'category': input.category,
          if (input.relatedGoal != null) 'related_goal': input.relatedGoal,
        },
      );
      final id = response.data?['data'];
      return DiaryGoal(
        id: id?.toString() ?? '',
        kind: input.relatedGoal != null
            ? DiaryGoalKind.kilocal
            : DiaryGoalKind.personal,
        content: input.content,
        dueDate: input.dueDate,
        category: input.category,
        relatedGoal: input.relatedGoal,
      );
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  @override
  Future<DiaryGoal> updateGoal(String id, DiaryGoalInput input) async {
    try {
      await _dio.patch<Map<String, dynamic>>(
        '$_goalsPath/$id',
        data: <String, dynamic>{
          'content': input.content,
          'due_date': input.dueDate != null
              ? _formatDate(input.dueDate!)
              : null,
          if (input.category != null) 'category': input.category,
          if (input.relatedGoal != null) 'related_goal': input.relatedGoal,
        },
      );
      // PATCH returns no body (see [[diario]]); re-fetch to get the
      // authoritative row rather than assuming the write round-tripped as-is.
      final goals = await fetchGoals();
      final updated = goals.where((g) => g.id == id).firstOrNull;
      if (updated == null) {
        throw const ApiException(
          type: ApiErrorType.notFound,
          statusCode: 404,
          message: 'Goal not found after update',
        );
      }
      return updated;
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  @override
  Future<void> updateGoalCompletion({
    required String id,
    required bool completed,
  }) async {
    try {
      await _dio.patch<Map<String, dynamic>>(
        '$_goalsPath/$id',
        data: <String, dynamic>{
          'completed_at': completed
              ? DateTime.now().toUtc().toIso8601String()
              : null,
        },
      );
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  @override
  Future<void> deleteGoal(String id) async {
    try {
      await _dio.delete<void>('$_goalsPath/$id');
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  @override
  Future<List<GoalCategory>> fetchCategories() async {
    try {
      final result = await _graphqlClient.query(
        _categoriesQuery,
        variables: {'lang': _resolveLocale()},
      );
      final data = result['data'] as Map<String, dynamic>?;
      final rows = data?['goal_categories'] as List<dynamic>? ?? const [];
      return rows.cast<Map<String, dynamic>>().map((row) {
        final translations = row['translations'] as List<dynamic>?;
        final title =
            (translations?.firstOrNull as Map<String, dynamic>?)?['title']
                as String?;
        return GoalCategory(id: row['id'].toString(), title: title ?? '');
      }).toList();
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  DiaryGoal _mapGoal(DiaryGoalDto dto) {
    // A goal carries either a `category` (personal) or a `related_goal`
    // (predefined Kilocal). `related_goal` wins the "Kilocal" badge.
    final kind = dto.relatedGoal != null
        ? DiaryGoalKind.kilocal
        : DiaryGoalKind.personal;
    return DiaryGoal(
      id: dto.id,
      kind: kind,
      content: dto.content,
      dueDate: _parseDate(dto.dueDate),
      completedAt: _parseDate(dto.completedAt),
      category: dto.category,
      relatedGoal: dto.relatedGoal,
    );
  }

  String _resolveLocale() => 'it-IT';

  static DateTime? _parseDate(String? value) {
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  static String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
