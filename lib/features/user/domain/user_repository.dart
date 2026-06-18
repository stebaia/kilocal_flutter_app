import 'app_user.dart';
import 'user_details.dart';

/// Repository contract for the authenticated user session.
///
/// Implementations read from `GET /users/me` (REST) and `GetUserDetails`
/// (GraphQL). All methods throw [ApiException] on expected API errors.
abstract class UserRepository {
  /// Fetches the current Directus user (`GET /users/me`).
  ///
  /// The returned [AppUser.id] is `myId`.
  Future<AppUser> fetchCurrentUser();

  /// Fetches the profile details for the user identified by [myId].
  Future<UserDetails> fetchUserDetails(String myId);
}
