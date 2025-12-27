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
  String _searchQuery = "";
  final Set<RequestStatus> _selectedStatuses = {};
  bool _showSearch = false;
  bool _showFilters = false;

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
              SliverPersistentHeader(
                pinned: true,
                delegate: _StickyTabDelegate(
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
          "ONGOING DRAFTS",
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 16),
        ..._buildGroupedDrafts(context, requests),
      ]),
    );
  }

  List<Widget> _buildGroupedDrafts(
    BuildContext context,
    List<SignatureRequest> requests,
  ) {
    final drafts = requests
        .where((r) => r.status == RequestStatus.draft)
        .toList();
    drafts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (drafts.isEmpty) {
      return [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(child: Text("No drafts found.")),
        ),
      ];
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final thisWeek = today.subtract(const Duration(days: 7));
    final thisMonth = DateTime(now.year, now.month, 1);

    final grouped = <String, List<SignatureRequest>>{
      'TODAY': [],
      'THIS WEEK': [],
      'THIS MONTH': [],
      'OLDER': [],
    };

    for (final draft in drafts) {
      final date = draft.createdAt;
      final draftDay = DateTime(date.year, date.month, date.day);

      if (draftDay == today) {
        grouped['TODAY']!.add(draft);
      } else if (date.isAfter(thisWeek)) {
        grouped['THIS WEEK']!.add(draft);
      } else if (date.isAfter(thisMonth)) {
        grouped['THIS MONTH']!.add(draft);
      } else {
        grouped['OLDER']!.add(draft);
      }
    }

    final widgets = <Widget>[];
    final theme = Theme.of(context);

    grouped.forEach((label, items) {
      if (items.isNotEmpty) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
        for (final item in items) {
          widgets.add(
            _RequestItem(
              request: item,
              onTap: () => _resumeDraft(context, ref, item),
            ),
          );
        }
      }
    });

    return widgets;
  }

  Widget _buildSigningView() {
    final requestsAsync = ref.watch(requestsProvider);
    return requestsAsync.when(
      data: (requests) {
        final activeRequests = requests
            .where((r) => r.status == RequestStatus.sent)
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
        // --- Filtering Logic ---
        final filteredRequests = requests.where((r) {
          // Status Filter
          final matchesStatus =
              _selectedStatuses.isEmpty || _selectedStatuses.contains(r.status);

          // Search Filter
          final query = _searchQuery.toLowerCase();
          final matchesSearch =
              query.isEmpty ||
              r.title.toLowerCase().contains(query) ||
              r.recipients.any(
                (rec) =>
                    rec.name.toLowerCase().contains(query) ||
                    rec.email.toLowerCase().contains(query),
              );

          // Basic Archiving Filter (Terminal + Sent)
          final isArchivingRelevant =
              r.status == RequestStatus.sent ||
              r.status == RequestStatus.completed ||
              r.status == RequestStatus.declined ||
              r.status == RequestStatus.voided;

          return matchesStatus && matchesSearch && isArchivingRelevant;
        }).toList();

        // Build a flat list of items (headers and cards)
        final displayItems = <dynamic>[];

        // Section: Title & Search/Filter UI
        displayItems.add('TITLE_SECTION');

        String? firstHeader;
        if (filteredRequests.isEmpty) {
          displayItems.add('EMPTY_STATE');
        } else {
          // Group everything by month/year
          final groupedHistory = <String, List<SignatureRequest>>{};
          final monthFormat = DateFormat('MMMM yyyy');

          // Ensure sorted by date newest first
          final sortedRequests = List<SignatureRequest>.from(filteredRequests)
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

          for (final req in sortedRequests) {
            final key = monthFormat.format(req.createdAt).toUpperCase();
            if (!groupedHistory.containsKey(key)) {
              groupedHistory[key] = [];
            }
            groupedHistory[key]!.add(req);
          }

          final historyKeys = groupedHistory.keys.toList();
          firstHeader = historyKeys.isNotEmpty ? historyKeys.first : null;

          for (int i = 0; i < historyKeys.length; i++) {
            final key = historyKeys[i];
            // Skip adding HEADER for the first one if we want it in the Title section
            if (i > 0) {
              displayItems.add('HEADER:$key');
            }
            displayItems.addAll(groupedHistory[key]!);
          }
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final item = displayItems[index];

            if (item == 'TITLE_SECTION') {
              return _buildArchivingHeader(theme, firstHeader);
            }

            if (item == 'EMPTY_STATE') {
              return Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 48,
                        color: theme.colorScheme.outline,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isEmpty && _selectedStatuses.isEmpty
                            ? "No documents in history."
                            : "No matches found.",
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (item is String && item.startsWith('HEADER:')) {
              final label = item.replaceFirst('HEADER:', '');
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
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

  Widget _buildArchivingHeader(ThemeData theme, String? firstHeader) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment
              .spaceBetween, // Changed to spaceBetween for alignment
          children: [
            if (firstHeader != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 0),
                child: Text(
                  firstHeader,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              )
            else
              const SizedBox.shrink(),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    _showSearch ? Icons.search_off : Icons.search,
                    color: _showSearch
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                  onPressed: () => setState(() => _showSearch = !_showSearch),
                ),
                IconButton(
                  icon: Icon(
                    _showFilters ? Icons.filter_list_off : Icons.filter_list,
                    color: _showFilters
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                  onPressed: () => setState(() => _showFilters = !_showFilters),
                ),
                if (_searchQuery.isNotEmpty || _selectedStatuses.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _searchQuery = "";
                        _selectedStatuses.clear();
                      });
                    },
                    child: const Text("Clear All"),
                  ),
              ],
            ),
          ],
        ),
        ClipRect(
          child: AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                if (_showSearch) ...[
                  const SizedBox(height: 8),
                  // Search Bar
                  TextField(
                    onChanged: (value) => setState(() => _searchQuery = value),
                    decoration: InputDecoration(
                      hintText: "Search by title or recipient...",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerLow,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                ],
                if (_showFilters) ...[
                  const SizedBox(height: 12),
                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _StatusFilterChip(
                          label: "Sent",
                          status: RequestStatus.sent,
                          isSelected: _selectedStatuses.contains(
                            RequestStatus.sent,
                          ),
                          onSelected: _toggleStatusFilter,
                        ),
                        const SizedBox(width: 8),
                        _StatusFilterChip(
                          label: "Completed",
                          status: RequestStatus.completed,
                          isSelected: _selectedStatuses.contains(
                            RequestStatus.completed,
                          ),
                          onSelected: _toggleStatusFilter,
                        ),
                        const SizedBox(width: 8),
                        _StatusFilterChip(
                          label: "Declined",
                          status: RequestStatus.declined,
                          isSelected: _selectedStatuses.contains(
                            RequestStatus.declined,
                          ),
                          onSelected: _toggleStatusFilter,
                        ),
                        const SizedBox(width: 8),
                        _StatusFilterChip(
                          label: "Voided",
                          status: RequestStatus.voided,
                          isSelected: _selectedStatuses.contains(
                            RequestStatus.voided,
                          ),
                          onSelected: _toggleStatusFilter,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  void _toggleStatusFilter(RequestStatus status, bool selected) {
    setState(() {
      if (selected) {
        _selectedStatuses.add(status);
      } else {
        _selectedStatuses.remove(status);
      }
    });
  }

  void _resumeDraft(BuildContext context, WidgetRef ref, SignatureRequest req) {
    // Set as active draft
    ref.read(activeDraftProvider.notifier).loadFromObject(req);

    if (req.status == RequestStatus.draft) {
      // Always route drafts through chat for a unified experience
      context.push('/create-chat');
    } else {
      // For sent/completed/voided, show the details view
      context.push('/details/${req.id}');
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

class _StatusFilterChip extends StatelessWidget {
  final String label;
  final RequestStatus status;
  final bool isSelected;
  final Function(RequestStatus, bool) onSelected;

  const _StatusFilterChip({
    required this.label,
    required this.status,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) => onSelected(status, selected),
      selectedColor: theme.colorScheme.primaryContainer,
      checkmarkColor: theme.colorScheme.primary,
      labelStyle: TextStyle(
        color: isSelected
            ? theme.colorScheme.onPrimaryContainer
            : theme.colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.outline,
          width: isSelected ? 1 : 0.5,
        ),
      ),
    );
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

class _StickyTabDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickyTabDelegate({required this.child});

  @override
  double get minExtent => 72.0;
  @override
  double get maxExtent => 72.0;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: child,
    );
  }

  @override
  bool shouldRebuild(_StickyTabDelegate oldDelegate) {
    return true;
  }
}
