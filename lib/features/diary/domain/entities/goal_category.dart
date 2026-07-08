import 'package:equatable/equatable.dart';

/// A selectable category for a personal goal (from the `goal_categories`
/// catalog). Verified ids on staging: 3 Benessere, 4 Attività esterne, 5 Fashion.
class GoalCategory extends Equatable {
  const GoalCategory({required this.id, required this.title});

  final String id;
  final String title;

  @override
  List<Object?> get props => [id, title];
}
