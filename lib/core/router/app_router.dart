import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/sender/presentation/chat_creation/chat_creation_screen.dart';
import '../../features/sender/presentation/dashboard_screen.dart';
import '../../features/sender/presentation/document_select_screen.dart';
import '../../features/sender/presentation/recipient_screen.dart';
import '../../features/sender/presentation/editor_screen.dart';
import '../../features/sender/presentation/review_screen.dart';
import '../../features/signer/presentation/signing_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/sender/presentation/widgets/share_link_view.dart';
import '../../features/sender/providers/requests_provider.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(Ref ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) => SelectionArea(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/create-chat',
            name: 'create_chat',
            builder: (context, state) => const ChatCreationScreen(),
          ),
          GoRoute(
            path: '/create',
            name: 'create',
            builder: (context, state) => const DocumentSelectScreen(),
          ),
          GoRoute(
            path: '/recipients',
            name: 'recipients',
            builder: (context, state) => const RecipientScreen(),
          ),
          GoRoute(
            path: '/editor/:requestId',
            name: 'editor',
            builder: (context, state) => const EditorScreen(),
          ),
          GoRoute(
            path: '/review',
            name: 'review',
            builder: (context, state) => const ReviewScreen(),
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
          // Request Details Route
          GoRoute(
            path: '/details/:requestId',
            name: 'details',
            builder: (context, state) {
              final requestId = state.pathParameters['requestId']!;
              final requests = ref.watch(requestsProvider).value ?? [];
              final request = requests.firstWhere((r) => r.id == requestId);
              return RequestDetailsView(
                request: request,
                onAction: () => context.go('/'),
                actionLabel: 'Back to Dashboard',
              );
            },
          ),
        ],
      ),
    ],
  );
}
