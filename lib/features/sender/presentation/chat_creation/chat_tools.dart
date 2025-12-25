import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart'; // No prefix, assume S is a class
import 'package:digito_app/features/sender/providers/requests_provider.dart';
import 'package:digito_app/domain/models/signature_request.dart';
import 'package:digito_app/domain/models/recipient.dart';

Map<String, int> _constraintsFor(SignatureRequestType type) {
  switch (type) {
    case SignatureRequestType.selfSign:
      return {'min': 1, 'max': 1};
    case SignatureRequestType.oneOnOne:
      return {'min': 2, 'max': 2};
    case SignatureRequestType.multiParty:
      return {'min': 3, 'max': 10};
  }
}

Map<String, dynamic> _snapshotDraft(SignatureRequest? draft) {
  return {
    'flowType': draft?.type.name,
    'fileName': draft?.title,
    'hasFile': (draft?.filePath?.isNotEmpty ?? false) || draft?.fileBytes != null,
    'recipientCount': draft?.recipients.length ?? 0,
    'recipients': (draft?.recipients ?? [])
        .map((r) => {'name': r.name, 'email': r.email})
        .toList(),
    'status': draft?.status.name,
    'signUrl': draft?.signUrl,
    'constraints': _constraintsFor(draft?.type ?? SignatureRequestType.oneOnOne),
  };
}

class SetRequestTypeTool extends AiTool<Map<String, dynamic>> {
  final ActiveDraft activeDraft;

  SetRequestTypeTool(this.activeDraft)
      : super(
          name: 'setRequestType',
          description: 'Sets the type of the signature request.',
          parameters: S.object(
            properties: {
              'type': S.string(
                description:
                    'The type of request: selfSign / oneOnOne / multiParty',
                enumValues: const ['selfSign', 'oneOnOne', 'multiParty'],
              ),
            },
            required: ['type'],
          ),
        );

  @override
  Future<Map<String, dynamic>> invoke(Map<String, dynamic> args) async {
    final typeStr = args['type'] as String;
    final type = switch (typeStr) {
      'selfSign' => SignatureRequestType.selfSign,
      'multiParty' => SignatureRequestType.multiParty,
      _ => SignatureRequestType.oneOnOne,
    };

    await activeDraft.updateType(type);

    final current = activeDraft.current;
    if (current != null) {
      final constraints = _constraintsFor(type);
      final max = constraints['max']!;
      if (current.recipients.length > max) {
        await activeDraft.updateRecipients(current.recipients.take(max).toList());
      }
    }

    return {
      'status': 'success',
      'type': typeStr,
      'constraints': _constraintsFor(type),
      'draft': _snapshotDraft(activeDraft.current),
    };
  }
}

class GetDraftStateTool extends AiTool<Map<String, dynamic>> {
  final ActiveDraft activeDraft;

  GetDraftStateTool(this.activeDraft)
      : super(
          name: 'getDraftState',
          description: 'Returns the current signature draft state and constraints.',
          parameters: S.object(properties: {}),
        );

  @override
  Future<Map<String, dynamic>> invoke(Map<String, dynamic> args) async {
    return {
      'status': 'success',
      'draft': _snapshotDraft(activeDraft.current),
    };
  }
}

class SendRequestTool extends AiTool<Map<String, dynamic>> {
  final ActiveDraft activeDraft;

  SendRequestTool(this.activeDraft)
      : super(
          name: 'sendRequest',
          description:
              'Finalizes and sends the signature request. Fails if file or recipients are missing.',
          parameters: S.object(properties: {}),
        );

  @override
  Future<Map<String, dynamic>> invoke(Map<String, dynamic> args) async {
    final current = activeDraft.current;
    if (current == null) {
      return {'status': 'error', 'message': 'No active draft'};
    }

    final constraints = _constraintsFor(current.type);
    final hasFile =
        (current.filePath?.isNotEmpty ?? false) || current.fileBytes != null;
    final count = current.recipients.length;
    final min = constraints['min']!;
    final max = constraints['max']!;

    if (!hasFile || count < min || count > max) {
      return {
        'status': 'error',
        'message': 'Draft incomplete',
        'hasFile': hasFile,
        'recipientCount': count,
        'constraints': constraints,
        'draft': _snapshotDraft(current),
      };
    }

    await activeDraft.markAsSent();
    return {
      'status': 'sent',
      'signUrl': activeDraft.current?.signUrl,
      'draft': _snapshotDraft(activeDraft.current),
    };
  }
}

class AddRecipientTool extends AiTool<Map<String, dynamic>> {
  final ActiveDraft activeDraft;

  AddRecipientTool(this.activeDraft)
      : super(
          name: 'addRecipient',
          description: 'Adds a recipient to the draft.',
          parameters: S.object(
            properties: {
              'name': S.string(description: 'Name'),
              'email': S.string(description: 'Email'),
            },
            required: ['name', 'email'],
          ),
        );

  @override
  Future<Map<String, dynamic>> invoke(Map<String, dynamic> args) async {
    final name = args['name'] as String;
    final email = args['email'] as String;
    final current = activeDraft.current;
    final type = current?.type ?? SignatureRequestType.oneOnOne;
    final constraints = _constraintsFor(type);
    final max = constraints['max']!;

    if ((current?.recipients.length ?? 0) >= max) {
      return {
        'status': 'error',
        'message': 'Max recipients reached for $type',
        'constraints': constraints,
        'draft': _snapshotDraft(current),
      };
    }

    await activeDraft.addRecipient(Recipient(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email,
      role: 'signer',
    ));

    return {
      'status': 'success',
      'added': email,
      'constraints': constraints,
      'draft': _snapshotDraft(activeDraft.current),
    };
  }
}
