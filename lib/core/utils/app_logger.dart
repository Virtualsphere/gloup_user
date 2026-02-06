import 'dart:developer' as developer;

class AppLogger {
  AppLogger._();

  static const String _tag = 'Gloup';

  /// Log debug message
  static void debug(String message, {String? tag}) {
    developer.log(
      message,
      name: tag ?? _tag,
      level: 500,
    );
  }

  /// Log info message
  static void info(String message, {String? tag}) {
    developer.log(
      message,
      name: tag ?? _tag,
      level: 800,
    );
  }

  /// Log warning message
  static void warning(String message, {String? tag}) {
    developer.log(
      message,
      name: tag ?? _tag,
      level: 900,
    );
  }

  /// Log error message
  static void error(String message, {Object? error, StackTrace? stackTrace, String? tag}) {
    developer.log(
      message,
      name: tag ?? _tag,
      error: error,
      stackTrace: stackTrace,
      level: 1000,
    );
  }
}
