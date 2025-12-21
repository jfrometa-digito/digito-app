import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/services/logger_service.dart';

part 'logger_provider.g.dart';

@Riverpod(keepAlive: true)
LoggerService logger(LoggerRef ref) {
  return ConsoleLoggerService();
}
