import 'package:dio/dio.dart';

import 'api_exception.dart';

/// Converts every [DioException] into a typed [ApiException] so the rest of the
/// app never deals with raw Dio errors. See `wiki/flutter-architecture.md`
/// (centralized error mapping) and [ApiException].
class ErrorInterceptor extends Interceptor {
  const ErrorInterceptor();

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: ApiException.fromDio(err),
      ),
    );
  }
}
