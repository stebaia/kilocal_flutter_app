import 'entities/home_data.dart';

/// Repository contract for the home screen dashboard data.
///
/// Implementations read from `POST /graphql` via [GraphqlClient].
abstract class HomeRepository {
  /// Fetches all data needed to render the home screen.
  ///
  /// [myId] is the authenticated Directus user id.
  /// [currentMonth] is `active_timeframe.sort` (1, 2 or 3).
  /// [userName] is the greeting name already loaded in session.
  Future<HomeData> fetchHome({
    required String myId,
    required int currentMonth,
    required String userName,
  });
}
