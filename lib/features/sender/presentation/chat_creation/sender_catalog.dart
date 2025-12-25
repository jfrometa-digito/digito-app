import 'package:digito_app/core/providers/auth_provider.dart';
import 'package:digito_app/domain/models/recipient.dart';
import 'package:digito_app/domain/models/signature_request.dart';
import 'package:digito_app/features/sender/providers/requests_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

Catalog createSenderCatalog() {
  return Catalog([
    CatalogItem(
      name: 'flowSelector',
      dataSchema: S.object(properties: {}),
      widgetBuilder: (args) => _FlowSelectorSurface(args: args),
    ),
    CatalogItem(
      name: 'fileUploader',
      dataSchema: S.object(properties: {}),
      widgetBuilder: (args) => _FileUploadSurface(args: args),
    ),
    CatalogItem(
      name: 'recipientManager',
      dataSchema: S.object(
        properties: {
          'minRecipients': S.integer(),
          'maxRecipients': S.integer(),
        },
      ),
      widgetBuilder: (args) => _RecipientManagerSurface(args: args),
    ),
    CatalogItem(
      name: 'draftSummary',
      dataSchema: S.object(
        properties: {
          'fileName': S.string(description: 'Selected file name'),
          'recipientCount': S.integer(description: 'Current recipients'),
          'status': S.string(
            description: 'Status label such as Draft/Ready',
          ),
          'flowType': S.string(description: 'selfSign | oneOnOne | multiParty'),
          'canSend': S.boolean(description: 'Enable send button'),
          'signUrl': S.string(description: 'Shareable signing URL'),
        },
        required: ['fileName', 'recipientCount', 'status', 'flowType', 'canSend'],
      ),
      widgetBuilder: (args) {
        final data = args.data as Map<String, dynamic>;
        return _DraftSummaryCard(
          fileName: data['fileName'] as String,
          recipientCount: data['recipientCount'] as int,
          status: data['status'] as String,
          flowType: data['flowType'] as String,
          canSend: data['canSend'] as bool,
          signUrl: data['signUrl'] as String?,
          onSend: () => args.dispatchEvent(
            UserActionEvent(
              name: 'sendRequest',
              sourceComponentId: 'draftSummary',
              context: const {},
            ),
          ),
        );
      },
    ),
  ]);
}

// --- Surfaces ---

class _FlowSelectorSurface extends ConsumerWidget {
  final dynamic args;

  const _FlowSelectorSurface({required this.args});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 2,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Select a Workflow',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('Sign Yourself'),
            subtitle: const Text('You are the only signer'),
            leading: const Icon(Icons.person),
            onTap: () => _handleSelect(ref, 'selfSign'),
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('One-on-One'),
            subtitle: const Text('Send to one person'),
            leading: const Icon(Icons.person_outline),
            onTap: () => _handleSelect(ref, 'oneOnOne'),
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('Multi-Party'),
            subtitle: const Text('Send to multiple people'),
            leading: const Icon(Icons.people),
            onTap: () => _handleSelect(ref, 'multiParty'),
          ),
        ],
      ),
    );
  }

  void _handleSelect(WidgetRef ref, String type) {
    // Optimistically update the draft so the status bar updates instantly.
    final notifier = ref.read(activeDraftProvider.notifier);
    switch (type) {
      case 'selfSign':
        notifier.updateType(SignatureRequestType.selfSign);
        break;
      case 'multiParty':
        notifier.updateType(SignatureRequestType.multiParty);
        break;
      default:
        notifier.updateType(SignatureRequestType.oneOnOne);
        break;
    }

    args.dispatchEvent(
      UserActionEvent(
        name: 'flowSelected',
        sourceComponentId: 'flowSelector',
        context: {'type': type},
      ),
    );
  }
}

class _FileUploadSurface extends ConsumerStatefulWidget {
  final dynamic args;

  const _FileUploadSurface({required this.args});

  @override
  ConsumerState<_FileUploadSurface> createState() => _FileUploadSurfaceState();
}

class _FileUploadSurfaceState extends ConsumerState<_FileUploadSurface> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(activeDraftProvider);
    final currentFileName =
        (draft?.title != null && draft!.title != 'Untitled Document')
            ? draft.title
            : null;

    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.cloud_upload),
                const SizedBox(width: 8),
                Text(
                  currentFileName ?? 'Upload a PDF',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                if (_isLoading)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _isLoading ? null : _pickFile,
              icon: const Icon(Icons.upload_file),
              label: Text(_isLoading ? 'Uploading...' : 'Choose PDF'),
            ),
            if (currentFileName != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Selected: $currentFileName',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFile() async {
    setState(() => _isLoading = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['pdf'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.single;
        await ref.read(activeDraftProvider.notifier).updateFile(
              file.path ?? '',
              file.name,
              fileBytes: file.bytes,
            );

        widget.args.dispatchEvent(
          UserActionEvent(
            name: 'fileUploaded',
            sourceComponentId: 'fileUploader',
            context: {
              'fileName': file.name,
              'hasBytes': file.bytes != null,
            },
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

class _RecipientManagerSurface extends ConsumerStatefulWidget {
  final dynamic args;

  const _RecipientManagerSurface({required this.args});

  @override
  ConsumerState<_RecipientManagerSurface> createState() =>
      _RecipientManagerSurfaceState();
}

class _RecipientManagerSurfaceState
    extends ConsumerState<_RecipientManagerSurface> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final data = widget.args.data as Map<String, dynamic>? ?? {};
    final minRecipients = (data['minRecipients'] ?? 1) as int;
    final maxRecipients = (data['maxRecipients'] ?? 1) as int;

    final draft = ref.watch(activeDraftProvider);
    final recipients = draft?.recipients ?? [];
    final count = recipients.length;
    final isAtMax = count >= maxRecipients;
    final meetsMin = count >= minRecipients;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.people),
                const SizedBox(width: 8),
                Text(
                  'Recipients ($count / $maxRecipients)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Minimum required: $minRecipients',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Theme.of(context).colorScheme.outline),
            ),
            const SizedBox(height: 12),
            for (final r in recipients) ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.account_circle),
                title: Text(r.name),
                subtitle: Text(r.email),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _removeRecipient(r.id ?? r.email),
                ),
              ),
              const Divider(height: 1),
            ],
            const SizedBox(height: 12),
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailCtrl,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: isAtMax ? null : _addRecipient,
                  icon: const Icon(Icons.person_add),
                  label: const Text('Add recipient'),
                ),
                const SizedBox(width: 12),
                TextButton.icon(
                  onPressed: _prefillCurrentUser,
                  icon: const Icon(Icons.person),
                  label: const Text('Add myself'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: meetsMin ? _complete : null,
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _prefillCurrentUser() async {
    final user = await ref.read(currentUserProvider.future);
    if (!mounted) return;
    if (user != null) {
      _nameCtrl.text = user.name ?? '';
      _emailCtrl.text = user.email;
    }
  }

  Future<void> _addRecipient() async {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    if (name.isEmpty || email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid name and email')),
      );
      return;
    }

    await ref.read(activeDraftProvider.notifier).addRecipient(
          Recipient(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: name,
            email: email,
            role: 'signer',
          ),
        );

    widget.args.dispatchEvent(
      UserActionEvent(
        name: 'recipientAdded',
        sourceComponentId: 'recipientManager',
        context: {'name': name, 'email': email},
      ),
    );

    _nameCtrl.clear();
    _emailCtrl.clear();
  }

  Future<void> _removeRecipient(String id) async {
    final draft = ref.read(activeDraftProvider);
    if (draft == null) return;
    final updated = draft.recipients.where((r) => r.id != id).toList();
    await ref.read(activeDraftProvider.notifier).updateRecipients(updated);
    widget.args.dispatchEvent(
      UserActionEvent(
        name: 'recipientRemoved',
        sourceComponentId: 'recipientManager',
        context: {'id': id},
      ),
    );
  }

  void _complete() {
    widget.args.dispatchEvent(
      UserActionEvent(
        name: 'recipientCollectionComplete',
        sourceComponentId: 'recipientManager',
        context: const {},
      ),
    );
  }
}

class _DraftSummaryCard extends StatelessWidget {
  final String fileName;
  final int recipientCount;
  final String status;
  final String flowType;
  final bool canSend;
  final String? signUrl;
  final VoidCallback onSend;

  const _DraftSummaryCard({
    required this.fileName,
    required this.recipientCount,
    required this.status,
    required this.flowType,
    required this.canSend,
    required this.onSend,
    this.signUrl,
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
            Row(
              children: [
                const Icon(Icons.assignment),
                const SizedBox(width: 8),
                Text(
                  'Draft Summary',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                Chip(
                  label: Text(flowType),
                  backgroundColor:
                      Theme.of(context).colorScheme.secondaryContainer,
                ),
              ],
            ),
            const Divider(),
            _buildRow(Icons.description, 'File', fileName),
            const SizedBox(height: 8),
            _buildRow(Icons.people, 'Recipients', '$recipientCount'),
            const SizedBox(height: 8),
            _buildRow(Icons.info, 'Status', status),
            if (signUrl != null) ...[
              const SizedBox(height: 8),
              _buildRow(Icons.link, 'Sign URL', signUrl!),
            ],
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: canSend ? onSend : null,
              icon: const Icon(Icons.send),
              label: const Text('Send for signing'),
            ),
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
