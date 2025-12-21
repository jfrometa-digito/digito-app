import 'package:json_annotation/json_annotation.dart';

part 'auth_user.g.dart';

/// Represents an authenticated user in the application
@JsonSerializable()
class AuthUser {
  final String id;
  final String email;
  final String? name;
  final String? picture;
  final DateTime? emailVerified;
  final String? role; // 'admin' or 'user'

  const AuthUser({
    required this.id,
    required this.email,
    this.name,
    this.picture,
    this.emailVerified,
    this.role = 'user',
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) =>
      _$AuthUserFromJson(json);

  Map<String, dynamic> toJson() => _$AuthUserToJson(this);

  AuthUser copyWith({
    String? id,
    String? email,
    String? name,
    String? picture,
    DateTime? emailVerified,
    String? role,
  }) {
    return AuthUser(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      picture: picture ?? this.picture,
      emailVerified: emailVerified ?? this.emailVerified,
      role: role ?? this.role,
    );
  }
}
