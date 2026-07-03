import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Logs every outgoing request and incoming response/error to the Dart debugger.
///
/// This interceptor logs full headers and bodies (which may include tokens,
/// credentials or personal data) and is therefore intended for local debugging
/// only. `DioClient` already registers it only when [kDebugMode] is true, and as
/// a defense-in-depth measure every log call here is also guarded by
/// [kDebugMode] so that no sensitive data can ever be emitted in a release
/// build, even if the interceptor is registered elsewhere by mistake.
class LoggingInterceptor extends Interceptor {
  const LoggingInterceptor();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      log('➡️ ${options.method} ${options.uri}', name: 'HTTP');
      log('   headers: ${options.headers}', name: 'HTTP');
      log('   body: ${options.data}', name: 'HTTP');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      log(
        '✅ ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.uri}',
        name: 'HTTP',
      );
      log('   response: ${response.data}', name: 'HTTP');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      log(
        '❌ ${err.response?.statusCode ?? 'NET'} ${err.requestOptions.method} ${err.requestOptions.uri}',
        name: 'HTTP',
      );
      log('   error: ${err.message}', name: 'HTTP');
      log('   response: ${err.response?.data}', name: 'HTTP');
    }
    handler.next(err);
  }
}
