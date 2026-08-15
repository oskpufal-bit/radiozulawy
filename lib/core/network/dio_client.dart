import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../app/config/app_config.dart';
import 'network_logging_interceptor.dart';

/// Builds a [Dio] instance pre-configured with the app's base URL, timeouts
/// and (debug-only) sanitized request logging.
///
/// Individual features should not construct their own [Dio] instances;
/// inject this one (see `dioProvider`) so timeout/error behaviour stays
/// consistent app-wide.
Dio createDioClient({String? baseUrl}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl ?? AppConfig.apiBaseUrl,
      connectTimeout: AppConfig.connectTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
      sendTimeout: AppConfig.sendTimeout,
    ),
  );

  if (kDebugMode) {
    dio.interceptors.add(NetworkLoggingInterceptor());
  }

  return dio;
}
