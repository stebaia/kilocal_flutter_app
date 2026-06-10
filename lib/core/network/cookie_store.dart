import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists the Directus session cookies / tokens.
///
/// From `wiki/authentication.md`: session state is held in cookies set by
/// Directus — `klkl-data` (access+refresh session token) and
/// `klkl_refresh_token` — with a 7-day duration. Authenticated requests send
/// credentials and an `Authorization: Bearer {access_token}`.
class CookieStore {
  CookieStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _kData = 'klkl-data';
  static const _kRefresh = 'klkl_refresh_token';
  static const _kAccess = 'access_token';

  Future<String?> get accessToken => _storage.read(key: _kAccess);
  Future<String?> get refreshToken => _storage.read(key: _kRefresh);
  Future<String?> get sessionData => _storage.read(key: _kData);

  Future<bool> get hasSession async => (await accessToken) != null;

  Future<void> saveSession({
    required String accessToken,
    String? refreshToken,
    String? sessionData,
  }) async {
    await _storage.write(key: _kAccess, value: accessToken);
    if (refreshToken != null) {
      await _storage.write(key: _kRefresh, value: refreshToken);
    }
    if (sessionData != null) {
      await _storage.write(key: _kData, value: sessionData);
    }
  }

  Future<void> clear() async {
    await _storage.delete(key: _kAccess);
    await _storage.delete(key: _kRefresh);
    await _storage.delete(key: _kData);
  }
}
