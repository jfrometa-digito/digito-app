import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../../domain/models/signature_request.dart';
import '../providers/requests_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(requestsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Digito',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(LucideIcons.userCircle),
          ),
        ],
      ),
      body: requestsAsync.when(
        data: (requests) {
          if (requests.isEmpty) return _EmptyState();
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            separatorBuilder: (ctx, i) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              // Show newest first
              final req = requests[requests.length - 1 - index];
              return _RequestCard(
                request: req,
                onTap: () {
                  if (req.status == RequestStatus.draft) {
                    // Resume Draft
                    ref.read(activeDraftIdProvider.notifier).set(req.id);

                    // Intelligent routing based on progress
                    if (req.fields.isNotEmpty) {
                      context.pushNamed('editor');
                    } else if (req.recipients.isNotEmpty) {
                      context.pushNamed('recipients');
                    } else if (req.filePath != null) {
                      context.pushNamed(
                          'recipients'); // Or document select if we allowed re-upload
                    } else {
                      context.pushNamed('create'); // Start at document select
                    }
                  } else {
                    // View details (not implemented yet)
                  }
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Initialize new draft and wait for it to be ready
          await ref.read(activeDraftProvider.notifier).initializeNewDraft();
          // Small delay to ensure provider propagation if needed, mostly redundant if await works well
          if (context.mounted) {
            // We can check if activeDraftIdProvider is set just to be safe
            final id = ref.read(activeDraftIdProvider);
            if (id != null) {
              context.pushNamed('create');
            }
          }
        },
        label: const Text('New Request'),
        icon: const Icon(LucideIcons.plus),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.fileSignature, size: 64, color: colorScheme.outline),
          const SizedBox(height: 16),
          Text(
            'No signature requests yet',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface),
          ),
          const SizedBox(height: 8),
          Text(
            'Create a new request to get started',
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final SignatureRequest request;
  final VoidCallback onTap;

  const _RequestCard({required this.request, required this.onTap});

  Color _getStatusColor(RequestStatus status) {
    switch (status) {
      case RequestStatus.draft:
        return Colors.orange;
      case RequestStatus.sent:
        return Colors.blue;
      case RequestStatus.completed:
        return Colors.green;
      case RequestStatus.declined:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('MMM d, yyyy').format(request.createdAt);
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      // Card theme from AppTheme handles shape and elevation
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getStatusColor(request.status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              LucideIcons.fileText,
              color: _getStatusColor(request.status),
            ),
          ),
          title: Text(
            request.title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              '${request.status.name.toUpperCase()} • $dateStr',
              style:
                  TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
            ),
          ),
          trailing: Icon(LucideIcons.chevronRight,
              color: colorScheme.onSurfaceVariant),
        ),
      ),
    );
  }
}
