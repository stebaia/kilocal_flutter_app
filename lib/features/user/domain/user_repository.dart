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

  /// Updates the profile via `PATCH /profile`. [values] is a free-form map of
  /// field name → value, routed server-side to `directus_users`,
  /// `user_addresses` or `user_details`. Throws [ApiException] on failure or if
  /// the API reports `success: false`.
  Future<void> updateProfile(Map<String, dynamic> values);

  /// Uploads [imageBytes] via `POST /files`, then sets it as the current user's
  /// avatar via `PATCH /users/me`. [filename] names the uploaded file (defaults
  /// applied by the caller). Returns the uploaded file id. Throws [ApiException]
  /// on failure. See [[avatar-upload-flow]].
  Future<String> updateAvatar({
    required List<int> imageBytes,
    required String filename,
  });
}
