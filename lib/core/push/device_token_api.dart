import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'device_token_api.g.dart';

/// Retrofit client for the FCM device-token endpoints under `/profile`.
///
/// See the "Kilocal App" OpenAPI spec (`/profile/device-tokens`): both verbs are
/// bearer-authenticated and act on the calling user's own tokens.
@RestApi()
abstract class DeviceTokenApi {
  factory DeviceTokenApi(Dio dio, {String? baseUrl}) = _DeviceTokenApi;

  /// `POST /profile/device-tokens` — upserts the token for this user+platform.
  ///
  /// Body: `{ "token": "<fcm-token>", "platform": "ios"|"android"|"web" }`.
  /// Responds 201 (created) or 200 (updated) with no body we consume.
  @POST('/profile/device-tokens')
  Future<void> register(@Body() Map<String, dynamic> body);

  /// `DELETE /profile/device-tokens` — removes the token on logout/revoke.
  ///
  /// Body carries only `{ "token": ... }` (no `platform`); responds 204, or 404
  /// if the token is already gone.
  @DELETE('/profile/device-tokens')
  Future<void> unregister(@Body() Map<String, dynamic> body);
}
