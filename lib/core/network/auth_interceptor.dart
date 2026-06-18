import 'package:dio/dio.dart';

import 'token_store.dart';

/// Attaches auth and handles single-shot token refresh on 401.
///
/// From `wiki/authentication.md` and `wiki/flutter-architecture.md`:
/// - authenticated calls send `Authorization: Bearer {access_token}`;
/// - on `401`, attempt `POST /auth/refresh` once, then retry the request;
///   otherwise emit an auth-expired signal and route to login.
///
/// Maps by **status code**, never by message text (PayPal returns its 401 in
/// Italian — see `wiki/contradictions.md` §4).
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({
    required TokenStore tokenStore,
    required Dio refreshClient,
    this.onAuthExpired,
  }) : _tokenStore = tokenStore,
       _refreshClient = refreshClient;

  final TokenStore _tokenStore;

  /// A bare Dio (no AuthInterceptor) used to call the refresh endpoint, to
  /// avoid recursive 401 handling.
  final Dio _refreshClient;

  /// Called when refresh fails / there is no session: the app should move to
  /// the unauthenticated state and route to login.
  final void Function()? onAuthExpired;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenStore.accessToken;
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final isUnauthorized = err.response?.statusCode == 401;
    final alreadyRetried = err.requestOptions.extra['__retried__'] == true;

    if (!isUnauthorized || alreadyRetried) {
      return handler.next(err);
    }

    final refreshed = await _tryRefresh();
    if (!refreshed) {
      onAuthExpired?.call();
      return handler.next(err);
    }

    try {
      final options = err.requestOptions;
      options.extra['__retried__'] = true;
      final token = await _tokenStore.accessToken;
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      final response = await _refreshClient.fetch<dynamic>(options);
      return handler.resolve(response);
    } on DioException catch (e) {
      return handler.next(e);
    }
  }

  Future<bool> _tryRefresh() async {
    final refresh = await _tokenStore.refreshToken;
    if (refresh == null) return false;
    try {
      final res = await _refreshClient.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refresh_token': refresh, 'mode': 'json'},
      );
      final data = res.data?['data'] as Map<String, dynamic>?;
      final access = data?['access_token'] as String?;
      if (access == null) return false;
      await _tokenStore.saveSession(
        accessToken: access,
        refreshToken: data?['refresh_token'] as String?,
      );
      return true;
    } on DioException {
      await _tokenStore.clear();
      return false;
    }
  }
}
