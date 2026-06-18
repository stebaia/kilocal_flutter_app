import 'package:dio/dio.dart';

/// Typed API error.
///
/// Error mapping convention (`wiki/flutter-architecture.md` §Networking concerns
/// and `wiki/contradictions.md` §3): `statusMessage` casing/format is inconsistent
/// across endpoints, so we switch on **HTTP status + a normalized code**, never on
/// the raw message string. PayPal returns its 401 message in Italian
/// (`wiki/contradictions.md` §4) — handled by status code, not text.
enum ApiErrorType {
  network, // no response (timeout, connection)
  unauthorized, // 401
  forbidden, // 403
  notFound, // 404
  badRequest, // 400
  conflict, // 409
  server, // 5xx
  unknown,
}

class ApiException implements Exception {
  const ApiException({
    required this.type,
    required this.statusCode,
    this.code,
    this.message,
  });

  /// Coarse, status-driven category.
  final ApiErrorType type;

  /// HTTP status code, if any.
  final int? statusCode;

  /// Normalized server code (upper-snake-case `statusMessage` when present,
  /// e.g. `DISCOUNT_INVALID`, `MISSING_SHIPPING_ADDRESS`). Match on this, not
  /// on free-text messages.
  final String? code;

  /// Raw, human-readable message (for logs/debugging only — may be localized).
  final String? message;

  /// Maps a [DioException] into a typed [ApiException].
  factory ApiException.fromDio(DioException e) {
    final response = e.response;
    final status = response?.statusCode;

    if (response == null) {
      return ApiException(
        type: ApiErrorType.network,
        statusCode: null,
        message: e.message,
      );
    }

    final code = _extractStatusMessage(response.data);
    return ApiException(
      type: _typeForStatus(status),
      statusCode: status,
      code: code,
      message: code ?? response.statusMessage,
    );
  }

  static ApiErrorType _typeForStatus(int? status) {
    switch (status) {
      case 400:
        return ApiErrorType.badRequest;
      case 401:
        return ApiErrorType.unauthorized;
      case 403:
        return ApiErrorType.forbidden;
      case 404:
        return ApiErrorType.notFound;
      case 409:
        return ApiErrorType.conflict;
      default:
        if (status != null && status >= 500) return ApiErrorType.server;
        return ApiErrorType.unknown;
    }
  }

  /// Nuxt/h3 errors surface as `{ "statusMessage": "..." }` (sometimes nested in
  /// `data`/`message`). Returns the normalized code if present.
  static String? _extractStatusMessage(Object? data) {
    if (data is Map) {
      final v = data['statusMessage'] ?? data['message'] ?? data['error'];
      if (v is String && v.isNotEmpty) return v;
    }
    return null;
  }

  @override
  String toString() =>
      'ApiException(type: $type, status: $statusCode, code: $code)';
}
