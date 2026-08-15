import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Thin wrapper around `package:logger`, silenced outside debug builds.
///
/// Callers must never pass tokens, credentials, submission contents or other
/// personal data — see docs/ARCHITECTURE.md for the logging policy.
class AppLogger {
  AppLogger._();

  static final Logger _logger = Logger(
    filter: _DebugOnlyFilter(),
    printer: PrettyPrinter(
      methodCount: 0,
      colors: false,
      printEmojis: false,
      dateTimeFormat: DateTimeFormat.none,
    ),
  );

  static void debug(String message) => _logger.d(message);

  static void info(String message) => _logger.i(message);

  static void warning(String message) => _logger.w(message);

  static void error(String message, [Object? error, StackTrace? stackTrace]) =>
      _logger.e(message, error: error, stackTrace: stackTrace);
}

class _DebugOnlyFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) => kDebugMode;
}
