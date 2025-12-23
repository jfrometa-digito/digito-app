import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/error_handler_service.dart';
import 'logger_provider.dart';

part 'error_handler_provider.g.dart';

/// Provider for the error handler service
@Riverpod(keepAlive: true)
ErrorHandlerService errorHandler(Ref ref) {
  final logger = ref.watch(loggerProvider);
  return ErrorHandlerService(logger);
}
