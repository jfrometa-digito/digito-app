import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/auth_service.dart';
import '../services/auth0_service.dart';
import '../services/mock_auth_service.dart';
import '../../domain/models/auth_user.dart';

part 'auth_provider.g.dart';

// TODO: Replace with your Auth0 credentials
const String _auth0Domain = 'YOUR_AUTH0_DOMAIN.auth0.com';
const String _auth0ClientId = 'YOUR_AUTH0_CLIENT_ID';

/// Provider for the authentication service
@Riverpod(keepAlive: true)
AuthService authService(AuthServiceRef ref) {
  // Use mock auth service for development
  // TODO: Switch to Auth0Service when ready for production
  return MockAuthService();

  // For production with Auth0:
  // return Auth0Service(
  //   domain: _auth0Domain,
  //   clientId: _auth0ClientId,
  // );
}

/// Provider for the current authenticated user
@riverpod
Future<AuthUser?> currentUser(CurrentUserRef ref) async {
  final authService = ref.watch(authServiceProvider);
  return await authService.getCurrentUser();
}

/// Provider for authentication status
@riverpod
Future<bool> isAuthenticated(IsAuthenticatedRef ref) async {
  final authService = ref.watch(authServiceProvider);
  return await authService.isAuthenticated();
}
