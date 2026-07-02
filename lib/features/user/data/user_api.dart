import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import 'dto/current_user_dto.dart';
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
}
