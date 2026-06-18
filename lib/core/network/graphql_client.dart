import 'package:dio/dio.dart';

import 'api_exception.dart';

/// Raw GraphQL client over the shared [Dio] instance.
///
/// Directus exposes a single `POST /graphql` endpoint that returns `200` even on
/// logical errors, so callers must inspect the top-level `errors` array
/// ([[graphql]], [[errors]]). No GraphQL package is used — queries are plain
/// strings and variables are a JSON map.
class GraphqlClient {
  GraphqlClient({required Dio dio}) : _dio = dio;

  final Dio _dio;

  /// Executes a GraphQL query and returns the response body.
  ///
  /// The returned map contains the `data` and optional `errors` keys. This method
  /// throws [ApiException] if the HTTP call fails or if the GraphQL response
  /// contains errors.
  Future<Map<String, dynamic>> query(
    String query, {
    Map<String, dynamic>? variables,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/graphql',
        data: <String, dynamic>{
          'query': query,
          // ignore: use_null_aware_elements
          if (variables != null) 'variables': variables,
        },
      );

      final body = response.data;
      if (body == null) {
        throw const ApiException(
          type: ApiErrorType.unknown,
          statusCode: 200,
          message: 'Empty GraphQL response',
        );
      }

      final errors = body['errors'];
      if (errors is List && errors.isNotEmpty) {
        final first = errors.first as Map<String, dynamic>;
        final extensions = first['extensions'] as Map<String, dynamic>?;
        final code = extensions?['code'] as String?;
        throw ApiException(
          type: _typeForGraphqlCode(code),
          statusCode: response.statusCode,
          code: code,
          message: first['message'] as String?,
        );
      }

      return body;
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  static ApiErrorType _typeForGraphqlCode(String? code) {
    switch (code) {
      case 'TOKEN_EXPIRED':
      case 'INVALID_TOKEN':
      case 'FORBIDDEN':
        return ApiErrorType.forbidden;
      default:
        return ApiErrorType.unknown;
    }
  }
}
