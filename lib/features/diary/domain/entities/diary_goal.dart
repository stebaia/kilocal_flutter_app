import 'package:equatable/equatable.dart';

/// A diary goal/milestone (Traguardo) — a `user_reminders` row carrying a
/// `category` (personal) or a `related_goal` (predefined Kilocal catalog).
///
/// Written via `/journal/goals` (POST/PATCH/DELETE).
class DiaryGoal extends Equatable {
  const DiaryGoal({
    required this.id,
    required this.kind,
    this.content,
    this.dueDate,
    this.completedAt,
    this.category,
    this.relatedGoal,
  });

  final String id;

  /// Whether this is a user-defined goal or a predefined Kilocal one, derived
  /// from which of `category` / `related_goal` is set.
  final DiaryGoalKind kind;

  final String? content;
  final DateTime? dueDate;
  final DateTime? completedAt;

  /// Raw backend refs (kept so updates can round-trip the goal untouched).
  final String? category;
  final String? relatedGoal;

  bool get isCompleted => completedAt != null;

  DiaryGoal copyWith({DateTime? completedAt, bool clearCompletedAt = false}) {
    return DiaryGoal(
      id: id,
      kind: kind,
      content: content,
      dueDate: dueDate,
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
      category: category,
      relatedGoal: relatedGoal,
    );
  }

  @override
  List<Object?> get props => [
    id,
    kind,
    content,
    dueDate,
    completedAt,
    category,
    relatedGoal,
  ];
}

/// Personal (`category`) vs predefined Kilocal (`related_goal`) — surfaced as
/// the "Personale" / "Kilocal" badge in the UI.
enum DiaryGoalKind { personal, kilocal }

/// Filter options in the Traguardi filter modal. All derivable client-side from
/// the fields `GET /journal/goals` already returns — no extra API needed.
enum GoalFilter { all, personal, kilocal, completed }

/// Payload for creating/updating a goal via `/journal/goals`.
class DiaryGoalInput extends Equatable {
  const DiaryGoalInput({
    required this.content,
    this.dueDate,
    this.category,
    this.relatedGoal,
  });

  final String content;
  final DateTime? dueDate;

  /// One of [category] / [relatedGoal] must be set (personal vs catalog).
  final String? category;
  final String? relatedGoal;

  @override
  List<Object?> get props => [content, dueDate, category, relatedGoal];
}
