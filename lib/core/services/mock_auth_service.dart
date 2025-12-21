import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/models/auth_user.dart';
import '../../domain/models/app_error.dart';
import 'auth_service.dart';

/// Mock authentication service for development/debug mode
/// Supports simple username/password authentication without external services
class MockAuthService implements AuthService {
  final FlutterSecureStorage _storage;

  static const String _accessTokenKey = 'mock_access_token';
  static const String _userKey = 'mock_user';

  // In-memory user database for demo purposes
  // Format: email => {password, role}
  static final Map<String, Map<String, String>> _users = {
    'admin@digito.com': {'password': 'password123', 'role': 'admin'},
    'user@digito.com': {'password': 'password123', 'role': 'user'},
    'demo@digito.com': {'password': 'demo', 'role': 'user'},
  };

  MockAuthService() : _storage = const FlutterSecureStorage();

  @override
  Future<AuthUser> login({AuthProvider? provider}) async {
    // For mock service, we'll return a default test user
    // In a real implementation, you'd show a login dialog
    final authUser = AuthUser(
      id: 'mock_user_${DateTime.now().millisecondsSinceEpoch}',
      email: 'demo@digito.com',
      name: 'Demo User',
      picture: null,
      emailVerified: DateTime.now(),
    );

    // Store mock token and user
    await _storage.write(
        key: _accessTokenKey,
        value: 'mock_token_${DateTime.now().millisecondsSinceEpoch}');
    await _storage.write(key: _userKey, value: jsonEncode(authUser.toJson()));

    return authUser;
  }

  /// Login with username and password
  Future<AuthUser> loginWithCredentials(String email, String password) async {
    // Check credentials
    if (!_users.containsKey(email) || _users[email]!['password'] != password) {
      throw AppError.auth(message: 'Invalid email or password');
    }

    final role = _users[email]!['role'] ?? 'user';

    final authUser = AuthUser(
      id: 'mock_${email.hashCode}',
      email: email,
      name: email.split('@').first.replaceAll('.', ' ').toUpperCase(),
      picture: null,
      emailVerified: DateTime.now(),
      role: role,
    );

    // Store mock token and user
    final token = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';
    await _storage.write(key: _accessTokenKey, value: token);
    await _storage.write(key: _userKey, value: jsonEncode(authUser.toJson()));

    return authUser;
  }

  /// Sign up new user (for demo - just adds to in-memory database)
  Future<AuthUser> signUp(String email, String password, String name) async {
    if (_users.containsKey(email)) {
      throw AppError.validation('Email already exists');
    }

    // Add to in-memory database (default role: user)
    _users[email] = {'password': password, 'role': 'user'};

    final authUser = AuthUser(
      id: 'mock_${email.hashCode}',
      email: email,
      name: name,
      picture: null,
      emailVerified: DateTime.now(),
    );

    // Store mock token and user
    final token = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';
    await _storage.write(key: _accessTokenKey, value: token);
    await _storage.write(key: _userKey, value: jsonEncode(authUser.toJson()));

    return authUser;
  }

  @override
  Future<void> logout() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _userKey);
  }

  @override
  Future<AuthUser?> getCurrentUser() async {
    try {
      final userJson = await _storage.read(key: _userKey);
      if (userJson == null) return null;

      final userMap = jsonDecode(userJson) as Map<String, dynamic>;
      return AuthUser.fromJson(userMap);
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
    // For mock service, just return the current token
    return await getAccessToken();
  }
}
