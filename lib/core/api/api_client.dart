import 'package:dio/dio.dart';

import '../errors/app_failure.dart';
import '../errors/failure_mapper.dart';

/// Thin, testable wrapper around [Dio] that turns transport exceptions into
/// [AppFailure]s.
///
/// Feature data sources should depend on this instead of [Dio] directly so
/// error handling stays consistent and mockable in tests.
class ApiClient {
  ApiClient(this._dio);

  final Dio _dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) => _run(() => _dio.get<T>(path, queryParameters: queryParameters));

  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) => _run(
    () => _dio.post<T>(path, data: data, queryParameters: queryParameters),
  );

  Future<Response<T>> _run<T>(Future<Response<T>> Function() request) async {
    try {
      return await request();
    } catch (error) {
      throw mapExceptionToFailure(error);
    }
  }
}
