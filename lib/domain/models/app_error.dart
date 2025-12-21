/// Types of errors that can occur in the application
enum ErrorType {
  /// Network connectivity issues
  network,

  /// Authentication/authorization errors
  auth,

  /// Validation errors (user input)
  validation,

  /// Server-side errors (5xx)
  server,

  /// Unknown or unexpected errors
  unknown,
}

/// Recovery actions that can be suggested to the user
enum RecoveryAction {
  /// Retry the failed operation
  retry,

  /// Go back to previous screen
  goBack,

  /// Log in again
  reAuthenticate,

  /// Contact support
  contactSupport,

  /// Dismiss and continue
  dismiss,
}

/// Standardized error model for the application
class AppError {
  /// Type of error
  final ErrorType type;

  /// User-friendly error message
  final String userMessage;

  /// Technical error message (for logging)
  final String? technicalMessage;

  /// Suggested recovery actions
  final List<RecoveryAction> recoveryActions;

  /// Original exception (if any)
  final Object? originalException;

  /// Stack trace (if any)
  final StackTrace? stackTrace;

  const AppError({
    required this.type,
    required this.userMessage,
    this.technicalMessage,
    this.recoveryActions = const [RecoveryAction.dismiss],
    this.originalException,
    this.stackTrace,
  });

  /// Factory for network errors
  factory AppError.network({String? message}) {
    return AppError(
      type: ErrorType.network,
      userMessage: message ??
          'No internet connection. Please check your network and try again.',
      recoveryActions: [RecoveryAction.retry, RecoveryAction.dismiss],
    );
  }

  /// Factory for authentication errors
  factory AppError.auth({String? message, Object? exception}) {
    return AppError(
      type: ErrorType.auth,
      userMessage: message ?? 'Authentication failed. Please log in again.',
      recoveryActions: [RecoveryAction.reAuthenticate, RecoveryAction.dismiss],
      originalException: exception,
    );
  }

  /// Factory for validation errors
  factory AppError.validation(String message) {
    return AppError(
      type: ErrorType.validation,
      userMessage: message,
      recoveryActions: [RecoveryAction.dismiss],
    );
  }

  /// Factory for server errors
  factory AppError.server({String? message}) {
    return AppError(
      type: ErrorType.server,
      userMessage: message ?? 'Server error. Please try again later.',
      recoveryActions: [RecoveryAction.retry, RecoveryAction.contactSupport],
    );
  }

  /// Factory for unknown errors
  factory AppError.unknown({Object? exception, StackTrace? stackTrace}) {
    return AppError(
      type: ErrorType.unknown,
      userMessage: 'An unexpected error occurred. Please try again.',
      technicalMessage: exception?.toString(),
      recoveryActions: [RecoveryAction.retry, RecoveryAction.contactSupport],
      originalException: exception,
      stackTrace: stackTrace,
    );
  }

  @override
  String toString() {
    return 'AppError(type: $type, userMessage: $userMessage, technicalMessage: $technicalMessage)';
  }
}
