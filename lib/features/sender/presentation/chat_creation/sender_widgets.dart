import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/models/recipient.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../providers/requests_provider.dart';

class FileSelectorWidget extends ConsumerStatefulWidget {
  const FileSelectorWidget({super.key});

  @override
  ConsumerState<FileSelectorWidget> createState() => _FileSelectorWidgetState();
}

class _FileSelectorWidgetState extends ConsumerState<FileSelectorWidget> {
  bool _isLoading = false;
  String? _selectedFileName;

  Future<void> _pickFile() async {
    setState(() => _isLoading = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true, // Need bytes for web
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.single;
        await ref.read(activeDraftProvider.notifier).updateFile(
              file.path ?? '', // Path might be empty/fake on web
              file.name,
              fileBytes: file.bytes,
            );
        setState(() => _selectedFileName = file.name);
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // If we have a file in the draft, show it
    final draft = ref.watch(activeDraftProvider);
    final currentFileName =
        draft?.title == 'Untitled Document' ? null : draft?.title;
    final displayFileName = _selectedFileName ?? currentFileName;

    if (displayFileName != null) {
      return Card(
        color: theme.colorScheme.surfaceContainer,
        child: ListTile(
          leading: const Icon(Icons.check_circle, color: Colors.green),
          title: Text(displayFileName,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: const Text('File selected successfully'),
          trailing: TextButton(
            onPressed: _pickFile,
            child: const Text('Change'),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Document', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Upload the PDF you want to send for signature.',
                style: theme.textTheme.bodyMedium),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isLoading ? null : _pickFile,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.upload_file),
                label: Text(_isLoading ? 'Uploading...' : 'Choose PDF'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RecipientFormWidget extends ConsumerStatefulWidget {
  const RecipientFormWidget({super.key});

  @override
  ConsumerState<RecipientFormWidget> createState() =>
      _RecipientFormWidgetState();
}

class _RecipientFormWidgetState extends ConsumerState<RecipientFormWidget> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _addRecipient() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final email = _emailController.text.trim();

      final currentDraft = ref.read(activeDraftProvider);
      final currentRecipients = currentDraft?.recipients ?? [];

      final newRecipient = Recipient(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        email: email,
        role: 'signer', // Default role
      );

      ref.read(activeDraftProvider.notifier).updateRecipients(
        [...currentRecipients, newRecipient],
      );

      _nameController.clear();
      _emailController.clear();

      // Force rebuild or show success?
      // The parent chat list will show the updated status in summary if watching,
      // or we can show a local snackbar/message.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added $name ($email)')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add Recipient', style: theme.textTheme.titleMedium),
              const SizedBox(height: 16),
              // "Add Myself" Button
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () async {
                    final user = await ref.read(currentUserProvider.future);
                    if (!context.mounted) return;
                    if (user != null) {
                      _nameController.text = user.name ?? '';
                      _emailController.text = user.email;
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Could not fetch user info')),
                      );
                    }
                  },
                  icon: const Icon(Icons.person_add),
                  label: const Text('Add Myself'),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  if (!value.contains('@')) return 'Invalid email';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _addRecipient,
                  child: const Text('Add Recipient'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RequestTypeSelectorWidget extends ConsumerWidget {
  const RequestTypeSelectorWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('What would you like to do?',
                style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            _OptionTile(
              icon: Icons.edit_document,
              title: 'Sign Yourself',
              subtitle: 'Upload and sign a document yourself',
              onTap: () async {
                await ref.read(activeDraftProvider.notifier).initSignMyself();
                // Optionally trigger visual feedback or next step
              },
            ),
            const Divider(),
            _OptionTile(
              icon: Icons.person,
              title: '1-on-1 Request',
              subtitle: 'Send a document to one person for signing',
              onTap: () async {
                await ref.read(activeDraftProvider.notifier).initOneOnOne();
              },
            ),
            const Divider(),
            _OptionTile(
              icon: Icons.people,
              title: 'Multi-Party Request',
              subtitle: 'Send to multiple people for signing',
              onTap: () async {
                await ref.read(activeDraftProvider.notifier).initMultiParty();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _OptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Watch active draft to highlight selected option (if needed in future)

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: theme.colorScheme.onPrimaryContainer),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  Text(subtitle, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            Icon(Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
