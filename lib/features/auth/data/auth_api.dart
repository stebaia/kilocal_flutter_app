import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import 'dto/auth_tokens_dto.dart';
import 'dto/register_response_dto.dart';

part 'auth_api.g.dart';

/// Retrofit client for Directus auth and Kilocal auth extension endpoints.
///
/// See `wiki/authentication.md`:
/// - `/auth/*` are native Directus endpoints (login, refresh, logout).
/// - `/api/auth/*` are Kilocal survey extension endpoints (register, password).
@RestApi()
abstract class AuthApi {
  factory AuthApi(Dio dio, {String? baseUrl}) = _AuthApi;

  /// `POST /auth/login` — body `{ email, password, mode: "json" }`.
  @POST('/auth/login')
  Future<AuthTokensDto> login(@Body() Map<String, dynamic> body);

  /// `POST /auth/logout` — body `{ refresh_token, mode: "json" }`.
  @POST('/auth/logout')
  Future<HttpResponse<void>> logout(@Body() Map<String, dynamic> body);

  /// `POST /api/auth/register` — Kilocal registration.
  ///
  /// The `X-Kilocal-Origin: app` header marks the mobile client on extension
  /// routes.
  @POST('/api/auth/register')
  Future<RegisterResponseDto> register(
    @Header('X-Kilocal-Origin') String origin,
    @Body() Map<String, dynamic> body,
  );

  /// `POST /api/auth/password-forgotten` — request reset email.
  ///
  /// Backend always returns `200`.
  @POST('/api/auth/password-forgotten')
  Future<HttpResponse<void>> requestPasswordReset(
    @Header('X-Kilocal-Origin') String origin,
    @Body() Map<String, dynamic> body,
  );
}
