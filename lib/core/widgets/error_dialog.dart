import 'package:flutter/material.dart';

import '../../domain/models/app_error.dart';

/// Reusable error dialog with recovery actions
class ErrorDialog extends StatelessWidget {
  final AppError error;
  final Function(RecoveryAction)? onAction;

  const ErrorDialog({
    super.key,
    required this.error,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      icon: Icon(
        _getErrorIcon(error.type),
        size: 48,
        color: colorScheme.error,
      ),
      title: Text(_getErrorTitle(error.type)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            error.userMessage,
            style: TextStyle(color: colorScheme.onSurface),
          ),
        ],
      ),
      actions: _buildActions(context),
    );
  }

  IconData _getErrorIcon(ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return Icons.wifi_off;
      case ErrorType.auth:
        return Icons.security;
      case ErrorType.validation:
        return Icons.info;
      case ErrorType.server:
        return Icons.cloud_off;
      case ErrorType.unknown:
        return Icons.warning_amber;
    }
  }

  String _getErrorTitle(ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return 'Connection Error';
      case ErrorType.auth:
        return 'Authentication Error';
      case ErrorType.validation:
        return 'Invalid Input';
      case ErrorType.server:
        return 'Server Error';
      case ErrorType.unknown:
        return 'Unexpected Error';
    }
  }

  List<Widget> _buildActions(BuildContext context) {
    final actions = <Widget>[];

    for (final action in error.recoveryActions) {
      actions.add(
        _buildActionButton(context, action),
      );
    }

    return actions;
  }

  Widget _buildActionButton(BuildContext context, RecoveryAction action) {
    final isPrimary = action == RecoveryAction.retry ||
        action == RecoveryAction.reAuthenticate;

    if (isPrimary) {
      return FilledButton(
        onPressed: () {
          Navigator.of(context).pop();
          onAction?.call(action);
        },
        child: Text(_getActionText(action)),
      );
    } else {
      return TextButton(
        onPressed: () {
          Navigator.of(context).pop();
          onAction?.call(action);
        },
        child: Text(_getActionText(action)),
      );
    }
  }

  String _getActionText(RecoveryAction action) {
    switch (action) {
      case RecoveryAction.retry:
        return 'Try Again';
      case RecoveryAction.goBack:
        return 'Go Back';
      case RecoveryAction.reAuthenticate:
        return 'Log In';
      case RecoveryAction.contactSupport:
        return 'Contact Support';
      case RecoveryAction.dismiss:
        return 'Dismiss';
    }
  }

  /// Show error dialog
  static Future<void> show(
    BuildContext context,
    AppError error, {
    Function(RecoveryAction)? onAction,
  }) {
    return showDialog(
      context: context,
      builder: (context) => ErrorDialog(
        error: error,
        onAction: onAction,
      ),
    );
  }
}
