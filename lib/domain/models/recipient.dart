import 'package:json_annotation/json_annotation.dart';

part 'recipient.g.dart';

@JsonSerializable()
class Recipient {
  final String name;
  final String email;
  final String? id; // Optional, useful for tracking status per recipient
  final String role; // 'signer', 'reviewer', etc.

  const Recipient({
    required this.name,
    required this.email,
    this.id,
    this.role = 'signer',
  });

  factory Recipient.fromJson(Map<String, dynamic> json) =>
      _$RecipientFromJson(json);
  Map<String, dynamic> toJson() => _$RecipientToJson(this);
}
