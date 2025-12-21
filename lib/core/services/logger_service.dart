import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;

/// Abstract interface for a logging service.
abstract class LoggerService {
  /// Logs a standard message.
  void log(String message);

  /// Logs an error with optional stack trace.
  void error(String message, [dynamic error, StackTrace? stackTrace]);
}

/// Implementation of [LoggerService] that prints to the console.
/// Uses ANSI color codes for specific message types if creating valid output.
class ConsoleLoggerService implements LoggerService {
  @override
  void log(String message) {
    if (kDebugMode) {
      developer.log(message, name: 'Digito');
    }
  }

  @override
  void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      developer.log(
        message,
        name: 'Digito',
        error: error,
        stackTrace: stackTrace,
        level: 1000, // Severe level
      );
    }
  }
}
