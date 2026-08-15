import 'package:dio/dio.dart';

import '../utils/app_logger.dart';

/// Development-only request logging.
///
/// Deliberately logs method, path and status code and nothing else —
/// headers, query parameters, request/response bodies are never printed, so
/// tokens, personal data or submission contents can't leak into logs even
/// during development.
class NetworkLoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    AppLogger.debug('--> ${options.method} ${options.path}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    AppLogger.debug(
      '<-- ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.path}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppLogger.warning(
      '<-x ${err.response?.statusCode} ${err.requestOptions.method} ${err.requestOptions.path} (${err.type.name})',
    );
    handler.next(err);
  }
}
