import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/models/auth_user.dart';
import '../../domain/models/app_error.dart';
import 'auth_service.dart';

/// Auth0 implementation of the AuthService
class Auth0Service implements AuthService {
  final Auth0 _auth0;
  final FlutterSecureStorage _storage;

  static const String _accessTokenKey = 'auth0_access_token';
  static const String _refreshTokenKey = 'auth0_refresh_token';
  static const String _userKey = 'auth0_user';

  Auth0Service({
    required String domain,
    required String clientId,
  })  : _auth0 = Auth0(domain, clientId),
        _storage = const FlutterSecureStorage();

  @override
  Future<AuthUser> login({AuthProvider? provider}) async {
    try {
      final credentials = await _performLogin(provider);

      // Store tokens securely
      await _storage.write(
          key: _accessTokenKey, value: credentials.accessToken);
      if (credentials.refreshToken != null) {
        await _storage.write(
            key: _refreshTokenKey, value: credentials.refreshToken);
      }

      // Get user info
      final userInfo = credentials.user;
      final authUser = AuthUser(
        id: userInfo.sub,
        email: userInfo.email ?? '',
        name: userInfo.name,
        picture: userInfo.pictureUrl?.toString(),
        emailVerified: userInfo.isEmailVerified == true ? DateTime.now() : null,
      );

      // Store user data
      await _storage.write(key: _userKey, value: authUser.toJson().toString());

      return authUser;
    } on WebAuthenticationException catch (e) {
      throw AppError.auth(
        message: 'Login failed: ${e.message}',
        exception: e,
      );
    } catch (e, stackTrace) {
      throw AppError.unknown(exception: e, stackTrace: stackTrace);
    }
  }

  Future<Credentials> _performLogin(AuthProvider? provider) async {
    // Build login options with connection parameter for specific OAuth provider
    final options = <String, dynamic>{};

    if (provider != null) {
      switch (provider) {
        case AuthProvider.google:
          options['connection'] = 'google-oauth2';
          break;
        case AuthProvider.apple:
          options['connection'] = 'apple';
          break;
        case AuthProvider.microsoft:
          options['connection'] = 'windowslive';
          break;
        case AuthProvider.email:
          // Use Auth0's default username-password connection
          options['connection'] = 'Username-Password-Authentication';
          break;
      }
    }

    if (kIsWeb) {
      // Web uses loginWithRedirect pattern
      return await _auth0.webAuthentication().login(
            parameters:
                options.isNotEmpty ? options.cast<String, String>() : {},
          );
    } else {
      // Mobile/Desktop uses loginWithBrowser (native SDK)
      return await _auth0.webAuthentication(scheme: 'digito').login(
            parameters:
                options.isNotEmpty ? options.cast<String, String>() : {},
          );
    }
  }

  @override
  Future<void> logout() async {
    try {
      if (kIsWeb) {
        await _auth0.webAuthentication().logout();
      } else {
        await _auth0.webAuthentication(scheme: 'digito').logout();
      }

      // Clear stored data
      await _storage.delete(key: _accessTokenKey);
      await _storage.delete(key: _refreshTokenKey);
      await _storage.delete(key: _userKey);
    } catch (e, stackTrace) {
      throw AppError.unknown(exception: e, stackTrace: stackTrace);
    }
  }

  @override
  Future<AuthUser?> getCurrentUser() async {
    try {
      final userJson = await _storage.read(key: _userKey);
      if (userJson == null) return null;

      // Parse stored user data
      // Note: You may need to implement proper JSON parsing here
      // For now, returning null if no user stored
      return null; // TODO: Implement proper JSON parsing
    } catch (e) {
      return null;
    }
  }

  @override
  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  @override
  Future<bool> isAuthenticated() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<String?> refreshToken() async {
    try {
      final refreshToken = await _storage.read(key: _refreshTokenKey);
      if (refreshToken == null) return null;

      final newCredentials = await _auth0.api.renewCredentials(
        refreshToken: refreshToken,
      );

      // Update stored tokens
      await _storage.write(
          key: _accessTokenKey, value: newCredentials.accessToken);
      if (newCredentials.refreshToken != null) {
        await _storage.write(
            key: _refreshTokenKey, value: newCredentials.refreshToken);
      }

      return newCredentials.accessToken;
    } catch (e) {
      // If refresh fails, user needs to log in again
      await logout();
      return null;
    }
  }
}
