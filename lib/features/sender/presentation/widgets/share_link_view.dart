import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/requests_provider.dart';
import '../../../../domain/models/signature_request.dart';

class RequestDetailsView extends ConsumerWidget {
  final String requestId;
  final VoidCallback onAction;
  final String actionLabel;

  const RequestDetailsView({
    super.key,
    required this.requestId,
    required this.onAction,
    this.actionLabel = 'Back to Dashboard',
  });

  void _copyToClipboard(BuildContext context, String? signUrl) {
    if (signUrl != null) {
      Clipboard.setData(ClipboardData(text: signUrl));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Link copied to clipboard!')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final requests = ref.watch(requestsProvider).value ?? [];
    final request = requests.firstWhere(
      (r) => r.id == requestId,
      orElse: () => SignatureRequest(
        id: requestId,
        title: 'Unknown',
        createdAt: DateTime.now(),
        status: RequestStatus.draft,
      ),
    );

    final url = request.signUrl ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onAction,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Success State (if just sent)
              if (request.status == RequestStatus.sent)
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle,
                          size: 48,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Request Sent!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'This document is now out for signature.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),

              // Document Info
              Text(
                'DOCUMENT',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                request.title.isNotEmpty ? request.title : "Untitled Document",
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // Share Link Section
              Text(
                'SHARE LINK',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        url.isNotEmpty ? url : "No link available",
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, size: 20),
                      onPressed: url.isNotEmpty
                          ? () => _copyToClipboard(context, url)
                          : null,
                      tooltip: 'Copy Link',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Recipients Section
              Text(
                'RECIPIENTS (${request.recipients.length})',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              ...request.recipients.map(
                (recipient) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colorScheme.outlineVariant),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.person_outline,
                            color: colorScheme.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                recipient.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                recipient.email,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Simulated Status
                        _StatusBadge(status: request.status),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton(
                  onPressed: onAction,
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(actionLabel),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final RequestStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status) {
      case RequestStatus.completed:
        color = Colors.green;
        label = "SIGNED";
        break;
      case RequestStatus.sent:
        color = Colors.blue;
        label = "PENDING";
        break;
      case RequestStatus.declined:
      case RequestStatus.voided:
        color = Colors.red;
        label = "REJECTED";
        break;
      case RequestStatus.draft:
        color = Colors.orange;
        label = "DRAFT";
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }
}
