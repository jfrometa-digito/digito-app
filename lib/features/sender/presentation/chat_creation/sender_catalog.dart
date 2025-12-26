import 'package:digito_app/core/providers/auth_provider.dart';
import 'package:digito_app/domain/models/recipient.dart';
import 'package:digito_app/domain/models/signature_request.dart';
import 'package:digito_app/features/sender/providers/requests_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Standalone Widgets for Guided Chat Flow

class FlowSelectorWidget extends ConsumerWidget {
  final ValueChanged<SignatureRequestType> onFlowSelected;

  const FlowSelectorWidget({super.key, required this.onFlowSelected});

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
            onTap: () => _handleSelect(ref, SignatureRequestType.selfSign),
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('One-on-One'),
            subtitle: const Text('Send to one person'),
            leading: const Icon(Icons.person_outline),
            onTap: () => _handleSelect(ref, SignatureRequestType.oneOnOne),
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('Multi-Party'),
            subtitle: const Text('Send to multiple people'),
            leading: const Icon(Icons.people),
            onTap: () => _handleSelect(ref, SignatureRequestType.multiParty),
          ),
        ],
      ),
    );
  }

  void _handleSelect(WidgetRef ref, SignatureRequestType type) {
    ref.read(activeDraftProvider.notifier).updateType(type);
    onFlowSelected(type);
  }
}

class FileUploaderWidget extends ConsumerStatefulWidget {
  final VoidCallback onFileUploaded;

  const FileUploaderWidget({super.key, required this.onFileUploaded});

  @override
  ConsumerState<FileUploaderWidget> createState() => _FileUploaderWidgetState();
}

class _FileUploaderWidgetState extends ConsumerState<FileUploaderWidget> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(activeDraftProvider);
    final currentFileName =
        (draft?.title != null && draft!.title != 'Untitled Document')
        ? draft.title
        : null;

    final hasFile =
        (draft?.filePath?.isNotEmpty ?? false) || draft?.fileBytes != null;

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
            if (currentFileName != null && hasFile) ...[
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Selected: $currentFileName',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              const SizedBox(height: 8),
              FilledButton.tonal(
                onPressed: widget.onFileUploaded,
                child: const Text('Done'),
              ),
            ],
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
        await ref
            .read(activeDraftProvider.notifier)
            .updateFile(file.path ?? '', file.name, fileBytes: file.bytes);
        // Note: We don't call onFileUploaded here immediately,
        // effectively letting the user see the file is selected and click "Done"
        // OR we can auto-advance. Let's auto-advance for smoother flow?
        // Actually, let's keep the "Done" button or just auto-advance.
        // The user experience "Upload -> auto next" is usually better.
        // Let's call it here.
        widget.onFileUploaded();
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

class RecipientManagerWidget extends ConsumerStatefulWidget {
  final VoidCallback onComplete;

  const RecipientManagerWidget({super.key, required this.onComplete});

  @override
  ConsumerState<RecipientManagerWidget> createState() =>
      _RecipientManagerWidgetState();
}

class _RecipientManagerWidgetState
    extends ConsumerState<RecipientManagerWidget> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  Map<String, int> _getConstraints(SignatureRequestType type) {
    switch (type) {
      case SignatureRequestType.selfSign:
        return {'min': 1, 'max': 1};
      case SignatureRequestType.oneOnOne:
        return {'min': 2, 'max': 2};
      case SignatureRequestType.multiParty:
        return {'min': 3, 'max': 10};
    }
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(activeDraftProvider);
    if (draft == null) return const SizedBox.shrink();

    final constraints = _getConstraints(draft.type);
    final minRecipients = constraints['min']!;
    final maxRecipients = constraints['max']!;

    final recipients = draft.recipients;
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
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
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
            if (!isAtMax) ...[
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
                    onPressed: _addRecipient,
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
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: meetsMin ? widget.onComplete : null,
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

    await ref
        .read(activeDraftProvider.notifier)
        .addRecipient(
          Recipient(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: name,
            email: email,
            role: 'signer',
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
  }
}

class DraftSummaryWidget extends StatelessWidget {
  final String fileName;
  final int recipientCount;
  final String status;
  final String flowType;
  final bool canSend;
  final String? signUrl;
  final VoidCallback onSend;

  const DraftSummaryWidget({
    super.key,
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
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.secondaryContainer,
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
        Expanded(child: SelectableText(value)),
      ],
    );
  }
}

class SigningLinkWidget extends StatelessWidget {
  final String signUrl;
  final VoidCallback onOpenLink;
  final VoidCallback? onReset;

  const SigningLinkWidget({
    super.key,
    required this.signUrl,
    required this.onOpenLink,
    this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Ready to Sign!',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text('You can start the signing process now.'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(4),
              ),
              child: SelectableText(
                signUrl,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onOpenLink,
                icon: const Icon(Icons.open_in_new),
                label: const Text('Open Signing Page'),
              ),
            ),
            if (onReset != null) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: onReset,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Close & Start New'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
