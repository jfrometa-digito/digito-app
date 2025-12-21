import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/providers/logger_provider.dart';

void main() {
  final container = ProviderContainer();
  final logger = container.read(loggerProvider);

  // Flutter Framework Errors
  FlutterError.onError = (details) {
    logger.error('Flutter Framework Error', details.exception, details.stack);
  };

  // Platform/Async Errors
  PlatformDispatcher.instance.onError = (error, stack) {
    logger.error('Platform Error', error, stack);
    return true; // Prevent default behavior (e.g. fatal crash)
  };

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const DigitoApp(),
    ),
  );
}

class DigitoApp extends ConsumerWidget {
  const DigitoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Digito',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
