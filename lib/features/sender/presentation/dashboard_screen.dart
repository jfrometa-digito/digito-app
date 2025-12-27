import 'package:digito_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../domain/models/signature_request.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/theme_provider.dart';
import '../providers/requests_provider.dart';
import 'widgets/dashboard_widgets.dart';
import '../../../../core/providers/locale_provider.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedIndex = 0; // 0: Drafting, 1: Signing, 2: Archiving

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: DashboardHeader(
        onMenuTap: () {
          // Future menu
        },
        onProfileTap: () => _showProfileMenu(context),
      ),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                  child: Text(
                    "Signing Mode",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Text(
                    "Select a workflow to begin",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SegmentedTabSelector(
                    selectedIndex: _selectedIndex,
                    onTabChanged: (index) =>
                        setState(() => _selectedIndex = index),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: _buildCurrentView(),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: StartDocumentButton(
              onTap: () {
                ref.read(activeDraftProvider.notifier).clear();
                context.pushNamed('create_chat');
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentView() {
    switch (_selectedIndex) {
      case 0:
        return _buildDraftingView();
      case 1:
        return _buildSigningView();
      case 2:
        return _buildArchivingView();
      default:
        return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
  }

  Widget _buildDraftingView() {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final requests = ref.watch(requestsProvider).value ?? [];
    final pendingCount = requests
        .where((r) => r.status == RequestStatus.sent)
        .length;

    return SliverList(
      delegate: SliverChildListDelegate([
        DashboardOptionCard(
          title: l10n.cardSelfSignTitle,
          subtitle: l10n.cardSelfSignSubtitle,
          icon: Icons.edit_note,
          iconBgColor: theme.colorScheme.primaryContainer,
          iconColor: theme.colorScheme.onPrimaryContainer,
          isHero: true,
          onTap: () async {
            await ref.read(activeDraftProvider.notifier).initSignMyself();
            if (mounted) context.pushNamed('create_chat');
          },
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SizedBox(
                height: 170, // Fixed height for alignment
                child: DashboardOptionCard(
                  title: l10n.cardOneOnOneTitle,
                  subtitle: l10n.cardOneOnOneSubtitle,
                  icon: Icons.people_outline,
                  iconBgColor: theme.colorScheme.secondaryContainer,
                  iconColor: theme.colorScheme.onSecondaryContainer,
                  onTap: () async {
                    await ref.read(activeDraftProvider.notifier).initOneOnOne();
                    if (mounted) context.pushNamed('create_chat');
                  },
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SizedBox(
                height: 170, // Fixed height for alignment
                child: DashboardOptionCard(
                  title: l10n.cardMultiPartyTitle,
                  // Truncate subtitle visually if needed in new design but keeping localized string
                  subtitle: l10n.cardMultiPartySubtitle,
                  icon: Icons.groups_outlined,
                  iconBgColor: const Color(0xFFE6F4EA), // Light green
                  iconColor: const Color(0xFF137333), // Green
                  onTap: () async {
                    await ref
                        .read(activeDraftProvider.notifier)
                        .initMultiParty();
                    if (mounted) context.pushNamed('create_chat');
                  },
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Text(
          "QUICK ACCESS",
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 16),
        QuickAccessRow(
          pendingCount: pendingCount,
          onPendingTap: () =>
              setState(() => _selectedIndex = 1), // Go to Signing
          onUploadTap: () async {
            // Go to self-sign as a shortcut
            await ref.read(activeDraftProvider.notifier).initSignMyself();
            if (mounted) context.pushNamed('create_chat');
          },
        ),
      ]),
    );
  }

  Widget _buildSigningView() {
    final requestsAsync = ref.watch(requestsProvider);
    return requestsAsync.when(
      data: (requests) {
        final activeRequests = requests
            .where(
              (r) =>
                  r.status == RequestStatus.sent ||
                  r.status == RequestStatus.draft,
            )
            .toList();

        if (activeRequests.isEmpty) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(top: 40),
              child: Center(child: Text("No active signing requests.")),
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final req = activeRequests[activeRequests.length - 1 - index];
            return _RequestItem(
              request: req,
              onTap: () => _resumeDraft(context, ref, req),
            );
          }, childCount: activeRequests.length),
        );
      },
      loading: () => const SliverToBoxAdapter(
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) =>
          SliverToBoxAdapter(child: Center(child: Text('Error: $err'))),
    );
  }

  Widget _buildArchivingView() {
    final requestsAsync = ref.watch(requestsProvider);
    final theme = Theme.of(context);

    return requestsAsync.when(
      data: (requests) {
        final ongoingRequests =
            requests.where((r) => r.status == RequestStatus.sent).toList()
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

        final terminalRequests =
            requests
                .where(
                  (r) =>
                      r.status == RequestStatus.completed ||
                      r.status == RequestStatus.declined ||
                      r.status == RequestStatus.voided,
                )
                .toList()
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

        if (ongoingRequests.isEmpty && terminalRequests.isEmpty) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(top: 40),
              child: Center(child: Text("No documents in history.")),
            ),
          );
        }

        // Group history by month/year
        final groupedHistory = <String, List<SignatureRequest>>{};
        final monthFormat = DateFormat('MMMM yyyy');

        for (final req in terminalRequests) {
          final key = monthFormat.format(req.createdAt).toUpperCase();
          if (!groupedHistory.containsKey(key)) {
            groupedHistory[key] = [];
          }
          groupedHistory[key]!.add(req);
        }

        final historyKeys = groupedHistory.keys.toList();

        // Build a flat list of items (headers and cards)
        final displayItems = <dynamic>[];

        // Section: Title & Subtitle
        displayItems.add('TITLE_SECTION');

        // Section: Ongoing
        if (ongoingRequests.isNotEmpty) {
          displayItems.add('HEADER:ONGOING');
          displayItems.addAll(ongoingRequests);
        }

        // Section: History Groups
        if (terminalRequests.isNotEmpty) {
          for (final key in historyKeys) {
            displayItems.add('HEADER:$key');
            displayItems.addAll(groupedHistory[key]!);
          }
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final item = displayItems[index];

            if (item == 'TITLE_SECTION') {
              return Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Document History",
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.filter_list,
                            color: theme.colorScheme.primary,
                          ),
                          onPressed: () {}, // Filter logic later
                        ),
                      ],
                    ),
                    Text(
                      "Manage your ongoing and signed documents",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (item is String && item.startsWith('HEADER:')) {
              final label = item.replaceFirst('HEADER:', '');
              return Padding(
                padding: const EdgeInsets.only(top: 24, bottom: 12),
                child: Text(
                  label == 'ONGOING' ? "ONGOING SIGNATURES" : label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              );
            }

            if (item is SignatureRequest) {
              final recipientName = item.recipients.isNotEmpty
                  ? item.recipients.first.name
                  : "No Recipient";
              final recipientEmail = item.recipients.isNotEmpty
                  ? item.recipients.first.email
                  : "";

              return HistoryRequestItem(
                title: item.title,
                recipientName: recipientName,
                recipientEmail: recipientEmail,
                date: item.createdAt,
                status: item.status,
                onTap: () => _resumeDraft(context, ref, item),
              );
            }

            return const SizedBox.shrink();
          }, childCount: displayItems.length),
        );
      },
      loading: () => const SliverToBoxAdapter(
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) =>
          SliverToBoxAdapter(child: Center(child: Text('Error: $err'))),
    );
  }

  void _resumeDraft(BuildContext context, WidgetRef ref, SignatureRequest req) {
    if (req.status == RequestStatus.draft) {
      ref.read(activeDraftProvider.notifier).loadFromObject(req);
      if (req.fields.isNotEmpty) {
        context.pushNamed('editor');
      } else if (req.recipients.isNotEmpty) {
        context.pushNamed('recipients');
      } else {
        context.pushNamed('create_chat');
      }
    } else if (req.status == RequestStatus.sent) {
      context.pushNamed('share', pathParameters: {'requestId': req.id});
    }
  }

  Future<void> _showProfileMenu(BuildContext context) async {
    try {
      final isAuth = await ref.read(isAuthenticatedProvider.future);

      if (!context.mounted) return;

      showModalBottomSheet(
        context: context,
        builder: (ctx) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.person),
                title: Text(AppLocalizations.of(context)!.menuProfile),
                onTap: () {
                  Navigator.pop(ctx);
                  if (isAuth) {
                    context.pushNamed('profile');
                  } else {
                    context.pushNamed('login');
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.brightness_6),
                title: Text(AppLocalizations.of(context)!.menuToggleTheme),
                onTap: () {
                  ref.read(appThemeModeProvider.notifier).toggle();
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Icon(Icons.language),
                title: Text(AppLocalizations.of(context)!.menuLanguage),
                trailing: Text(
                  ref.read(appLocaleProvider).languageCode.toUpperCase(),
                ),
                onTap: () {
                  ref.read(appLocaleProvider.notifier).toggle();
                  Navigator.pop(ctx);
                },
              ),
              if (isAuth)
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: Text(AppLocalizations.of(context)!.menuLogOut),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final authService = ref.read(authServiceProvider);
                    await authService.logout();
                    ref.invalidate(currentUserProvider);
                    ref.invalidate(isAuthenticatedProvider);
                  },
                )
              else
                ListTile(
                  leading: const Icon(Icons.login),
                  title: const Text('Log In'),
                  onTap: () {
                    Navigator.pop(ctx);
                    context.pushNamed('login');
                  },
                ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (context.mounted) {
        // Safe fallback
      }
    }
  }
}

class _RequestItem extends StatelessWidget {
  final SignatureRequest request;
  final VoidCallback onTap;

  const _RequestItem({required this.request, required this.onTap});

  Color _getStatusColor(RequestStatus status) {
    switch (status) {
      case RequestStatus.draft:
        return Colors.orange;
      case RequestStatus.sent:
        return Colors.blue;
      case RequestStatus.completed:
        return Colors.green;
      case RequestStatus.declined:
      case RequestStatus.voided:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateStr = DateFormat('MMM d').format(request.createdAt);
    final statusColor = _getStatusColor(request.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.description, color: statusColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.title.isNotEmpty
                          ? request.title
                          : "Untitled Document",
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "$dateStr • ${request.status.name.toUpperCase()}",
                      style: theme.textTheme.bodySmall?.copyWith(
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
}
