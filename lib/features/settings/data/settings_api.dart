import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import 'settings_dto.dart';

part 'settings_api.g.dart';

/// Retrofit client for the shop settings endpoint (`wiki/settings.md`).
///
/// `GET /api/settings` — no auth. Returns global shop configuration. On error the
/// backend returns `{ "settings": {} }` with **no** error status code
/// (see `wiki/contradictions.md` §5), so callers can't distinguish "empty config"
/// from "error" via status — handle an empty map defensively.
@RestApi()
abstract class SettingsApi {
  factory SettingsApi(Dio dio, {String? baseUrl}) = _SettingsApi;

  @GET('/api/settings')
  Future<SettingsDto> getSettings();
}
