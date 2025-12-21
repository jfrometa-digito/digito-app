// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'placed_field.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlacedField _$PlacedFieldFromJson(Map<String, dynamic> json) => PlacedField(
      id: json['id'] as String,
      type: $enumDecode(_$FieldTypeEnumMap, json['type']),
      position:
          PlacedField._offsetFromJson(json['position'] as Map<String, dynamic>),
      pageNumber: (json['pageNumber'] as num).toInt(),
      assignedToEmail: json['assignedToEmail'] as String?,
    );

Map<String, dynamic> _$PlacedFieldToJson(PlacedField instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$FieldTypeEnumMap[instance.type]!,
      'position': PlacedField._offsetToJson(instance.position),
      'pageNumber': instance.pageNumber,
      'assignedToEmail': instance.assignedToEmail,
    };

const _$FieldTypeEnumMap = {
  FieldType.signature: 'signature',
  FieldType.initials: 'initials',
  FieldType.date: 'date',
  FieldType.text: 'text',
};
