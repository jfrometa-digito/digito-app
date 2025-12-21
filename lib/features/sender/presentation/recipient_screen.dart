import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../domain/models/signature_request.dart';
import '../../../../domain/models/recipient.dart';
import '../../../../core/providers/auth_provider.dart';
import '../providers/requests_provider.dart';

class RecipientScreen extends ConsumerStatefulWidget {
  const RecipientScreen({super.key});

  @override
  ConsumerState<RecipientScreen> createState() => _RecipientScreenState();
}

class _RecipientScreenState extends ConsumerState<RecipientScreen> {
  // We'll use a local controller list to manage text fields, but sync to provider on changes
  final List<TextEditingController> _nameControllers = [];
  final List<TextEditingController> _emailControllers = [];

  @override
  void initState() {
    super.initState();
    // Initialize controllers from draft if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final recipients = ref.read(activeDraftProvider)?.recipients ?? [];
      if (recipients.isEmpty) {
        _addRecipientRow();
      } else {
        for (final r in recipients) {
          _addRecipientRow(r);
        }
      }
    });
  }

  @override
  void dispose() {
    for (var c in _nameControllers) {
      c.dispose();
    }
    for (var c in _emailControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addRecipientRow([Recipient? recipient]) {
    final nameCtrl = TextEditingController(text: recipient?.name ?? '');
    final emailCtrl = TextEditingController(text: recipient?.email ?? '');

    // Listeners to auto-save to draft
    nameCtrl.addListener(_syncToDraft);
    emailCtrl.addListener(_syncToDraft);

    setState(() {
      _nameControllers.add(nameCtrl);
      _emailControllers.add(emailCtrl);
    });

    // Initial sync if we added a new empty row isn't strictly necessary until they type,
    // but ensures the list size matches.
    if (recipient == null) {
      _syncToDraft();
    }
  }

  void _removeRefcipientRow(int index) {
    if (_nameControllers.length <= 1) return;

    setState(() {
      _nameControllers[index].dispose();
      _emailControllers[index].dispose();
      _nameControllers.removeAt(index);
      _emailControllers.removeAt(index);
    });
    _syncToDraft();
  }

  void _addMeAsRecipient() {
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user != null) {
      _addRecipientRow(Recipient(
        id: 'me',
        name: user.name ?? '',
        email: user.email,
        role: 'signer',
      ));
    }
  }

  void _syncToDraft() {
    final recipients = <Recipient>[];
    for (int i = 0; i < _nameControllers.length; i++) {
      recipients.add(Recipient(
        name: _nameControllers[i].text,
        email: _emailControllers[i].text,
        id: 'recipient-$i', // Simple ID generation
      ));
    }
    ref.read(activeDraftProvider.notifier).updateRecipients(recipients);
  }

  void _onNext() {
    final activeDraft = ref.read(activeDraftProvider);
    if (activeDraft == null) return;

    // Validate
    bool isValid = true;
    for (int i = 0; i < _nameControllers.length; i++) {
      if (_nameControllers[i].text.trim().isEmpty ||
          _emailControllers[i].text.trim().isEmpty) {
        isValid = false;
        break;
      }
    }

    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all recipient fields')),
      );
      return;
    }

    // Flow-specific validation
    if (activeDraft.type == SignatureRequestType.oneOnOne &&
        _nameControllers.length != 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('1-on-1 requires exactly 2 signers.')),
      );
      return;
    }

    context.pushNamed('editor');
  }

  @override
  Widget build(BuildContext context) {
    final activeDraft = ref.watch(activeDraftProvider);
    if (activeDraft == null) return const SizedBox();

    final title = _getFlowTitle(activeDraft.type);
    final isSelfSign = activeDraft.type == SignatureRequestType.selfSign;
    final isOneOnOne = activeDraft.type == SignatureRequestType.oneOnOne;
    final canAddMore =
        !isSelfSign && (!isOneOnOne || _nameControllers.length < 2);
    final hasMe = _nameControllers.any((c) =>
        c.text == (ref.read(currentUserProvider).valueOrNull?.name ?? ''));

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: _nameControllers.length,
              separatorBuilder: (ctx, i) => const SizedBox(height: 24),
              itemBuilder: (context, index) {
                return _buildRecipientRow(index, activeDraft.type);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!hasMe && activeDraft.type != SignatureRequestType.selfSign)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: OutlinedButton.icon(
                      onPressed: _addMeAsRecipient,
                      icon: const Icon(LucideIcons.userPlus),
                      label: const Text('Include myself as signer'),
                    ),
                  ),
                if (canAddMore)
                  OutlinedButton.icon(
                    onPressed: () => _addRecipientRow(),
                    icon: const Icon(LucideIcons.plus),
                    label: const Text('Add Another Recipient'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _onNext,
                  child: const Text('Next: Place Fields'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getFlowTitle(SignatureRequestType type) {
    switch (type) {
      case SignatureRequestType.selfSign:
        return 'Sign Myself';
      case SignatureRequestType.oneOnOne:
        return '1-on-1 Signature';
      case SignatureRequestType.multiParty:
        return 'Add Recipients';
    }
  }

  Widget _buildRecipientRow(int index, SignatureRequestType type) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelfSign = type == SignatureRequestType.selfSign;
    final canDelete = !isSelfSign && _nameControllers.length > 1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isSelfSign ? 'Your Information' : 'Recipient ${index + 1}',
                style: TextStyle(
                    fontWeight: FontWeight.w600, color: colorScheme.onSurface),
              ),
              if (canDelete)
                IconButton(
                  icon: Icon(LucideIcons.trash2,
                      size: 20, color: colorScheme.error),
                  onPressed: () => _removeRefcipientRow(index),
                ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameControllers[index],
            decoration: const InputDecoration(
              labelText: 'Full Name',
              prefixIcon: Icon(LucideIcons.user),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _emailControllers[index],
            decoration: const InputDecoration(
              labelText: 'Email Address',
              prefixIcon: Icon(LucideIcons.mail),
            ),
          ),
        ],
      ),
    );
  }
}
