import 'package:digito_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../domain/models/signature_request.dart';

// --- Header ---
// --- Header ---
class DashboardHeader extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onMenuTap;
  final VoidCallback onProfileTap;

  const DashboardHeader({
    super.key,
    required this.onMenuTap,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      backgroundColor: theme.colorScheme.surface,
      elevation: 0,
      titleSpacing: 20,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.primary, // Brand Blue from theme
            ),
            child: Icon(
              Icons.fingerprint,
              color: theme.colorScheme.onPrimary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            "Digito",
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.account_circle,
            color: theme.colorScheme.onSurface,
            size: 28,
          ),
          onPressed: onProfileTap,
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// --- Segmented Tab Selector ---
class SegmentedTabSelector extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;

  const SegmentedTabSelector({
    super.key,
    required this.selectedIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            children: [
              _buildTab(context, AppLocalizations.of(context)!.tabDrafting, 0),
              _buildTab(context, AppLocalizations.of(context)!.tabSigning, 1),
              _buildTab(context, AppLocalizations.of(context)!.tabArchiving, 2),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTab(BuildContext context, String label, int index) {
    final isSelected = selectedIndex == index;
    final theme = Theme.of(context);

    return Expanded(
      child: GestureDetector(
        onTap: () => onTabChanged(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? theme.colorScheme.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --- Option Card (Hero & Grid) ---
class DashboardOptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final VoidCallback onTap;
  final bool isHero; // If true, renders the large top card

  const DashboardOptionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.iconBgColor = const Color(0xFFE8F0FE), // Default fallback
    this.iconColor = const Color(0xFF1967D2), // Default fallback
    required this.onTap,
    this.isHero = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isHero) {
      return Card(
        elevation: 0,
        color: theme.colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: iconBgColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(icon, color: iconColor, size: 24),
                    ),
                    // Decorative elements from design
                    Row(
                      children: [
                        Icon(
                          Icons.arrow_forward,
                          color: theme.colorScheme.outlineVariant,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Grid Style Card
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const Spacer(),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Quick Access Row ---
class QuickAccessRow extends StatelessWidget {
  final int pendingCount;
  final VoidCallback onPendingTap;
  final VoidCallback onUploadTap;

  const QuickAccessRow({
    super.key,
    required this.pendingCount,
    required this.onPendingTap,
    required this.onUploadTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionChip(
            icon: Icons.pending_actions,
            label: 'Pending ($pendingCount)',
            color: Colors.orange, // Keep distinct semantic colors
            onTap: onPendingTap,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionChip(
            icon: Icons.cloud_upload_outlined,
            label: 'Upload File',
            color: Colors.blue, // Keep distinct semantic colors
            onTap: onUploadTap,
          ),
        ),
        const SizedBox(width: 12),
        // Placeholder for alignment or extra action
        const Expanded(child: SizedBox()),
      ],
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: theme.colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Start Document Button ---
class StartDocumentButton extends StatelessWidget {
  final VoidCallback onTap;

  const StartDocumentButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: FilledButton.icon(
          onPressed: onTap,
          icon: const Icon(Icons.add),
          label: const Text(
            "Start New Document",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 4,
            shadowColor: theme.colorScheme.primary.withOpacity(0.4),
          ),
        ),
      ),
    );
  }
}

// --- History Request Item ---
class HistoryRequestItem extends StatelessWidget {
  final String title;
  final String recipientName;
  final String recipientEmail;
  final DateTime date;
  final RequestStatus status;
  final VoidCallback onTap;

  const HistoryRequestItem({
    super.key,
    required this.title,
    required this.recipientName,
    required this.recipientEmail,
    required this.date,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateStr = DateFormat('MMM d, yyyy').format(date);
    final statusColor = _getStatusColor(status);
    final statusBgColor = _getStatusBgColor(status);
    // basic label for now
    final statusLabel = status.name;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        _getStatusIcon(status),
                        color: statusColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  title.isNotEmpty
                                      ? title
                                      : "Untitled Document",
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: statusBgColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  statusLabel.toUpperCase(),
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: statusColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.person_outline,
                                size: 16,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                recipientName.isNotEmpty
                                    ? recipientName
                                    : "Unknown Recipient",
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.alternate_email,
                                size: 16,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  recipientEmail.isNotEmpty
                                      ? recipientEmail
                                      : "No email provided",
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Sent: $dateStr",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      "View Details →",
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(RequestStatus status) {
    switch (status) {
      case RequestStatus.draft:
        return Colors.orange;
      case RequestStatus.sent:
        return Colors.blue;
      case RequestStatus.completed:
        return const Color(0xFF137333); // Green
      case RequestStatus.declined:
      case RequestStatus.voided:
        return const Color(0xFFC5221F); // Red
    }
  }

  Color _getStatusBgColor(RequestStatus status) {
    switch (status) {
      case RequestStatus.draft:
        return Colors.orange.withOpacity(0.1);
      case RequestStatus.sent:
        return Colors.blue.withOpacity(0.1);
      case RequestStatus.completed:
        return const Color(0xFFE6F4EA); // Light Green
      case RequestStatus.declined:
      case RequestStatus.voided:
        return const Color(0xFFFCE8E6); // Light Red
    }
  }

  IconData _getStatusIcon(RequestStatus status) {
    switch (status) {
      case RequestStatus.draft:
        return Icons.edit_note;
      case RequestStatus.sent:
        return Icons.send;
      case RequestStatus.completed:
        return Icons.check_circle_outline;
      case RequestStatus.declined:
        return Icons.cancel_outlined;
      case RequestStatus.voided:
        return Icons.block;
    }
  }
}
