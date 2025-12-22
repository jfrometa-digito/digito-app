import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../domain/models/signature_request.dart';

class ShareLinkView extends StatelessWidget {
  final SignatureRequest request;
  final VoidCallback onAction;
  final String actionLabel;

  const ShareLinkView({
    super.key,
    required this.request,
    required this.onAction,
    this.actionLabel = 'Back to Dashboard',
  });

  void _copyToClipboard(BuildContext context) {
    if (request.signUrl != null) {
      Clipboard.setData(ClipboardData(text: request.signUrl!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Link copied to clipboard!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final url = request.signUrl ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Share Link'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.checkCircle2,
                    size: 80, color: Colors.green),
              ),
              const SizedBox(height: 32),
              const Text(
                'Request Ready!',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              Text(
                'A signature request link is available for this document. You can share it to collect signatures.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 16, color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 40),
              // URL Display
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        url,
                        style: const TextStyle(fontFamily: 'monospace'),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.copy, size: 20),
                      onPressed: () => _copyToClipboard(context),
                      tooltip: 'Copy Link',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 60),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onAction,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
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
