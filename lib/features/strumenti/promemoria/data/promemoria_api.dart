import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import 'dto/user_reminder_dto.dart';

part 'promemoria_api.g.dart';

/// Retrofit client for the calendar-reminder endpoints under `/tools/reminders`.
///
/// See `wiki/swagger.md` ("Kilocal App" tab, `Strumenti` tag): these return
/// calendar reminders only (no `category`/`related_goal`; journal goals live on
/// `/journal/goals`). Body shape is [UserReminderInput] server-side.
@RestApi()
abstract class PromemoriaApi {
  factory PromemoriaApi(Dio dio, {String? baseUrl}) = _PromemoriaApi;

  /// `GET /tools/reminders` — all calendar reminders for the current user.
  @GET('/tools/reminders')
  Future<UserRemindersResponseDto> list();

  /// `POST /tools/reminders` — create a reminder.
  ///
  /// The response is `{ "data": <newId> }` (a bare id, **not** the created row —
  /// the Swagger `UserReminder` schema is inaccurate here), so we don't parse a
  /// body; callers re-fetch via [list]. See [[promemoria-tool-status]].
  @POST('/tools/reminders')
  Future<void> create(@Body() Map<String, dynamic> body);

  /// `PATCH /tools/reminders/{id}` — update fields of an existing reminder.
  @PATCH('/tools/reminders/{id}')
  Future<void> update(
    @Path('id') String id,
    @Body() Map<String, dynamic> body,
  );

  /// `DELETE /tools/reminders/{id}` — remove a reminder (`204`).
  @DELETE('/tools/reminders/{id}')
  Future<void> delete(@Path('id') String id);
}
