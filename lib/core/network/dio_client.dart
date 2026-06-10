import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../config/env.dart';
import 'auth_interceptor.dart';
import 'cookie_store.dart';
import 'error_interceptor.dart';

/// Builds the shared [Dio] instance backing every Retrofit client.
///
/// From `wiki/flutter-architecture.md`: Retrofit over Dio, with interceptors for
/// cookie + Bearer auth, single-shot token refresh, and centralized error
/// mapping. CORS-aligned: requests carry credentials (the Bearer header; on web,
/// `withCredentials` sends cookies) and target the configured `SHOP_URL`.
class DioClient {
  DioClient({
    required CookieStore cookieStore,
    void Function()? onAuthExpired,
  }) {
    _dio = _baseDio();

    // Bare client (no auth interceptor) used for token refresh and retries to
    // avoid recursive 401 handling.
    final refreshClient = _baseDio();

    _dio.interceptors.addAll([
      AuthInterceptor(
        cookieStore: cookieStore,
        refreshClient: refreshClient,
        onAuthExpired: onAuthExpired,
      ),
      const ErrorInterceptor(),
      if (kDebugMode)
        PrettyDioLogger(requestHeader: true, requestBody: true),
    ]);
  }

  late final Dio _dio;

  Dio get dio => _dio;

  static Dio _baseDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: Env.shopUrl,
        connectTimeout: Env.timeout,
        receiveTimeout: Env.timeout,
        sendTimeout: Env.timeout,
        contentType: Headers.jsonContentType,
        headers: {'Accept': 'application/json'},
      ),
    );
    // Send cookies on web (`credentials: 'include'`, see wiki/authentication.md).
    dio.options.extra['withCredentials'] = true;
    return dio;
  }
}
