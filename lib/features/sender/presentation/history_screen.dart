import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/requests_provider.dart';
import '../../../domain/models/signature_request.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(requestsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('History'),
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft),
          onPressed: () => context.pop(),
        ),
      ),
      body: requestsAsync.when(
        data: (requests) {
          if (requests.isEmpty) {
            return const Center(child: Text('No requests found'));
          }

          // Sort by date (newest first)
          final sortedRequests = List<SignatureRequest>.from(requests)
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

          // Group by month
          final Map<String, List<SignatureRequest>> groupedRequests = {};
          final monthFormat = DateFormat('MMMM yyyy');

          for (final req in sortedRequests) {
            final monthKey = monthFormat.format(req.createdAt);
            if (!groupedRequests.containsKey(monthKey)) {
              groupedRequests[monthKey] = [];
            }
            groupedRequests[monthKey]!.add(req);
          }

          final months = groupedRequests.keys.toList();

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: months.length,
            itemBuilder: (context, index) {
              final month = months[index];
              final items = groupedRequests[month]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 24, bottom: 16, left: 4),
                    child: Text(
                      month.toUpperCase(),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.primary,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  ...items.map((req) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _HistoryItemCard(request: req),
                      )),
                ],
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

class _HistoryItemCard extends ConsumerWidget {
  final SignatureRequest request;

  const _HistoryItemCard({required this.request});

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
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final dateStr = DateFormat('MMM d').format(request.createdAt);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: InkWell(
        onTap: () => _handleTap(context, ref),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _getStatusColor(request.status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  LucideIcons.fileText,
                  color: _getStatusColor(request.status),
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${request.type.name.toUpperCase()} • $dateStr',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(request.status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  request.status.name.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: _getStatusColor(request.status),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleTap(BuildContext context, WidgetRef ref) {
    if (request.status == RequestStatus.draft) {
      ref.read(activeDraftProvider.notifier).loadExisting(request.id);
      if (request.fields.isNotEmpty) {
        context.pushNamed('editor');
      } else if (request.recipients.isNotEmpty) {
        context.pushNamed('recipients');
      } else {
        context.pushNamed('create');
      }
    } else if (request.status == RequestStatus.sent) {
      context.pushNamed('share', pathParameters: {'requestId': request.id});
    }
  }
}
