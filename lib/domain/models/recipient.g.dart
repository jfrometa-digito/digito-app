// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipient.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Recipient _$RecipientFromJson(Map<String, dynamic> json) => Recipient(
      name: json['name'] as String,
      email: json['email'] as String,
      id: json['id'] as String?,
    );

Map<String, dynamic> _$RecipientToJson(Recipient instance) => <String, dynamic>{
      'name': instance.name,
      'email': instance.email,
      'id': instance.id,
    };
