import 'dart:typed_data';
import 'package:json_annotation/json_annotation.dart';
import 'placed_field.dart';
import 'recipient.dart';

part 'signature_request.g.dart';

enum RequestStatus {
  draft,
  sent,
  completed,
  declined,
}

enum SignatureRequestType {
  selfSign,
  oneOnOne,
  multiParty,
}

@JsonSerializable(explicitToJson: true)
class SignatureRequest {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final RequestStatus status;

  final List<Recipient> recipients;
  final List<PlacedField> fields;
  final String? filePath; // Path to local file (Mobile/Desktop)
  final String? signUrl; // Shareable link for signing
  final SignatureRequestType type; // Type of signature flow

  // Transient field for Web support (not serialized)
  @JsonKey(includeFromJson: false, includeToJson: false)
  final Uint8List? fileBytes;

  const SignatureRequest({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.status,
    this.updatedAt,
    this.recipients = const [],
    this.fields = const [],
    this.filePath,
    this.fileBytes,
    this.signUrl,
    this.type = SignatureRequestType.multiParty,
  });

  SignatureRequest copyWith({
    String? title,
    RequestStatus? status,
    DateTime? updatedAt,
    List<Recipient>? recipients,
    List<PlacedField>? fields,
    String? filePath,
    Uint8List? fileBytes,
    String? signUrl,
    SignatureRequestType? type,
  }) {
    return SignatureRequest(
      id: id,
      title: title ?? this.title,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      recipients: recipients ?? this.recipients,
      fields: fields ?? this.fields,
      filePath: filePath ?? this.filePath,
      fileBytes: fileBytes ?? this.fileBytes,
      signUrl: signUrl ?? this.signUrl,
      type: type ?? this.type,
    );
  }

  factory SignatureRequest.fromJson(Map<String, dynamic> json) =>
      _$SignatureRequestFromJson(json);
  Map<String, dynamic> toJson() => _$SignatureRequestToJson(this);
}
