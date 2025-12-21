import '../../domain/models/auth_user.dart';

/// OAuth/Auth providers supported by the application
enum AuthProvider {
  google,
  apple,
  microsoft,
  email,
}

/// Abstract authentication service interface
abstract class AuthService {
  /// Log in with optional provider
  /// If provider is null, will show universal login page
  Future<AuthUser> login({AuthProvider? provider});

  /// Log out the current user
  Future<void> logout();

  /// Get the currently authenticated user
  /// Returns null if not authenticated
  Future<AuthUser?> getCurrentUser();

  /// Get the current access token
  /// Returns null if not authenticated or token expired
  Future<String?> getAccessToken();

  /// Check if user is authenticated
  Future<bool> isAuthenticated();

  /// Refresh the access token
  Future<String?> refreshToken();
}
