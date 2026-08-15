import 'package:dio/dio.dart';

import 'app_failure.dart';

/// Translates transport-level exceptions into [AppFailure]s so the rest of
/// the app never has to know Dio (or any other client) exists.
AppFailure mapExceptionToFailure(Object error) {
  if (error is AppFailure) return error;

  if (error is DioException) {
    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => const TimeoutFailure(),
      DioExceptionType.connectionError => const NoConnectionFailure(),
      DioExceptionType.badResponse => ServerFailure(
        statusCode: error.response?.statusCode,
      ),
      DioExceptionType.cancel => const UnknownFailure(
        'Żądanie zostało anulowane.',
      ),
      DioExceptionType.badCertificate => const UnknownFailure(
        'Nieprawidłowy certyfikat serwera.',
      ),
      DioExceptionType.unknown => const NoConnectionFailure(),
      _ => const UnknownFailure(),
    };
  }

  if (error is FormatException) {
    return const InvalidResponseFailure();
  }

  return const UnknownFailure();
}
