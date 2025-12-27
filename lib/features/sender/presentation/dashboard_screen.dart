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

enum SigningGroupMode { daily, weekly, monthly }

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
  SigningGroupMode _groupMode = SigningGroupMode.daily;

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
        return _buildHomeView();
      case 1:
        return _buildSigningView();
      case 2:
        return _buildArchivingView();
      default:
        return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
  }

  Widget _buildHomeView() {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return SliverList(
      delegate: SliverChildListDelegate([
        DashboardHero(onChatTap: () => context.pushNamed('create_chat')),
        const SizedBox(height: 32),
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
      ]),
    );
  }

  Widget _buildSigningView() {
    final requestsAsync = ref.watch(requestsProvider);
    final theme = Theme.of(context);

    return requestsAsync.when(
      data: (requests) {
        final drafts = requests
            .where((r) => r.status == RequestStatus.draft)
            .toList();
        final sent = requests
            .where((r) => r.status == RequestStatus.sent)
            .toList();

        if (drafts.isEmpty && sent.isEmpty) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(top: 40),
              child: Center(child: Text("No active requests or drafts.")),
            ),
          );
        }

        final displayItems = <dynamic>[];

        // Grouping Selector
        displayItems.add('GROUP_SELECTOR');

        // Combined and Grouped List
        final allActive = [...drafts, ...sent];
        allActive.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        final grouped = _groupRequests(allActive, _groupMode);

        grouped.forEach((label, items) {
          if (items.isNotEmpty) {
            displayItems.add('HEADER:$label');
            displayItems.addAll(items);
          }
        });

        return SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final item = displayItems[index];

            if (item == 'GROUP_SELECTOR') {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _GroupModeChip(
                        label: "Daily",
                        isSelected: _groupMode == SigningGroupMode.daily,
                        onSelected: () =>
                            setState(() => _groupMode = SigningGroupMode.daily),
                      ),
                      const SizedBox(width: 8),
                      _GroupModeChip(
                        label: "Weekly",
                        isSelected: _groupMode == SigningGroupMode.weekly,
                        onSelected: () => setState(
                          () => _groupMode = SigningGroupMode.weekly,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _GroupModeChip(
                        label: "Monthly",
                        isSelected: _groupMode == SigningGroupMode.monthly,
                        onSelected: () => setState(
                          () => _groupMode = SigningGroupMode.monthly,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (item is String && item.startsWith('HEADER:')) {
              return Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 8),
                child: Text(
                  item.replaceFirst('HEADER:', ''),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
              );
            }

            if (item is SignatureRequest) {
              return _RequestItem(
                request: item,
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

  Map<String, List<SignatureRequest>> _groupRequests(
    List<SignatureRequest> requests,
    SigningGroupMode mode,
  ) {
    final grouped = <String, List<SignatureRequest>>{};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (final req in requests) {
      String label;
      final date = req.createdAt;

      if (mode == SigningGroupMode.daily) {
        final reqDay = DateTime(date.year, date.month, date.day);
        if (reqDay == today) {
          label = "TODAY";
        } else if (reqDay == today.subtract(const Duration(days: 1))) {
          label = "YESTERDAY";
        } else {
          label = DateFormat('EEEE, MMM d').format(date).toUpperCase();
        }
      } else if (mode == SigningGroupMode.weekly) {
        final weekStart = today.subtract(Duration(days: today.weekday - 1));
        final lastWeekStart = weekStart.subtract(const Duration(days: 7));

        if (date.isAfter(weekStart)) {
          label = "THIS WEEK";
        } else if (date.isAfter(lastWeekStart)) {
          label = "LAST WEEK";
        } else {
          label = "OLDER";
        }
      } else {
        label = DateFormat('MMMM yyyy').format(date).toUpperCase();
      }

      if (!grouped.containsKey(label)) {
        grouped[label] = [];
      }
      grouped[label]!.add(req);
    }
    return grouped;
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

class DashboardHero extends StatelessWidget {
  final VoidCallback onChatTap;

  const DashboardHero({super.key, required this.onChatTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              Icons.fingerprint,
              size: 48,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.dashboardTitle,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.dashboardSubtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              l10n.dashboardPoweredBy,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupModeChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const _GroupModeChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected
            ? theme.colorScheme.onPrimary
            : theme.colorScheme.onSurface,
      ),
      selectedColor: theme.colorScheme.primary,
      backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(
        alpha: 0.3,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.outlineVariant,
        ),
      ),
    );
  }
}
