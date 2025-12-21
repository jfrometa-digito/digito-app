import 'package:json_annotation/json_annotation.dart';

part 'user_profile.g.dart';

/// User roles in the system
enum UserRole {
  admin,
  user,
}

/// User account status
enum AccountStatus {
  active,
  inactive,
  disconnected,
}

/// Represents a user's profile with extended information
@JsonSerializable()
class UserProfile {
  final String id;
  final String email;
  final String? name;
  final String? picture;
  final UserRole role;
  final AccountStatus status;

  // Contract acceptance flags
  final bool adhesionContractAccepted;
  final bool certificateContractAccepted;
  final DateTime? adhesionContractAcceptedAt;
  final DateTime? certificateContractAcceptedAt;

  // Identity validation
  final bool identityValidated;
  final DateTime? identityValidatedAt;

  // Certificate information
  final bool hasCertificate;
  final String? certificateId;
  final DateTime? certificateCreatedAt;
  final bool certificateRevoked;
  final DateTime? certificateRevokedAt;

  // Assigned permissions (for display purposes)
  final List<String> permissions;

  // Metadata
  final String? auth0Id;
  final DateTime createdAt;
  final DateTime lastAccess;

  const UserProfile({
    required this.id,
    required this.email,
    this.name,
    this.picture,
    this.role = UserRole.user,
    this.status = AccountStatus.active,
    this.adhesionContractAccepted = false,
    this.certificateContractAccepted = false,
    this.adhesionContractAcceptedAt,
    this.certificateContractAcceptedAt,
    this.identityValidated = false,
    this.identityValidatedAt,
    this.hasCertificate = false,
    this.certificateId,
    this.certificateCreatedAt,
    this.certificateRevoked = false,
    this.certificateRevokedAt,
    this.permissions = const [],
    this.auth0Id,
    required this.createdAt,
    required this.lastAccess,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);

  Map<String, dynamic> toJson() => _$UserProfileToJson(this);

  UserProfile copyWith({
    String? id,
    String? email,
    String? name,
    String? picture,
    UserRole? role,
    AccountStatus? status,
    bool? adhesionContractAccepted,
    bool? certificateContractAccepted,
    DateTime? adhesionContractAcceptedAt,
    DateTime? certificateContractAcceptedAt,
    bool? identityValidated,
    DateTime? identityValidatedAt,
    bool? hasCertificate,
    String? certificateId,
    DateTime? certificateCreatedAt,
    bool? certificateRevoked,
    DateTime? certificateRevokedAt,
    List<String>? permissions,
    String? auth0Id,
    DateTime? createdAt,
    DateTime? lastAccess,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      picture: picture ?? this.picture,
      role: role ?? this.role,
      status: status ?? this.status,
      adhesionContractAccepted:
          adhesionContractAccepted ?? this.adhesionContractAccepted,
      certificateContractAccepted:
          certificateContractAccepted ?? this.certificateContractAccepted,
      adhesionContractAcceptedAt:
          adhesionContractAcceptedAt ?? this.adhesionContractAcceptedAt,
      certificateContractAcceptedAt:
          certificateContractAcceptedAt ?? this.certificateContractAcceptedAt,
      identityValidated: identityValidated ?? this.identityValidated,
      identityValidatedAt: identityValidatedAt ?? this.identityValidatedAt,
      hasCertificate: hasCertificate ?? this.hasCertificate,
      certificateId: certificateId ?? this.certificateId,
      certificateCreatedAt: certificateCreatedAt ?? this.certificateCreatedAt,
      certificateRevoked: certificateRevoked ?? this.certificateRevoked,
      certificateRevokedAt: certificateRevokedAt ?? this.certificateRevokedAt,
      permissions: permissions ?? this.permissions,
      auth0Id: auth0Id ?? this.auth0Id,
      createdAt: createdAt ?? this.createdAt,
      lastAccess: lastAccess ?? this.lastAccess,
    );
  }

  /// Check if user is admin
  bool get isAdmin => role == UserRole.admin;

  /// Get status color for UI
  String get statusColor {
    switch (status) {
      case AccountStatus.active:
        return 'green';
      case AccountStatus.inactive:
        return 'orange';
      case AccountStatus.disconnected:
        return 'gray';
    }
  }

  /// Get status label
  String get statusLabel {
    switch (status) {
      case AccountStatus.active:
        return 'Activo';
      case AccountStatus.inactive:
        return 'Inactivo';
      case AccountStatus.disconnected:
        return 'Desconectado';
    }
  }
}
