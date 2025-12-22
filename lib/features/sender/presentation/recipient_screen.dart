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
  final List<TextEditingController> _nameControllers = [];
  final List<TextEditingController> _emailControllers = [];
  final List<String> _recipientIds = []; // Track IDs to avoid regeneration
  bool _includeMyself = false;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() => _isInitializing = true);
    // Guard against re-initialization
    if (_nameControllers.isNotEmpty) {
      setState(() => _isInitializing = false);
      return;
    }

    final draft = ref.read(activeDraftProvider);
    final recipients = draft?.recipients ?? [];

    // Await user data to ensure pre-population works even with async mock service
    final user = await ref.read(currentUserProvider.future);

    if (!mounted) return;

    setState(() {
      // Check if user is already in the list or if it's a self-sign flow
      if (user != null &&
          recipients.any((r) => r.email == user.email && r.name == user.name)) {
        _includeMyself = true;
      } else if (draft?.type == SignatureRequestType.selfSign) {
        _includeMyself = true;
      }

      if (recipients.isEmpty) {
        if (draft?.type == SignatureRequestType.selfSign && user != null) {
          _addRecipientRow(
            recipient: Recipient(
              id: 'me',
              name: user.name ?? '',
              email: user.email,
              role: 'signer',
            ),
            skipSync: true,
          );
        } else if (draft?.type == SignatureRequestType.oneOnOne ||
            draft?.type == SignatureRequestType.multiParty) {
          // Initialize with 2 recipients for 1-on-1 and Multi-party
          _addRecipientRow(skipSync: true);
          _addRecipientRow(skipSync: true);
        } else {
          _addRecipientRow(skipSync: true);
        }
      } else {
        for (final r in recipients) {
          _addRecipientRow(recipient: r, skipSync: true);
        }
        // Ensure 1-on-1 and multiParty always have at least 2 even if draft was saved with 1
        if ((draft?.type == SignatureRequestType.oneOnOne ||
                draft?.type == SignatureRequestType.multiParty) &&
            recipients.length < 2) {
          for (int i = recipients.length; i < 2; i++) {
            _addRecipientRow(skipSync: true);
          }
        }
      }
    });

    // Sync final state once
    _syncToDraft();
    setState(() => _isInitializing = false);
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

  void _addRecipientRow({Recipient? recipient, bool skipSync = false}) {
    final nameCtrl = TextEditingController(text: recipient?.name ?? '');
    final emailCtrl = TextEditingController(text: recipient?.email ?? '');

    // Listeners to auto-save to draft
    nameCtrl.addListener(_syncToDraft);
    emailCtrl.addListener(_syncToDraft);

    setState(() {
      _nameControllers.add(nameCtrl);
      _emailControllers.add(emailCtrl);
      _recipientIds.add(recipient?.id ?? 'recipient-${_recipientIds.length}');
    });

    // Initial sync if requested
    if (!skipSync && recipient == null) {
      _syncToDraft();
    }
  }

  void _removeRefcipientRow(int index) {
    final draft = ref.read(activeDraftProvider);
    // Determine minimum based on flow type: 1 for selfSign, 2 for oneOnOne and multiParty
    int minRecipients = 1;
    if (draft?.type == SignatureRequestType.oneOnOne ||
        draft?.type == SignatureRequestType.multiParty) {
      minRecipients = 2;
    }

    if (_nameControllers.length <= minRecipients) return;

    setState(() {
      _nameControllers[index].dispose();
      _emailControllers[index].dispose();
      _nameControllers.removeAt(index);
      _emailControllers.removeAt(index);
      _recipientIds.removeAt(index);

      // If we remove the 'me' row, uncheck the box
      if (index == 0 && _includeMyself) {
        _includeMyself = false;
      }
    });
    _syncToDraft();
  }

  void _onIncludeMyselfToggled(bool? value) {
    if (value == null) return;

    final user = ref.read(currentUserProvider).valueOrNull;

    setState(() {
      _includeMyself = value;
      if (_includeMyself && user != null) {
        // Populate first recipient with user data
        if (_nameControllers.isNotEmpty) {
          _nameControllers[0].text = user.name ?? '';
          _emailControllers[0].text = user.email;
        } else {
          _addRecipientRow(
            recipient: Recipient(
              id: 'me',
              name: user.name ?? '',
              email: user.email,
              role: 'signer',
            ),
          );
        }
      } else if (!_includeMyself && user != null) {
        // Clear first recipient if it matches user data
        if (_nameControllers.isNotEmpty &&
            _nameControllers[0].text == (user.name ?? '') &&
            _emailControllers[0].text == user.email) {
          _nameControllers[0].text = '';
          _emailControllers[0].text = '';
        }
      }
    });

    if (user == null && value) {
      // If user is null but they tried to check it, show a message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('User profile not loaded. Please try again.')),
      );
      setState(() => _includeMyself = false);
    }

    _syncToDraft();
  }

  void _syncToDraft() {
    final recipients = <Recipient>[];
    for (int i = 0; i < _nameControllers.length; i++) {
      recipients.add(Recipient(
        name: _nameControllers[i].text,
        email: _emailControllers[i].text,
        id: _recipientIds[i],
      ));
    }
    ref.read(activeDraftProvider.notifier).updateRecipients(recipients);
  }

  void _onNext() {
    final activeDraft = ref.read(activeDraftProvider);
    if (activeDraft == null) return;

    // Validate email/name presence
    bool isFilled = true;
    for (int i = 0; i < _nameControllers.length; i++) {
      if (_nameControllers[i].text.trim().isEmpty ||
          _emailControllers[i].text.trim().isEmpty) {
        isFilled = false;
        break;
      }
    }

    if (!isFilled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all recipient fields')),
      );
      return;
    }

    // Flow-specific validation
    final type = activeDraft.type;
    final count = _nameControllers.length;

    if (type == SignatureRequestType.selfSign && count != 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Self signing must have exactly 1 signer.')),
      );
      return;
    }

    if (type == SignatureRequestType.oneOnOne && count != 2) {
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
    final userAsync = ref.watch(currentUserProvider);
    if (activeDraft == null) return const SizedBox();

    final colorScheme = Theme.of(context).colorScheme;
    final title = _getFlowTitle(activeDraft.type);
    final isSelfSign = activeDraft.type == SignatureRequestType.selfSign;
    final isOneOnOne = activeDraft.type == SignatureRequestType.oneOnOne;
    final canAddMore = !isSelfSign && !isOneOnOne;

    print(
        'DEBUG Build: Type=${activeDraft.type}, isSelfSign=$isSelfSign, isOneOnOne=$isOneOnOne, canAddMore=$canAddMore, recipientCount=${_nameControllers.length}');

    if (_isInitializing) {
      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Ensure _includeMyself stays in sync if user loads or changes
    final user = userAsync.valueOrNull;

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
          // Flow Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Flow',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurfaceVariant,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: colorScheme.primary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: CheckboxListTile(
                    value: _includeMyself,
                    onChanged: user == null ? null : _onIncludeMyselfToggled,
                    title: const Text('I am one of the signers'),
                    subtitle: Text(
                      user == null
                          ? 'Loading profile...'
                          : 'Auto-fill my account details',
                      style: TextStyle(
                          fontSize: 12, color: colorScheme.onSurfaceVariant),
                    ),
                    secondary: Icon(LucideIcons.userCheck,
                        color: user == null
                            ? colorScheme.outline
                            : colorScheme.primary),
                    controlAffinity: ListTileControlAffinity.trailing,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
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
    final isOneOnOne = type == SignatureRequestType.oneOnOne;
    final isMultiParty = type == SignatureRequestType.multiParty;

    // Determine if this row can be deleted based on flow type and current count
    bool canDelete = false;
    if (isSelfSign) {
      canDelete = false; // Never allow delete for selfSign (must have 1)
    } else if (isOneOnOne) {
      canDelete = false; // Never allow delete for 1-on-1 (must have exactly 2)
    } else if (isMultiParty) {
      canDelete =
          _nameControllers.length > 2; // Allow delete only if more than 2
    }

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
