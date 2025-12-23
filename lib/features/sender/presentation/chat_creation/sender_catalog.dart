import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

Catalog createSenderCatalog({
  required Function(String message) onMessageSent,
  required VoidCallback onUploadPressed,
}) {
  return Catalog([
    CatalogItem(
      name: 'flowSelector',
      dataSchema: S.object(
        properties: {},
      ),
      widgetBuilder: (args) {
        return FlowSelectionCard(
          onSelect: (type) {
            String readableFn;
            switch (type) {
              case 'selfSign':
                readableFn = "I want to sign it myself.";
                break;
              case 'oneOnOne':
                readableFn = "I want to send it to one person.";
                break;
              case 'multiParty':
                readableFn = "I want to send it to multiple people.";
                break;
              default:
                readableFn = "Selected $type";
            }
            onMessageSent(readableFn);
          },
        );
      },
    ),
    CatalogItem(
      name: 'fileUploader',
      dataSchema: S.object(properties: {}),
      widgetBuilder: (args) {
        return FileUploadCard(onPressed: onUploadPressed);
      },
    ),
    CatalogItem(
      name: 'draftSummary',
      dataSchema: S.object(
        properties: {
          'fileName': S.string(
            description: 'The name of the selected file',
          ),
          'recipientCount': S.integer(
            description: 'The number of recipients added',
          ),
          'status': S.string(
            description: 'The status of the draft (e.g., "Draft", "Ready")',
          ),
        },
        required: ['fileName', 'recipientCount', 'status'],
      ),
      widgetBuilder: (args) {
        final data = args.data as Map<String, dynamic>;
        return DraftSummaryCard(
          fileName: data['fileName'] as String,
          recipientCount: data['recipientCount'] as int,
          status: data['status'] as String,
        );
      },
    ),
    CatalogItem(
      name: 'recipientList',
      dataSchema: S.object(
        properties: {
          'recipients': S.string(
            description: 'Comma separated list of recipients',
          ),
        },
        required: ['recipients'],
      ),
      widgetBuilder: (args) {
        final data = args.data as Map<String, dynamic>;
        return RecipientListCard(
          recipients: data['recipients'] as String,
        );
      },
    ),
  ]);
}

// --- Widgets ---

class FlowSelectionCard extends StatelessWidget {
  final Function(String) onSelect;

  const FlowSelectionCard({super.key, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("Select a Workflow",
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('Sign Yourself'),
            subtitle: const Text('You are the only signer'),
            leading: const Icon(Icons.person),
            onTap: () => onSelect('selfSign'),
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('One-on-One'),
            subtitle: const Text('Send to one person'),
            leading: const Icon(Icons.person_outline),
            onTap: () => onSelect('oneOnOne'),
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('Multi-Party'),
            subtitle: const Text('Send to multiple people'),
            leading: const Icon(Icons.people),
            onTap: () => onSelect('multiParty'),
          ),
        ],
      ),
    );
  }
}

class FileUploadCard extends StatelessWidget {
  final VoidCallback onPressed;
  const FileUploadCard({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      child: InkWell(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.all(24),
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.cloud_upload, size: 48, color: Colors.blue),
              SizedBox(height: 16),
              Text("Tap to Upload Document", style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}

class DraftSummaryCard extends StatelessWidget {
  final String fileName;
  final int recipientCount;
  final String status;

  const DraftSummaryCard({
    super.key,
    required this.fileName,
    required this.recipientCount,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Draft Summary',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const Divider(),
            _buildRow(Icons.description, 'File:', fileName),
            const SizedBox(height: 8),
            _buildRow(Icons.people, 'Recipients:', '$recipientCount'),
            const SizedBox(height: 8),
            _buildRow(Icons.info, 'Status:', status),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(width: 8),
        Expanded(child: Text(value)),
      ],
    );
  }
}

class RecipientListCard extends StatelessWidget {
  final String recipients;

  const RecipientListCard({super.key, required this.recipients});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recipients',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const Divider(),
            if (recipients.isEmpty)
              const Text('No recipients added yet.')
            else
              Text(recipients),
          ],
        ),
      ),
    );
  }
}
