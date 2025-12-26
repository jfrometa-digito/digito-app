import 'package:digito_app/l10n/app_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/providers/logger_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/widgets/error_boundary.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/providers/locale_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Firebase for web platform (required for Firebase AI)
  // if (kIsWeb) {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // }

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
    UncontrolledProviderScope(container: container, child: const DigitoApp()),
  );
}

class DigitoApp extends ConsumerWidget {
  const DigitoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(appThemeModeProvider);
    final locale = ref.watch(appLocaleProvider);

    return GlobalErrorHandler(
      child: MaterialApp.router(
        title: 'Digito',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        routerConfig: router,
        locale: locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('es')],
        builder: (context, child) {
          return child ?? const SizedBox.shrink();
        },
      ),
    );
  }
}
