import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists the Directus Bearer tokens.
///
/// From `wiki/authentication.md`: the mobile app uses `mode: json` (no cookies).
/// We store the access token and refresh token in secure storage and send the
/// access token as `Authorization: Bearer {access_token}`.
class TokenStore {
  TokenStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _kAccess = 'access_token';
  static const _kRefresh = 'refresh_token';

  Future<String?> get accessToken => _storage.read(key: _kAccess);
  Future<String?> get refreshToken => _storage.read(key: _kRefresh);

  Future<bool> get hasSession async => (await accessToken) != null;

  Future<void> saveSession({
    required String accessToken,
    String? refreshToken,
  }) async {
    await _storage.write(key: _kAccess, value: accessToken);
    if (refreshToken != null) {
      await _storage.write(key: _kRefresh, value: refreshToken);
    }
  }

  Future<void> clear() async {
    await _storage.delete(key: _kAccess);
    await _storage.delete(key: _kRefresh);
  }
}
