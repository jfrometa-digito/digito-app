import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/auth_service.dart';
import '../services/mock_auth_service.dart';
import '../../domain/models/auth_user.dart';

part 'auth_provider.g.dart';

/// Provider for the authentication service
@Riverpod(keepAlive: true)
AuthService authService(Ref ref) {
  // Use mock auth service for development
  return MockAuthService();
}

/// Provider for the current authenticated user
@riverpod
Future<AuthUser?> currentUser(Ref ref) async {
  final authService = ref.watch(authServiceProvider);
  return await authService.getCurrentUser();
}

/// Provider for authentication status
@riverpod
Future<bool> isAuthenticated(Ref ref) async {
  final authService = ref.watch(authServiceProvider);
  return await authService.isAuthenticated();
}
