import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/error_handler_provider.dart';
import '../widgets/error_dialog.dart';
import '../../domain/models/app_error.dart';

/// Global error boundary that catches and displays errors
class ErrorBoundary extends ConsumerStatefulWidget {
  final Widget child;

  const ErrorBoundary({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends ConsumerState<ErrorBoundary> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  /// Handle errors that bubble up from child widgets
  void handleError(Object error, StackTrace stackTrace) {
    final errorHandler = ref.read(errorHandlerProvider);
    final appError = errorHandler.handleError(error, stackTrace);

    // Show error dialog if we have a valid context
    if (mounted && context.mounted) {
      ErrorDialog.show(
        context,
        appError,
        onAction: (action) {
          _handleRecoveryAction(action, appError);
        },
      );
    }
  }

  void _handleRecoveryAction(RecoveryAction action, AppError error) {
    switch (action) {
      case RecoveryAction.retry:
        // For retry, we might want to trigger whatever failed again
        // This is application-specific
        break;
      case RecoveryAction.goBack:
        if (mounted && context.mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
        break;
      case RecoveryAction.reAuthenticate:
        // Navigate to login
        // This would typically use go_router
        break;
      case RecoveryAction.contactSupport:
        // Open support email or URL
        break;
      case RecoveryAction.dismiss:
        // Do nothing, dialog already dismissed
        break;
    }
  }
}

/// Wrapper widget that provides error handling to the entire app
class GlobalErrorHandler extends ConsumerWidget {
  final Widget child;

  const GlobalErrorHandler({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ErrorBoundary(
      child: child,
    );
  }
}
