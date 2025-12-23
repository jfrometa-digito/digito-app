import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

/// Define the Catalog for the document signing flow.
final signingCatalog = Catalog([
  CatalogItem(
    name: 'signingRequest',
    dataSchema: S.object(
      properties: {
        'docTitle': S.string(description: 'Title of the document'),
        'recipients': S.string(description: 'List of recipients as a string'),
        'status': S.string(
          description: 'Current status of the request',
          enumValues: ['Pending', 'Completed', 'Draft'],
        ),
      },
      required: ['docTitle', 'recipients', 'status'],
    ),
    widgetBuilder: (args) {
      final req = args.data as Map<String, dynamic>;
      return SigningRequestCard(
        title: req['docTitle'] as String,
        recipientsText: req['recipients'] as String,
        status: req['status'] as String,
      );
    },
  ),
  CatalogItem(
    name: 'documentPreview',
    dataSchema: S.object(
      properties: {
        'docTitle': S.string(description: 'Title of the document to preview'),
        'previewText':
            S.string(description: 'A snippet of the document content'),
      },
      required: ['docTitle', 'previewText'],
    ),
    widgetBuilder: (args) {
      final data = args.data as Map<String, dynamic>;
      return DocumentPreview(
        title: data['docTitle'] as String,
        previewText: data['previewText'] as String,
      );
    },
  ),
  CatalogItem(
    name: 'signaturePad',
    dataSchema: S.object(
      properties: {
        'prompt': S.string(description: 'Instruction for the signer'),
      },
      required: ['prompt'],
    ),
    widgetBuilder: (args) {
      final data = args.data as Map<String, dynamic>;
      return SignaturePadCard(
        prompt: data['prompt'] as String,
        onSigned: (signature) {
          args.dispatchEvent(UserActionEvent(
            name: 'signatureCaptured',
            sourceComponentId: '',
            // data: {'signature': signature},
          ));
        },
      );
    },
  ),
]);

class SigningRequestCard extends StatelessWidget {
  final String title;
  final String recipientsText;
  final String status;

  const SigningRequestCard({
    super.key,
    required this.title,
    required this.recipientsText,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.description, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _StatusBadge(status: status),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'To: $recipientsText',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DocumentPreview extends StatelessWidget {
  final String title;
  final String previewText;

  const DocumentPreview({
    super.key,
    required this.title,
    required this.previewText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preview: $title',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            previewText,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontStyle: FontStyle.italic,
            ),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class SignaturePadCard extends StatelessWidget {
  final String prompt;
  final Function(String) onSigned;

  const SignaturePadCard({
    super.key,
    required this.prompt,
    required this.onSigned,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              prompt,
              style: theme.textTheme.titleSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.colorScheme.outline),
              ),
              child: InkWell(
                onTap: () => _showSignaturePad(context),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.edit, color: Colors.grey),
                      Text('Tap to sign', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSignaturePad(BuildContext context) {
    onSigned('MOCKED_SIGNATURE_DATA');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Signature captured!')),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = status == 'Completed'
        ? Colors.green
        : status == 'Pending'
            ? Colors.orange
            : Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
