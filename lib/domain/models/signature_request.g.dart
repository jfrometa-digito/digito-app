// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'signature_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SignatureRequest _$SignatureRequestFromJson(Map<String, dynamic> json) =>
    SignatureRequest(
      id: json['id'] as String,
      title: json['title'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: $enumDecode(_$RequestStatusEnumMap, json['status']),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      recipients:
          (json['recipients'] as List<dynamic>?)
              ?.map((e) => Recipient.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      fields:
          (json['fields'] as List<dynamic>?)
              ?.map((e) => PlacedField.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      filePath: json['filePath'] as String?,
      signUrl: json['signUrl'] as String?,
      type:
          $enumDecodeNullable(_$SignatureRequestTypeEnumMap, json['type']) ??
          SignatureRequestType.multiParty,
    );

Map<String, dynamic> _$SignatureRequestToJson(SignatureRequest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'status': _$RequestStatusEnumMap[instance.status]!,
      'recipients': instance.recipients.map((e) => e.toJson()).toList(),
      'fields': instance.fields.map((e) => e.toJson()).toList(),
      'filePath': instance.filePath,
      'signUrl': instance.signUrl,
      'type': _$SignatureRequestTypeEnumMap[instance.type]!,
    };

const _$RequestStatusEnumMap = {
  RequestStatus.draft: 'draft',
  RequestStatus.sent: 'sent',
  RequestStatus.completed: 'completed',
  RequestStatus.declined: 'declined',
};

const _$SignatureRequestTypeEnumMap = {
  SignatureRequestType.selfSign: 'selfSign',
  SignatureRequestType.oneOnOne: 'oneOnOne',
  SignatureRequestType.multiParty: 'multiParty',
};
