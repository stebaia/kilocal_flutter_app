import '../data/dto/register_response_dto.dart';

/// Repository contract for authentication.
///
/// Implementations talk to the Directus CMS via Bearer JWT. All methods throw
/// [ApiException] on expected API errors and propagate lower-level exceptions
/// (e.g. network) as-is.
abstract class AuthRepository {
  /// Logs the user in and persists the returned tokens.
  Future<void> login({required String email, required String password});

  /// Registers a new user with the Kilocal survey extension.
  Future<RegisterResponseDto> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String passwordConfirm,
    bool? privacyAccepted,
    bool? newsletterAccepted,
  });

  /// Invalidates the refresh token on the server and clears local tokens.
  Future<void> logout();

  /// Requests a password-reset email. Always succeeds from the caller's
  /// perspective (the backend never reveals whether the email exists).
  Future<void> requestPasswordReset({required String email});

  /// Whether an access token is currently stored locally.
  Future<bool> get isAuthenticated;
}
