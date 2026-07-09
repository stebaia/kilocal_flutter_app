import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import 'dto/current_user_dto.dart';
import 'dto/directus_file_dto.dart';
import 'dto/success_response_dto.dart';

part 'user_api.g.dart';

/// Retrofit client for Directus user endpoints.
///
/// See `wiki/user-current.md`:
/// - `GET /users/me` returns the authenticated Directus user; `id` is `myId`.
@RestApi()
abstract class UserApi {
  factory UserApi(Dio dio, {String? baseUrl}) = _UserApi;

  /// `GET /users/me` — returns the current user wrapped in `data`.
  ///
  /// The `fields` parameter matches the wiki spec:
  /// `id,email,first_name,last_name,role.name`.
  @GET('/users/me')
  Future<CurrentUserResponseDto> getCurrentUser(@Query('fields') String fields);

  /// `PATCH /profile` — updates `directus_users`, `user_addresses` and
  /// `user_details` in one call. The free-form body is routed by field name
  /// server-side (see `wiki/profilo.md`). Returns `{ "success": true }`.
  @PATCH('/profile')
  Future<SuccessResponseDto> updateProfile(@Body() Map<String, dynamic> body);

  /// `POST /files` — Directus core multipart upload. Returns the created file
  /// wrapped in `data`; its `id` is used as the avatar reference.
  ///
  /// Note: `avatar` lives on `directus_users`, so it must be written with
  /// [updateCurrentUser] (`PATCH /users/me`), NOT `PATCH /profile` (which routes
  /// unknown fields to `user_details`). See [[avatar-upload-flow]].
  @POST('/files')
  @MultiPart()
  Future<DirectusFileResponseDto> uploadFile(@Part(name: 'file') MultipartFile file);

  /// `PATCH /users/me` — updates the authenticated `directus_users` row. Used to
  /// set `avatar` to the uploaded file id.
  ///
  /// Returns `void`: the response echoes the full user with `role` as a plain id
  /// (not the expanded `{name}` this DTO expects), so we don't parse it — callers
  /// re-fetch via `GET /users/me` (`loadSession`) instead.
  @PATCH('/users/me')
  Future<void> updateCurrentUser(@Body() Map<String, dynamic> body);
}
