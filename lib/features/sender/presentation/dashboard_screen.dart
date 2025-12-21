import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../../domain/models/signature_request.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/theme_provider.dart';
import '../providers/requests_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(requestsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Digito',
          style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.5),
        ),
        actions: [
          _buildProfileMenu(context, ref),
        ],
      ),
      body: requestsAsync.when(
        data: (requests) {
          return CustomScrollView(
            slivers: [
              // Hero / Quick Actions
              SliverToBoxAdapter(
                child: _QuickActionsSection(),
              ),

              // Recent Activity Header
              if (requests.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      children: [
                        Text(
                          'Recent Activity',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {},
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                  ),
                ),

              // Requests List
              if (requests.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyState(),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        // Show newest first
                        final req = requests[requests.length - 1 - index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _RequestCard(
                            request: req,
                            onTap: () => _resumeDraft(context, ref, req),
                          ),
                        );
                      },
                      childCount: requests.length,
                    ),
                  ),
                ),

              // Bottom spacing
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  void _resumeDraft(BuildContext context, WidgetRef ref, SignatureRequest req) {
    if (req.status == RequestStatus.draft) {
      ref.read(activeDraftProvider.notifier).loadExisting(req.id);
      if (req.fields.isNotEmpty) {
        context.pushNamed('editor');
      } else if (req.recipients.isNotEmpty) {
        context.pushNamed('recipients');
      } else {
        context.pushNamed('create');
      }
    } else if (req.status == RequestStatus.sent) {
      context.pushNamed('share', pathParameters: {'requestId': req.id});
    } else {
      // Future: View completed/declined details
    }
  }

  Widget _buildProfileMenu(BuildContext context, WidgetRef ref) {
    final isAuthAsync = ref.watch(isAuthenticatedProvider);

    return isAuthAsync.when(
      data: (isAuth) {
        if (isAuth) {
          return PopupMenuButton<String>(
            icon: const Icon(LucideIcons.userCircle),
            itemBuilder: (context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(LucideIcons.user, size: 20),
                    SizedBox(width: 12),
                    Text('Profile'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'theme',
                child: _ThemeMenuItem(),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(LucideIcons.logOut, size: 20),
                    SizedBox(width: 12),
                    Text('Log Out'),
                  ],
                ),
              ),
            ],
            onSelected: (value) async {
              if (value == 'profile') {
                context.pushNamed('profile');
              } else if (value == 'theme') {
                ref.read(appThemeModeProvider.notifier).toggle();
              } else if (value == 'logout') {
                final authService = ref.read(authServiceProvider);
                await authService.logout();
                ref.invalidate(currentUserProvider);
                ref.invalidate(isAuthenticatedProvider);
              }
            },
          );
        }
        return Row(
          children: [
            IconButton(
              onPressed: () => ref.read(appThemeModeProvider.notifier).toggle(),
              icon: Icon(
                Theme.of(context).brightness == Brightness.light
                    ? LucideIcons.moon
                    : LucideIcons.sun,
              ),
            ),
            IconButton(
              onPressed: () => context.pushNamed('login'),
              icon: const Icon(LucideIcons.userCircle),
            ),
          ],
        );
      },
      loading: () => const SizedBox(
          width: 48,
          child: Center(
              child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2)))),
      error: (_, __) => IconButton(
        onPressed: () => context.pushNamed('login'),
        icon: const Icon(LucideIcons.userCircle),
      ),
    );
  }
}

class _QuickActionsSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light
            ? colorScheme.primaryContainer.withOpacity(0.4)
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What would you like to do?',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _QuickActionCard(
                  title: 'Sign Myself',
                  subtitle: 'Quick solo signature',
                  icon: LucideIcons.penTool,
                  color: colorScheme.primary,
                  onTap: () async {
                    await ref
                        .read(activeDraftProvider.notifier)
                        .initSignMyself();
                    if (context.mounted) context.pushNamed('create');
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickActionCard(
                  title: '1-on-1 Sign',
                  subtitle: 'You and another',
                  icon: LucideIcons.users,
                  color: Colors.indigo,
                  onTap: () async {
                    await ref.read(activeDraftProvider.notifier).initOneOnOne();
                    if (context.mounted) context.pushNamed('create');
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _QuickActionCard(
            title: 'Multi-party Signature',
            subtitle: 'Request signatures from multiple recipients',
            icon: LucideIcons.fileSignature,
            isWide: true,
            color: Colors.teal,
            onTap: () async {
              await ref.read(activeDraftProvider.notifier).initMultiParty();
              if (context.mounted) context.pushNamed('create');
            },
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isWide;

  const _QuickActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    this.isWide = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: Theme.of(context).brightness == Brightness.light
              ? color.withOpacity(0.1)
              : color.withOpacity(0.3),
        ),
      ),
      color: Theme.of(context).colorScheme.surface,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Opacity(
              opacity: 0.5,
              child: Icon(LucideIcons.fileSignature,
                  size: 64, color: colorScheme.outline),
            ),
            const SizedBox(height: 16),
            Text(
              'No recent activity',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your sent and draft requests will appear here',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
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
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: _getStatusColor(request.status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  LucideIcons.fileText,
                  color: _getStatusColor(request.status),
                  size: 26,
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
                          fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getStatusColor(request.status)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
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
                        const SizedBox(width: 8),
                        Text(
                          dateStr,
                          style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(LucideIcons.chevronRight,
                  color: colorScheme.outline, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeMenuItem extends ConsumerWidget {
  const _ThemeMenuItem();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Row(
      children: [
        Icon(isLight ? LucideIcons.moon : LucideIcons.sun, size: 20),
        const SizedBox(width: 12),
        Text(isLight ? 'Dark Mode' : 'Light Mode'),
      ],
    );
  }
}
