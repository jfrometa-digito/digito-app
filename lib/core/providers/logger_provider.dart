import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/logger_service.dart';

part 'logger_provider.g.dart';

@Riverpod(keepAlive: true)
LoggerService logger(Ref ref) {
  return ConsoleLoggerService();
}
