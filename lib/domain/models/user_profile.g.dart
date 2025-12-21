// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => UserProfile(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      picture: json['picture'] as String?,
      role:
          $enumDecodeNullable(_$UserRoleEnumMap, json['role']) ?? UserRole.user,
      status: $enumDecodeNullable(_$AccountStatusEnumMap, json['status']) ??
          AccountStatus.active,
      adhesionContractAccepted:
          json['adhesionContractAccepted'] as bool? ?? false,
      certificateContractAccepted:
          json['certificateContractAccepted'] as bool? ?? false,
      adhesionContractAcceptedAt: json['adhesionContractAcceptedAt'] == null
          ? null
          : DateTime.parse(json['adhesionContractAcceptedAt'] as String),
      certificateContractAcceptedAt:
          json['certificateContractAcceptedAt'] == null
              ? null
              : DateTime.parse(json['certificateContractAcceptedAt'] as String),
      identityValidated: json['identityValidated'] as bool? ?? false,
      identityValidatedAt: json['identityValidatedAt'] == null
          ? null
          : DateTime.parse(json['identityValidatedAt'] as String),
      hasCertificate: json['hasCertificate'] as bool? ?? false,
      certificateId: json['certificateId'] as String?,
      certificateCreatedAt: json['certificateCreatedAt'] == null
          ? null
          : DateTime.parse(json['certificateCreatedAt'] as String),
      certificateRevoked: json['certificateRevoked'] as bool? ?? false,
      certificateRevokedAt: json['certificateRevokedAt'] == null
          ? null
          : DateTime.parse(json['certificateRevokedAt'] as String),
      permissions: (json['permissions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      auth0Id: json['auth0Id'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastAccess: DateTime.parse(json['lastAccess'] as String),
    );

Map<String, dynamic> _$UserProfileToJson(UserProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'name': instance.name,
      'picture': instance.picture,
      'role': _$UserRoleEnumMap[instance.role]!,
      'status': _$AccountStatusEnumMap[instance.status]!,
      'adhesionContractAccepted': instance.adhesionContractAccepted,
      'certificateContractAccepted': instance.certificateContractAccepted,
      'adhesionContractAcceptedAt':
          instance.adhesionContractAcceptedAt?.toIso8601String(),
      'certificateContractAcceptedAt':
          instance.certificateContractAcceptedAt?.toIso8601String(),
      'identityValidated': instance.identityValidated,
      'identityValidatedAt': instance.identityValidatedAt?.toIso8601String(),
      'hasCertificate': instance.hasCertificate,
      'certificateId': instance.certificateId,
      'certificateCreatedAt': instance.certificateCreatedAt?.toIso8601String(),
      'certificateRevoked': instance.certificateRevoked,
      'certificateRevokedAt': instance.certificateRevokedAt?.toIso8601String(),
      'permissions': instance.permissions,
      'auth0Id': instance.auth0Id,
      'createdAt': instance.createdAt.toIso8601String(),
      'lastAccess': instance.lastAccess.toIso8601String(),
    };

const _$UserRoleEnumMap = {
  UserRole.admin: 'admin',
  UserRole.user: 'user',
};

const _$AccountStatusEnumMap = {
  AccountStatus.active: 'active',
  AccountStatus.inactive: 'inactive',
  AccountStatus.disconnected: 'disconnected',
};
