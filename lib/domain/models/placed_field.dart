import 'package:flutter/painting.dart';
import 'package:json_annotation/json_annotation.dart';

part 'placed_field.g.dart';

enum FieldType { signature, initials, date, text }

@JsonSerializable(explicitToJson: true)
class PlacedField {
  final String id;
  final FieldType type;

  // Custom converter for Offset needed if we want to serialize it easily
  @JsonKey(fromJson: _offsetFromJson, toJson: _offsetToJson)
  final Offset position;

  final int pageNumber;
  final String? assignedToEmail;

  PlacedField({
    required this.id,
    required this.type,
    required this.position,
    required this.pageNumber,
    this.assignedToEmail,
  });

  PlacedField copyWith({Offset? position, String? assignedToEmail}) {
    return PlacedField(
      id: id,
      type: type,
      position: position ?? this.position,
      pageNumber: pageNumber,
      assignedToEmail: assignedToEmail ?? this.assignedToEmail,
    );
  }

  factory PlacedField.fromJson(Map<String, dynamic> json) =>
      _$PlacedFieldFromJson(json);
  Map<String, dynamic> toJson() => _$PlacedFieldToJson(this);

  static Offset _offsetFromJson(Map<String, dynamic> json) =>
      Offset((json['dx'] as num).toDouble(), (json['dy'] as num).toDouble());

  static Map<String, dynamic> _offsetToJson(Offset offset) =>
      {'dx': offset.dx, 'dy': offset.dy};
}
