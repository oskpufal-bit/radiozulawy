/// Common representation of everything that can go wrong when the app talks
/// to the outside world (network, storage, parsing).
///
/// Kept intentionally small — features are expected to switch over this
/// sealed type (`switch (failure) { NetworkFailure() => ..., ... }`) rather
/// than inspect stack traces or raw exceptions.
sealed class AppFailure {
  const AppFailure(this.message);

  /// Human-readable (developer-facing) description. Screens should map this
  /// to a localized, user-facing message rather than showing it directly.
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Device has no usable internet connection.
final class NoConnectionFailure extends AppFailure {
  const NoConnectionFailure([super.message = 'Brak połączenia z internetem.']);
}

/// Request took too long to complete.
final class TimeoutFailure extends AppFailure {
  const TimeoutFailure([
    super.message = 'Przekroczono czas oczekiwania na odpowiedź.',
  ]);
}

/// Server responded with an error status code (4xx/5xx).
final class ServerFailure extends AppFailure {
  const ServerFailure({
    required this.statusCode,
    String message = 'Wystąpił błąd serwera.',
  }) : super(message);

  final int? statusCode;
}

/// Server responded but the payload could not be parsed/understood.
final class InvalidResponseFailure extends AppFailure {
  const InvalidResponseFailure([
    super.message = 'Otrzymano nieprawidłową odpowiedź.',
  ]);
}

/// Anything that doesn't fit the categories above.
final class UnknownFailure extends AppFailure {
  const UnknownFailure([super.message = 'Wystąpił nieznany błąd.']);
}
