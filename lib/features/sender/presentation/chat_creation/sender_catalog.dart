import 'package:digito_app/core/providers/auth_provider.dart';
import 'package:digito_app/domain/models/recipient.dart';
import 'package:digito_app/domain/models/signature_request.dart';
import 'package:digito_app/features/sender/providers/requests_provider.dart';
import 'package:digito_app/l10n/app_localizations.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:digito_app/features/sender/presentation/chat_creation/_dashed_border_painter.dart';

// Standalone Widgets for Guided Chat Flow

class FlowSelectorWidget extends ConsumerWidget {
  final ValueChanged<SignatureRequestType> onFlowSelected;

  const FlowSelectorWidget({super.key, required this.onFlowSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildOptionCard(
          context,
          icon: Icons.edit_document,
          title: AppLocalizations.of(context)!.cardSelfSignTitle,
          subtitle: AppLocalizations.of(context)!.cardSelfSignSubtitle,
          onTap: () => _handleSelect(ref, SignatureRequestType.selfSign),
        ),
        const SizedBox(height: 12),
        _buildOptionCard(
          context,
          icon: Icons.people_alt,
          title: AppLocalizations.of(context)!.cardOneOnOneTitle,
          subtitle: AppLocalizations.of(context)!.cardOneOnOneSubtitle,
          onTap: () => _handleSelect(ref, SignatureRequestType.oneOnOne),
        ),
        const SizedBox(height: 12),
        _buildOptionCard(
          context,
          icon: Icons.groups,
          title: AppLocalizations.of(context)!.cardMultiPartyTitle,
          subtitle: AppLocalizations.of(context)!.cardMultiPartySubtitle,
          onTap: () => _handleSelect(ref, SignatureRequestType.multiParty),
        ),
      ],
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      color: theme.colorScheme.surface,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: theme.colorScheme.onPrimaryContainer),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
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
    final theme = Theme.of(context);
    final draft = ref.watch(activeDraftProvider);
    final currentFileName =
        (draft?.title != null && draft!.title != 'Untitled Document')
        ? draft.title
        : null;

    final hasFile =
        (draft?.filePath?.isNotEmpty ?? false) || draft?.fileBytes != null;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      color: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppLocalizations.of(context)!.uploadDocumentTitle,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _isLoading ? null : _pickFile,
              child: Container(
                height: 160,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.transparent, // Handled by CustomPaint
                    style: BorderStyle.none,
                  ),
                ),
                child: CustomPaint(
                  painter: DashedBorderPainter(
                    color: theme.colorScheme.outlineVariant,
                    strokeWidth: 2,
                    gap: 5,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.cloud_upload_outlined,
                            size: 32,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          AppLocalizations.of(context)!.uploadBrowse,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppLocalizations.of(context)!.uploadDrag,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (currentFileName != null && hasFile) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.colorScheme.secondary),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: theme.colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        currentFileName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 48,
                child: FilledButton(
                  onPressed: widget.onFileUploaded,
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.btnNextStep,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward),
                    ],
                  ),
                ),
              ),
            ] else ...[
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSourceOption(
                    context,
                    Icons.folder_open,
                    AppLocalizations.of(context)!.sourceFiles,
                  ),
                  _buildSourceOption(
                    context,
                    Icons.document_scanner_outlined,
                    AppLocalizations.of(context)!.sourceScan,
                  ),
                  _buildSourceOption(
                    context,
                    Icons.add_to_drive,
                    AppLocalizations.of(context)!.sourceDrive,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSourceOption(BuildContext context, IconData icon, String label) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            icon,
            color: theme
                .colorScheme
                .primary, // Or keep orange if it's a specific brand color, but theme is safer
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
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
    final theme = Theme.of(context);
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
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      color: theme.colorScheme.surface,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.recipientsTitle,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "$count ${AppLocalizations.of(context)!.recipientsAdded}",
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (recipients.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  AppLocalizations.of(context)!.recipientsEmpty,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            for (final r in recipients) ...[
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                  borderRadius: BorderRadius.circular(16),
                ),
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primary,
                    child: Text(
                      r.name.isNotEmpty ? r.name[0].toUpperCase() : '?',
                      style: TextStyle(color: theme.colorScheme.onPrimary),
                    ),
                  ),
                  title: Text(
                    r.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(r.email),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: theme.colorScheme.error,
                    ),
                    onPressed: () => _removeRecipient(r.id ?? r.email),
                  ),
                ),
              ),
            ],
            if (!isAtMax) ...[
              const SizedBox(height: 24),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.person_add_alt_1,
                      color: theme.colorScheme.onPrimaryContainer,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    AppLocalizations.of(context)!.recipientsAddNew,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.labelFullName,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  hintText: 'Jane Doe',
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHigh,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: Icon(
                    Icons.badge_outlined,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.labelEmail,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _emailCtrl,
                decoration: InputDecoration(
                  hintText: 'jane@company.com',
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHigh,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: _addRecipient,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: theme.colorScheme.outline),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.add),
                  label: Text(AppLocalizations.of(context)!.btnAddToList),
                ),
              ),
              // Quick add myself link
              Center(
                child: TextButton(
                  onPressed: _prefillCurrentUser,
                  child: Text(AppLocalizations.of(context)!.btnAddMyself),
                ),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                onPressed: meetsMin ? widget.onComplete : null,
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor: theme.colorScheme.onSurface
                      .withValues(alpha: 0.12),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward),
                  ],
                ),
              ),
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
        SnackBar(
          content: Text(AppLocalizations.of(context)!.errorInvalidRecipient),
        ),
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
  final bool hasFields;
  final String? signUrl;
  final VoidCallback onSend;
  final VoidCallback onEditFields;

  const DraftSummaryWidget({
    super.key,
    required this.fileName,
    required this.recipientCount,
    required this.status,
    required this.flowType,
    required this.canSend,
    required this.hasFields,
    required this.onSend,
    required this.onEditFields,
    this.signUrl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      color: theme.colorScheme.surface,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.assignment, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.summaryTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Chip(
                  label: Text(
                    flowType,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                  ),
                  backgroundColor: theme.colorScheme.secondaryContainer,
                  side: BorderSide.none,
                ),
              ],
            ),
            Divider(color: theme.colorScheme.outlineVariant),
            const SizedBox(height: 16),
            _buildRow(
              context,
              Icons.description,
              AppLocalizations.of(context)!.summaryFile,
              fileName,
            ),
            const SizedBox(height: 12),
            _buildRow(
              context,
              Icons.people,
              AppLocalizations.of(context)!.summaryRecipients,
              '$recipientCount',
            ),
            const SizedBox(height: 12),
            _buildRow(
              context,
              Icons.info_outline,
              AppLocalizations.of(context)!.summaryStatus,
              status,
            ),
            if (signUrl != null) ...[
              const SizedBox(height: 12),
              _buildRow(
                context,
                Icons.link,
                AppLocalizations.of(context)!.summarySignUrl,
                signUrl!,
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: onEditFields,
                icon: Icon(hasFields ? Icons.edit : Icons.add),
                label: Text(
                  hasFields
                      ? AppLocalizations.of(context)!.btnEditFields
                      : AppLocalizations.of(context)!.btnAddFields,
                ),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed: canSend ? onSend : null,
                icon: const Icon(Icons.send),
                label: Text(AppLocalizations.of(context)!.btnSendForSigning),
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor: theme.colorScheme.onSurface
                      .withValues(alpha: 0.12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            SelectableText(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
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
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      color: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors
                        .red
                        .shade50, // Keep generic PDF red or use errorContainer
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.picture_as_pdf,
                    color: Colors.redAccent,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Signed Document.pdf",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.circle,
                            size: 8,
                            color:
                                theme.colorScheme.primary, // Or success color
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "ACTIVE",
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "•  Link generated",
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              "SIGNING LINK",
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      signUrl,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed:
                        onOpenLink, // Reusing open link as Copy for now or implementing copy logic
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.link),
                    label: const Text("Copy Link"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {}, // Mock email
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(color: theme.colorScheme.outline),
                    ),
                    icon: const Icon(Icons.email_outlined),
                    label: const Text("Email"),
                  ),
                ),
              ],
            ),
            if (onReset != null) ...[
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: onReset,
                  child: Text(
                    "Done",
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
