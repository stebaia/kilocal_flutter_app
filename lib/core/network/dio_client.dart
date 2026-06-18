import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/env.dart';
import 'auth_interceptor.dart';
import 'error_interceptor.dart';
import 'logging_interceptor.dart';
import 'token_store.dart';

/// Builds the shared [Dio] instance backing every Retrofit client.
///
/// From `wiki/flutter-architecture.md`: Retrofit over Dio, with interceptors for
/// Bearer auth, single-shot token refresh, and centralized error mapping.
class DioClient {
  DioClient({required TokenStore tokenStore, void Function()? onAuthExpired}) {
    _dio = _baseDio();

    // Bare client (no auth interceptor) used for token refresh and retries to
    // avoid recursive 401 handling.
    final refreshClient = _baseDio();

    _dio.interceptors.addAll([
      AuthInterceptor(
        tokenStore: tokenStore,
        refreshClient: refreshClient,
        onAuthExpired: onAuthExpired,
      ),
      const ErrorInterceptor(),
      if (kDebugMode) const LoggingInterceptor(),
    ]);
  }

  late final Dio _dio;

  Dio get dio => _dio;

  static Dio _baseDio() {
    return Dio(
      BaseOptions(
        baseUrl: Env.baseUrl,
        connectTimeout: Env.timeout,
        receiveTimeout: Env.timeout,
        sendTimeout: Env.timeout,
        contentType: Headers.jsonContentType,
        headers: {'Accept': 'application/json'},
      ),
    );
  }
}
