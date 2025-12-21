import 'dart:typed_data';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../domain/models/signature_request.dart';
import '../../../../domain/models/recipient.dart';
import '../../../../domain/models/placed_field.dart';
import '../data/requests_repository.dart';

part 'requests_provider.g.dart';

// Repository Provider
@riverpod
RequestsRepository requestsRepository(RequestsRepositoryRef ref) {
  return RequestsRepository();
}

// All Requests List Provider
@riverpod
class Requests extends _$Requests {
  @override
  Future<List<SignatureRequest>> build() async {
    final repo = ref.watch(requestsRepositoryProvider);
    return repo.getAllRequests();
  }

  Future<void> addOrUpdate(SignatureRequest request) async {
    final repo = ref.read(requestsRepositoryProvider);
    await repo.saveRequest(request);
    // Invalidate self to refresh list
    ref.invalidateSelf();
  }

  Future<void> delete(String id) async {
    final repo = ref.read(requestsRepositoryProvider);
    await repo.deleteRequest(id);
    ref.invalidateSelf();
  }
}

// --- Active Draft Logic ---

// Provider to hold the ID of the currently active draft being edited
@riverpod
class ActiveDraftId extends _$ActiveDraftId {
  @override
  String? build() => null;

  void set(String? id) => state = id;
}

// Provider to access/modify the active draft
@riverpod
class ActiveDraft extends _$ActiveDraft {
  @override
  SignatureRequest? build() {
    final id = ref.watch(activeDraftIdProvider);
    final requestsAsync = ref.watch(requestsProvider);

    if (id == null) return null;

    // Use valueOrNull to keep showing data while reloading (e.g., during save)
    final requests = requestsAsync.valueOrNull;
    if (requests == null) return null;

    try {
      return requests.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  // --- Actions to update the draft ---

  Future<void> initializeNewDraft() async {
    final newRequest = SignatureRequest(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Untitled Document',
      createdAt: DateTime.now(),
      status: RequestStatus.draft,
    );
    await ref.read(requestsProvider.notifier).addOrUpdate(newRequest);
    ref.read(activeDraftIdProvider.notifier).set(newRequest.id);
  }

  Future<void> updateFile(String filePath, String fileName,
      {Uint8List? fileBytes}) async {
    final current = state;
    if (current == null) return;

    final updated = current.copyWith(
      filePath: filePath,
      fileBytes: fileBytes,
      title: fileName, // Use filename as default title
      updatedAt: DateTime.now(),
    );
    await ref.read(requestsProvider.notifier).addOrUpdate(updated);
  }

  Future<void> updateRecipients(List<Recipient> recipients) async {
    final current = state;
    if (current == null) return;

    final updated = current.copyWith(
      recipients: recipients,
      updatedAt: DateTime.now(),
    );
    await ref.read(requestsProvider.notifier).addOrUpdate(updated);
  }

  Future<void> updateFields(List<PlacedField> fields) async {
    final current = state;
    if (current == null) return;

    final updated = current.copyWith(
      fields: fields,
      updatedAt: DateTime.now(),
    );
    await ref.read(requestsProvider.notifier).addOrUpdate(updated);
  }

  Future<void> markAsSent() async {
    final current = state;
    if (current == null) return;

    final updated = current.copyWith(
      status: RequestStatus.sent,
      updatedAt: DateTime.now(),
    );
    await ref.read(requestsProvider.notifier).addOrUpdate(updated);
    // Clear active draft after sending
    ref.read(activeDraftIdProvider.notifier).set(null);
  }
}
