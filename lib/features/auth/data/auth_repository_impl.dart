import 'package:dio/dio.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/token_store.dart';
import '../domain/auth_repository.dart';
import 'auth_api.dart';
import 'dto/auth_tokens_dto.dart';
import 'dto/register_response_dto.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({required AuthApi api, required TokenStore tokenStore})
    : _api = api,
      _tokenStore = tokenStore;

  final AuthApi _api;
  final TokenStore _tokenStore;

  @override
  Future<void> login({required String email, required String password}) async {
    try {
      final tokens = await _api.login({
        'email': email,
        'password': password,
        'mode': 'json',
      });
      await _saveTokens(tokens);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  @override
  Future<RegisterResponseDto> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String passwordConfirm,
    bool? privacyAccepted,
    bool? newsletterAccepted,
  }) async {
    try {
      return await _api.register('app', {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'password': password,
        'password_confirm': passwordConfirm,
        'origin': 'app',
        if (privacyAccepted != null) 'privacy_accepted': privacyAccepted,
        if (newsletterAccepted != null)
          'newsletter_accepted': newsletterAccepted,
      });
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  @override
  Future<void> logout() async {
    final refresh = await _tokenStore.refreshToken;
    await _tokenStore.clear();
    if (refresh == null) return;
    try {
      await _api.logout({'refresh_token': refresh, 'mode': 'json'});
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  @override
  Future<void> requestPasswordReset({required String email}) async {
    try {
      await _api.requestPasswordReset('app', {'email': email, 'origin': 'app'});
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  @override
  Future<bool> get isAuthenticated => _tokenStore.hasSession;

  Future<void> _saveTokens(AuthTokensDto tokens) async {
    await _tokenStore.saveSession(
      accessToken: tokens.data.accessToken,
      refreshToken: tokens.data.refreshToken,
    );
  }
}
