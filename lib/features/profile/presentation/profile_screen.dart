import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/providers/profile_provider.dart';
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final profileAsync = ref.watch(profileStateProvider);

    return profileAsync.when(
      data: (profile) {
        if (profile == null) {
          return const Scaffold(
            body: Center(child: Text('Please log in to view your profile')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Perfil'),
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
                      Text(
                        profile.name ?? 'Usuario',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        profile.email,
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _StatusBadge(status: profile.status),
                      const SizedBox(height: 16),
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
                            'Administrador del Sistema',
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Administrative Info (Only for Admins)
                if (profile.isAdmin)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Información Administrativa',
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
                                    label: 'User ID', value: profile.id)),
                            const SizedBox(width: 16),
                            Expanded(
                                child: _InfoTile(
                                    label: 'Auth0 ID',
                                    value: profile.auth0Id ?? profile.id)),
                          ],
                        ),
                      ],
                    ),
                  ),

                // Common Stats
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Row(
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
                          label: 'Cuenta creada',
                          value: DateFormat('MMM dd, yyyy')
                              .format(profile.createdAt),
                        ),
                      ),
                    ],
                  ),
                ),

                // Settings Section (Theme Toggle)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ajustes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SwitchListTile(
                        title: const Text('Modo Oscuro'),
                        secondary: Icon(
                          Theme.of(context).brightness == Brightness.light
                              ? LucideIcons.moon
                              : LucideIcons.sun,
                        ),
                        value: Theme.of(context).brightness == Brightness.dark,
                        onChanged: (_) =>
                            ref.read(appThemeModeProvider.notifier).toggle(),
                      ),
                      const Divider(),
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
                  height: 450,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _RolesTab(profile: profile),
                      _PermissionsTab(profile: profile),
                      _CertificateTab(profile: profile, ref: ref),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, _) => Scaffold(body: Center(child: Text('Error: $err'))),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final AccountStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = status == AccountStatus.active ? Colors.green : Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status == AccountStatus.active ? 'Activo' : 'Inactivo',
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
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
              Text('Roles Asignados',
                  style: TextStyle(
                      fontSize: 14, color: colorScheme.onSurfaceVariant)),
              if (profile.isAdmin)
                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(LucideIcons.plus, size: 16),
                  label: const Text('Asignar rol'),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _RoleTile(
            title: profile.isAdmin ? 'Admin' : 'Usuario Regular',
            description: profile.isAdmin
                ? 'Acceso total al sistema'
                : 'Capacidad de firmar y enviar documentos',
          ),
        ],
      ),
    );
  }
}

class _RoleTile extends StatelessWidget {
  final String title;
  final String description;
  const _RoleTile({required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: colorScheme.surfaceContainerHighest,
            child: Icon(LucideIcons.user,
                size: 20, color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                Text(description,
                    style: TextStyle(
                        fontSize: 12, color: colorScheme.onSurfaceVariant)),
              ],
            ),
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
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('Tus Permisos',
            style:
                TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant)),
        const SizedBox(height: 12),
        ...profile.permissions.map((p) => ListTile(
              leading: const Icon(LucideIcons.checkCircle2,
                  color: Colors.green, size: 20),
              title: Text(p),
              dense: true,
              contentPadding: EdgeInsets.zero,
            )),
      ],
    );
  }
}

class _CertificateTab extends StatelessWidget {
  final UserProfile profile;
  final WidgetRef ref;
  const _CertificateTab({required this.profile, required this.ref});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Requisitos del Certificado',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface),
          ),
          const SizedBox(height: 16),
          _PrerequisiteItem(
            title: 'Validación de Identidad',
            isDone: profile.identityValidated,
            onAction: () => ref
                .read(profileStateProvider.notifier)
                .updateContract('identity', true),
          ),
          _PrerequisiteItem(
            title: 'Contrato de Adhesión',
            isDone: profile.adhesionContractAccepted,
            onAction: () => ref
                .read(profileStateProvider.notifier)
                .updateContract('adhesion', true),
          ),
          _PrerequisiteItem(
            title: 'Contrato de Certificado',
            isDone: profile.certificateContractAccepted,
            onAction: () => ref
                .read(profileStateProvider.notifier)
                .updateContract('certificate', true),
          ),
          const SizedBox(height: 24),
          if (profile.hasCertificate)
            _CertificateActive(
              certificateId: profile.certificateId ?? 'N/A',
              onRevoke: () => _showRevokeDialog(context, ref),
            )
          else
            _CertificateActionCard(
              profile: profile,
              onAction: () =>
                  ref.read(profileStateProvider.notifier).createCertificate(),
            ),
        ],
      ),
    );
  }

  void _showRevokeDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Revocar Certificado'),
        content: const Text(
            'Esta acción invalidará tu firma electrónica. ¿Deseas continuar?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              ref.read(profileStateProvider.notifier).revokeCertificate();
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Revocar'),
          ),
        ],
      ),
    );
  }
}

class _PrerequisiteItem extends StatelessWidget {
  final String title;
  final bool isDone;
  final VoidCallback onAction;

  const _PrerequisiteItem(
      {required this.title, required this.isDone, required this.onAction});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isDone
                  ? Colors.green.withValues(alpha: 0.3)
                  : colorScheme.outline.withValues(alpha: 0.2)),
          color: isDone ? Colors.green.withValues(alpha: 0.05) : null,
        ),
        child: Row(
          children: [
            Icon(isDone ? LucideIcons.checkCircle2 : LucideIcons.circle,
                color: isDone ? Colors.green : colorScheme.outline, size: 20),
            const SizedBox(width: 12),
            Expanded(
                child: Text(title,
                    style: TextStyle(
                        fontWeight:
                            isDone ? FontWeight.w600 : FontWeight.normal))),
            if (!isDone)
              TextButton(onPressed: onAction, child: const Text('Completar'))
            else
              const Icon(LucideIcons.check, color: Colors.green, size: 16),
          ],
        ),
      ),
    );
  }
}

class _CertificateActive extends StatelessWidget {
  final String certificateId;
  final VoidCallback onRevoke;
  const _CertificateActive(
      {required this.certificateId, required this.onRevoke});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          const Icon(LucideIcons.shieldCheck, size: 48, color: Colors.green),
          const SizedBox(height: 12),
          const Text('Certificado Activo',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          Text('ID: $certificateId', style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: onRevoke,
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Revocar Certificado'),
          ),
        ],
      ),
    );
  }
}

class _CertificateActionCard extends StatelessWidget {
  final UserProfile profile;
  final VoidCallback onAction;
  const _CertificateActionCard({required this.profile, required this.onAction});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final canCreate = profile.canCreateCertificate;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: canCreate
            ? Colors.blue.withValues(alpha: 0.05)
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: canCreate
            ? Border.all(color: Colors.blue.withValues(alpha: 0.2))
            : null,
      ),
      child: Column(
        children: [
          Icon(canCreate ? LucideIcons.unlock : LucideIcons.lock,
              size: 48,
              color: canCreate ? Colors.blue : colorScheme.onSurfaceVariant),
          const SizedBox(height: 12),
          Text(
            canCreate ? '¡Listo para firmar!' : 'Prerrequisitos faltantes',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: canCreate ? Colors.blue : colorScheme.onSurface),
          ),
          const SizedBox(height: 8),
          Text(
            canCreate
                ? 'Puedes generar tu firma digital ahora.'
                : 'Debes completar los pasos anteriores.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: canCreate ? onAction : null,
              child: const Text('Crear Certificado Digital'),
            ),
          ),
        ],
      ),
    );
  }
}
