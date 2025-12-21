import '../../domain/models/app_error.dart';
import 'logger_service.dart';

/// Error handler service for centralized error processing
class ErrorHandlerService {
  final LoggerService _logger;

  ErrorHandlerService(this._logger);

  /// Process an error and convert it to AppError
  AppError handleError(Object error, [StackTrace? stackTrace]) {
    AppError appError;

    if (error is AppError) {
      appError = error;
    } else {
      // Convert different error types
      appError = _convertToAppError(error, stackTrace);
    }

    // Log the error
    _logger.error(
        appError.userMessage, appError.originalException ?? error, stackTrace);

    return appError;
  }

  AppError _convertToAppError(Object error, StackTrace? stackTrace) {
    final errorString = error.toString().toLowerCase();

    // Check for network errors
    if (errorString.contains('socket') ||
        errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('timeout')) {
      return AppError.network();
    }

    // Check for auth errors
    if (errorString.contains('auth') ||
        errorString.contains('unauthorized') ||
        errorString.contains('forbidden') ||
        errorString.contains('401') ||
        errorString.contains('403')) {
      return AppError.auth(exception: error);
    }

    // Check for server errors
    if (errorString.contains('500') ||
        errorString.contains('502') ||
        errorString.contains('503') ||
        errorString.contains('server error')) {
      return AppError.server();
    }

    // Default to unknown error
    return AppError.unknown(exception: error, stackTrace: stackTrace);
  }

  /// Get a user-friendly message for recovery actions
  String getRecoveryActionText(RecoveryAction action) {
    switch (action) {
      case RecoveryAction.retry:
        return 'Try Again';
      case RecoveryAction.goBack:
        return 'Go Back';
      case RecoveryAction.reAuthenticate:
        return 'Log In Again';
      case RecoveryAction.contactSupport:
        return 'Contact Support';
      case RecoveryAction.dismiss:
        return 'Dismiss';
    }
  }
}
