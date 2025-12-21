import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../domain/models/user_profile.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  //  Mock profile data - will be replaced with real data from provider
  UserProfile get _mockProfile => UserProfile(
        id: 'ID21331654895621478563115',
        email: 'juan.elias.rodriguez@domainspa.com',
        name: 'Juan Elias Rodriguez Reyes',
        role: UserRole.admin,
        status: AccountStatus.active,
        createdAt: DateTime(2025, 10, 30),
        lastAccess: DateTime(2025, 11, 5),
        adhesionContractAccepted: true,
        certificateContractAccepted: true,
        identityValidated: true,
        hasCertificate: true,
        permissions: [
          'Firmar documetos',
          'Generar links de firma',
          'Actualizar integraciones',
          'Algo mas sobre dev',
        ],
      );

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final profile = _mockProfile; // TODO: Replace with real data

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
              ),
              child: Column(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: colorScheme.primaryContainer,
                    child: Text(
                      profile.name?.substring(0, 1).toUpperCase() ?? 'U',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Name
                  Text(
                    profile.name ?? 'User',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Email
                  Text(
                    profile.email,
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Status Badge
                  _StatusBadge(status: profile.status),
                  const SizedBox(height: 16),
                  // Role Tag (if admin)
                  if (profile.isAdmin)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'Full-stack developer engineer lvl 2',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Info Section
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informacion de Usuario',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _InfoTile(
                          label: 'User ID',
                          value: profile.id,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _InfoTile(
                          label: 'Auth0 ID',
                          value: profile.auth0Id ?? profile.id,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _InfoTile(
                          label: 'Último acceso',
                          value: DateFormat('MMM dd, yyyy')
                              .format(profile.lastAccess),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _InfoTile(
                          label: 'Creación',
                          value: DateFormat('MMM dd, yyyy')
                              .format(profile.createdAt),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Tabs
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Roles'),
                Tab(text: 'Permisos'),
                Tab(text: 'Certificado'),
              ],
            ),

            // Tab Content
            SizedBox(
              height: 400,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _RolesTab(profile: profile),
                  _PermissionsTab(profile: profile),
                  _CertificateTab(profile: profile),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final AccountStatus status;

  const _StatusBadge({required this.status});

  Color _getColor(BuildContext context) {
    switch (status) {
      case AccountStatus.active:
        return Colors.green;
      case AccountStatus.inactive:
        return Colors.orange;
      case AccountStatus.disconnected:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: _getColor(context), width: 2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status == AccountStatus.active
            ? 'Activo'
            : status == AccountStatus.inactive
                ? 'Inactivo'
                : 'Desconectado',
        style: TextStyle(
          color: _getColor(context),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;

  const _InfoTile({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _RolesTab extends StatelessWidget {
  final UserProfile profile;

  const _RolesTab({required this.profile});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Roles Asignados',
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              if (profile.isAdmin)
                FilledButton.icon(
                  onPressed: () {
                    // TODO: Implement assign role
                  },
                  icon: const Icon(LucideIcons.plus, size: 16),
                  label: const Text('Asignar rol'),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _RoleTile(
            title: 'Full-stack developer engineer lvl 2',
            description: 'Description del rol',
            onDelete: profile.isAdmin ? () {} : null,
          ),
          const SizedBox(height: 8),
          _RoleTile(
            title: 'Firmante',
            description: 'Permision del rol',
            onDelete: profile.isAdmin ? () {} : null,
          ),
        ],
      ),
    );
  }
}

class _RoleTile extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback? onDelete;

  const _RoleTile({
    required this.title,
    required this.description,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outline),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: colorScheme.surfaceContainerHighest,
            child: Icon(
              LucideIcons.user,
              size: 20,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (onDelete != null)
            IconButton(
              icon: const Icon(LucideIcons.trash2, size: 20),
              color: Colors.red,
              onPressed: onDelete,
            ),
        ],
      ),
    );
  }
}

class _PermissionsTab extends StatelessWidget {
  final UserProfile profile;

  const _PermissionsTab({required this.profile});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Permisos Asignados',
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Lorem ipsum dolor sit amet consectetur.',
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          ...profile.permissions.map(
            (permission) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(
                    permission.toLowerCase().contains('firma')
                        ? LucideIcons.penTool
                        : permission.toLowerCase().contains('link')
                            ? LucideIcons.link
                            : permission.toLowerCase().contains('integr')
                                ? LucideIcons.code
                                : LucideIcons.moreHorizontal,
                    size: 20,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(permission),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CertificateTab extends StatelessWidget {
  final UserProfile profile;

  const _CertificateTab({required this.profile});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Contract Status
          _ContractStatusTile(
            title: 'Contrato de adhesión',
            accepted: profile.adhesionContractAccepted,
            acceptedAt: profile.adhesionContractAcceptedAt,
          ),
          const SizedBox(height: 8),
          _ContractStatusTile(
            title: 'Contrato de certificado',
            accepted: profile.certificateContractAccepted,
            acceptedAt: profile.certificateContractAcceptedAt,
          ),
          const SizedBox(height: 8),
          _ContractStatusTile(
            title: 'Validación de identidad',
            accepted: profile.identityValidated,
            acceptedAt: profile.identityValidatedAt,
          ),
          const SizedBox(height: 24),

          // Certificate Status
          if (profile.hasCertificate) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  const Icon(
                    LucideIcons.checkCircle,
                    size: 48,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Certificado creado exitosamente',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () {
                      _showRevokeDialog(context);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Revocar Certificado'),
                  ),
                ],
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Icon(
                    LucideIcons.alertCircle,
                    size: 48,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No se ha creado un certificado',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () {
                      // TODO: Create certificate
                    },
                    icon: const Icon(LucideIcons.plus, size: 16),
                    label: const Text('Crear Certificado'),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showRevokeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Revocar Certificado'),
        content: const Text(
          'Esta acción es irreversible. Al proceder, tu certificado se invalidará de forma permanente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              // TODO: Revoke certificate
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Revocar'),
          ),
        ],
      ),
    );
  }
}

class _ContractStatusTile extends StatelessWidget {
  final String title;
  final bool accepted;
  final DateTime? acceptedAt;

  const _ContractStatusTile({
    required this.title,
    required this.accepted,
    this.acceptedAt,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outline),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            accepted ? LucideIcons.checkCircle2 : LucideIcons.circle,
            size: 20,
            color: accepted ? Colors.green : colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (accepted && acceptedAt != null)
                  Text(
                    'Aceptado: ${DateFormat('MMM dd, yyyy').format(acceptedAt!)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
