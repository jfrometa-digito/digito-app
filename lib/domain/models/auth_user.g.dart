// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthUser _$AuthUserFromJson(Map<String, dynamic> json) => AuthUser(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      picture: json['picture'] as String?,
      emailVerified: json['emailVerified'] == null
          ? null
          : DateTime.parse(json['emailVerified'] as String),
      role: json['role'] as String? ?? 'user',
    );

Map<String, dynamic> _$AuthUserToJson(AuthUser instance) => <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'name': instance.name,
      'picture': instance.picture,
      'emailVerified': instance.emailVerified?.toIso8601String(),
      'role': instance.role,
    };
