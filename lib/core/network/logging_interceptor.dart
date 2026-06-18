import 'dart:developer';

import 'package:dio/dio.dart';

/// Logs every outgoing request and incoming response/error to the Dart debugger.
///
/// Only enabled in debug builds via `DioClient`. Never log sensitive data such
/// as passwords in production; this interceptor is intended for local debugging
/// only.
class LoggingInterceptor extends Interceptor {
  const LoggingInterceptor();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    log('➡️ ${options.method} ${options.uri}', name: 'HTTP');
    log('   headers: ${options.headers}', name: 'HTTP');
    log('   body: ${options.data}', name: 'HTTP');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    log(
      '✅ ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.uri}',
      name: 'HTTP',
    );
    log('   response: ${response.data}', name: 'HTTP');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    log(
      '❌ ${err.response?.statusCode ?? 'NET'} ${err.requestOptions.method} ${err.requestOptions.uri}',
      name: 'HTTP',
    );
    log('   error: ${err.message}', name: 'HTTP');
    log('   response: ${err.response?.data}', name: 'HTTP');
    handler.next(err);
  }
}
