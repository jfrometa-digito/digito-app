import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/user_profile.dart';
import 'auth_provider.dart';

part 'profile_provider.g.dart';

@riverpod
class ProfileState extends _$ProfileState {
  @override
  AsyncValue<UserProfile?> build() {
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.whenData((user) {
      if (user == null) return null;

      // Initial load - in a real app this would fetch from a repository
      // For now we'll initialize with mock data based on the user's role
      return UserProfile(
        id: user.id,
        email: user.email,
        name: user.name,
        role: user.role == 'admin' ? UserRole.admin : UserRole.user,
        status: AccountStatus.active,
        createdAt: DateTime(2025, 1, 1),
        lastAccess: DateTime.now(),
        // Regular user starts with some prerequisites incomplete for demo
        identityValidated: user.role == 'admin',
        adhesionContractAccepted: user.role == 'admin',
        certificateContractAccepted: user.role == 'admin',
        permissions: user.role == 'admin'
            ? ['Firmar documentos', 'Administrar usuarios', 'Generar reportes']
            : ['Firmar documentos'],
      );
    });
  }

  Future<void> updateContract(String type, bool accepted) async {
    final current = state.valueOrNull;
    if (current == null) return;

    state = AsyncData(current.copyWith(
      adhesionContractAccepted:
          type == 'adhesion' ? accepted : current.adhesionContractAccepted,
      certificateContractAccepted: type == 'certificate'
          ? accepted
          : current.certificateContractAccepted,
      identityValidated:
          type == 'identity' ? accepted : current.identityValidated,
      adhesionContractAcceptedAt: type == 'adhesion' && accepted
          ? DateTime.now()
          : current.adhesionContractAcceptedAt,
      certificateContractAcceptedAt: type == 'certificate' && accepted
          ? DateTime.now()
          : current.certificateContractAcceptedAt,
      identityValidatedAt: type == 'identity' && accepted
          ? DateTime.now()
          : current.identityValidatedAt,
    ));
  }

  Future<void> createCertificate() async {
    final current = state.valueOrNull;
    if (current == null || !current.canCreateCertificate) return;

    state = AsyncData(current.copyWith(
      hasCertificate: true,
      certificateId: 'CERT-${DateTime.now().millisecondsSinceEpoch}',
      certificateCreatedAt: DateTime.now(),
      certificateRevoked: false,
    ));
  }

  Future<void> revokeCertificate() async {
    final current = state.valueOrNull;
    if (current == null) return;

    state = AsyncData(current.copyWith(
      hasCertificate: false,
      certificateRevoked: true,
      certificateRevokedAt: DateTime.now(),
    ));
  }
}
