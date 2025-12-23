import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart'; // No prefix, assume S is a class
import 'package:digito_app/features/sender/providers/requests_provider.dart';
import 'package:digito_app/domain/models/signature_request.dart';
import 'package:digito_app/domain/models/recipient.dart';

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
                    'The type of request: "selfSign", "oneOnOne", "multiParty"',
                enumValues: const ['selfSign', 'oneOnOne', 'multiParty'],
              ),
            },
            required: ['type'],
          ),
        );

  @override
  Future<Map<String, dynamic>> invoke(Map<String, dynamic> args) async {
    final typeStr = args['type'] as String;
    SignatureRequestType type;
    switch (typeStr) {
      case 'selfSign':
        type = SignatureRequestType.selfSign;
        break;
      case 'multiParty':
        type = SignatureRequestType.multiParty;
        break;
      case 'oneOnOne':
      default:
        type = SignatureRequestType.oneOnOne;
        break;
    }
    await activeDraft.updateType(type);
    return {'status': 'success', 'type': typeStr};
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

    await activeDraft.addRecipient(Recipient(
      id: DateTime.now()
          .millisecondsSinceEpoch
          .toString(), // Generating a temporary ID
      name: name,
      email: email,
      role: 'signer', // Default role
    ));

    return {'status': 'success', 'added': email};
  }
}
