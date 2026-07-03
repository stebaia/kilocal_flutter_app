import 'package:dio/dio.dart';
import 'package:firebase_performance/firebase_performance.dart';

/// Records a Firebase [HttpMetric] for every Dio request.
///
/// Firebase Performance auto-instruments native HTTP stacks, but Dart-level
/// requests made through Dio are invisible to it, so we track them explicitly:
/// method + URL, response payload size, and HTTP status. One metric per request
/// is keyed in `extra` so the matching response/error can stop the right one.
class PerformanceInterceptor extends Interceptor {
  PerformanceInterceptor({FirebasePerformance? performance})
    : _performance = performance ?? FirebasePerformance.instance;

  final FirebasePerformance _performance;

  static const String _metricKey = 'firebase_http_metric';

  HttpMethod _method(String method) {
    switch (method.toUpperCase()) {
      case 'GET':
        return HttpMethod.Get;
      case 'POST':
        return HttpMethod.Post;
      case 'PUT':
        return HttpMethod.Put;
      case 'DELETE':
        return HttpMethod.Delete;
      case 'PATCH':
        return HttpMethod.Patch;
      case 'HEAD':
        return HttpMethod.Head;
      case 'OPTIONS':
        return HttpMethod.Options;
      case 'CONNECT':
        return HttpMethod.Connect;
      case 'TRACE':
        return HttpMethod.Trace;
      default:
        return HttpMethod.Get;
    }
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final metric = _performance.newHttpMetric(
        options.uri.toString(),
        _method(options.method),
      );
      await metric.start();
      options.extra[_metricKey] = metric;
    } catch (_) {
      // Never let instrumentation break a request.
    }
    handler.next(options);
  }

  @override
  Future<void> onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    await _stop(response.requestOptions, response.statusCode, response.data);
    handler.next(response);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    await _stop(
      err.requestOptions,
      err.response?.statusCode,
      err.response?.data,
    );
    handler.next(err);
  }

  Future<void> _stop(
    RequestOptions options,
    int? statusCode,
    Object? data,
  ) async {
    final metric = options.extra.remove(_metricKey);
    if (metric is! HttpMetric) return;
    try {
      if (statusCode != null) metric.httpResponseCode = statusCode;
      if (data is String) metric.responsePayloadSize = data.length;
      await metric.stop();
    } catch (_) {
      // Ignore instrumentation failures.
    }
  }
}
