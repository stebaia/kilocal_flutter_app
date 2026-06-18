import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import 'dto/current_user_dto.dart';

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
}
