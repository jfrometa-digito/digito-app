import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../domain/models/signature_request.dart';
import '../providers/requests_provider.dart';
import 'widgets/share_link_view.dart';

class ReviewScreen extends ConsumerStatefulWidget {
  const ReviewScreen({super.key});

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  bool _isSent = false;
  SignatureRequest? _sentRequest;

  Future<void> _onSend() async {
    // Simulate API call
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    await Future.delayed(const Duration(seconds: 2));

    // Mark as sent in repository
    await ref.read(activeDraftProvider.notifier).markAsSent();

    final sentDraft = ref.read(activeDraftProvider);

    if (mounted) {
      Navigator.pop(context); // Pop loading dialog
      setState(() {
        _isSent = true;
        _sentRequest = sentDraft;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeDraft = ref.watch(activeDraftProvider);
    // If no draft (shouldn't happen unless deep linked incorrectly or weird state), handle gracefully
    if (activeDraft == null && !_isSent) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_isSent && _sentRequest != null) {
      return RequestDetailsView(
        request: _sentRequest!,
        actionLabel: 'Done',
        onAction: () {
          ref.read(activeDraftProvider.notifier).clear();
          context.go('/');
        },
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Review Request')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SummaryCard(
              title: 'Document',
              icon: Icons.description,
              content: activeDraft!.title,
              subContent: activeDraft.filePath, // Or show size if we had it
            ),
            const SizedBox(height: 16),
            _SummaryCard(
              title: 'Recipients',
              icon: Icons.people,
              content: '${activeDraft.recipients.length} Signers',
              subContent: activeDraft.recipients
                  .map((r) => '${r.name} (${r.email})')
                  .join(', '),
            ),
            const SizedBox(height: 16),
            const _SummaryCard(
              title: 'Message',
              icon: Icons.message,
              content:
                  'Please sign this document.', // We could add a message field to the model later
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                    child: const Text('Back'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _onSend,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                    icon: const Icon(Icons.send),
                    label: const Text('Send Request'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String content;
  final String? subContent;

  const _SummaryCard({
    required this.title,
    required this.icon,
    required this.content,
    this.subContent,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                // Handle long text
                Text(
                  content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: colorScheme.onSurface,
                  ),
                ),
                if (subContent != null)
                  Text(
                    subContent!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
