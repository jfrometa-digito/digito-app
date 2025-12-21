import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/sender/presentation/dashboard_screen.dart';
import '../../features/sender/presentation/document_select_screen.dart';
import '../../features/sender/presentation/recipient_screen.dart';
import '../../features/sender/presentation/editor_screen.dart';
import '../../features/sender/presentation/review_screen.dart';
import '../../features/signer/presentation/signing_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const DashboardScreen(),
        routes: [
          GoRoute(
            path: 'create',
            name: 'create',
            builder: (context, state) => const DocumentSelectScreen(),
            routes: [
              // Flattened structure: /create/recipients, /create/editor, /create/review
              GoRoute(
                path: 'recipients',
                name: 'recipients',
                builder: (context, state) => const RecipientScreen(),
              ),
              GoRoute(
                path: 'editor',
                name: 'editor',
                builder: (context, state) => const EditorScreen(),
              ),
              GoRoute(
                path: 'review',
                name: 'review',
                builder: (context, state) => const ReviewScreen(),
              ),
            ],
          ),
        ],
      ),
      // Login Route
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      // Profile Route
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      // Signer Route
      GoRoute(
        path: '/sign/:requestId',
        builder: (context, state) {
          final requestId = state.pathParameters['requestId']!;
          return SigningScreen(requestId: requestId);
        },
      ),
    ],
  );
}
