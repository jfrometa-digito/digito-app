import 'dart:typed_data';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../domain/models/signature_request.dart';
import '../../../../domain/models/recipient.dart';
import '../../../../domain/models/placed_field.dart';
import '../../../../core/providers/auth_provider.dart';
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

    // Optimistic update to avoid loading gap which breaks ActiveDraft
    final currentList = state.valueOrNull ?? [];
    final index = currentList.indexWhere((r) => r.id == request.id);

    if (index != -1) {
      final updatedList = List<SignatureRequest>.from(currentList);
      updatedList[index] = request;
      state = AsyncData(updatedList);
    } else {
      state = AsyncData([...currentList, request]);
    }
  }

  Future<void> delete(String id) async {
    final repo = ref.read(requestsRepositoryProvider);
    await repo.deleteRequest(id);

    final currentList = state.valueOrNull ?? [];
    final updatedList = currentList.where((r) => r.id != id).toList();
    state = AsyncData(updatedList);
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

// In-memory storage for file bytes (Web support)
// This is needed because saving to the repository (SharedPreferences) strips out the bytes.
final _transientFiles = <String, Uint8List>{};

@riverpod
class TransientFile extends _$TransientFile {
  @override
  Uint8List? build(String requestId) {
    return _transientFiles[requestId];
  }

  void set(Uint8List? bytes) {
    if (bytes != null) {
      _transientFiles[requestId] = bytes;
    } else {
      _transientFiles.remove(requestId);
    }
    state = bytes;
  }
}

// Provider to access/modify the active draft
@riverpod
class ActiveDraft extends _$ActiveDraft {
  @override
  SignatureRequest? build() {
    // We no longer purely watch the list for the draft.
    // The state of this notifier IS the source of truth for the draft being edited.
    // This allows us to have a "virtual" draft that isn't in the requests list yet.
    return null;
  }

  // Helper to sync draft to main requests list & repository
  Future<void> _persist(SignatureRequest draft) async {
    // Only persist if there's something meaningful (at least a file or a recipient)
    final isMeaningful = draft.filePath != null ||
        draft.fileBytes != null ||
        draft.recipients.isNotEmpty;

    if (isMeaningful) {
      await ref.read(requestsProvider.notifier).addOrUpdate(draft);
    }
  }

  void set(SignatureRequest? draft) {
    state = draft;
  }

  void loadExisting(String id) {
    final requests = ref.read(requestsProvider).valueOrNull ?? [];
    try {
      final request = requests.firstWhere((r) => r.id == id);
      // Merge transient bytes if available
      final transientBytes = ref.read(transientFileProvider(id));
      if (transientBytes != null) {
        state = request.copyWith(fileBytes: transientBytes);
      } else {
        state = request;
      }
    } catch (_) {
      state = null;
    }
  }

  // --- Quick Action Initializers ---

  Future<void> initSignMyself() async {
    final user = ref.read(currentUserProvider).valueOrNull;
    final newRequest = SignatureRequest(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Sign Myself',
      createdAt: DateTime.now(),
      status: RequestStatus.draft,
      type: SignatureRequestType.selfSign,
      recipients: user != null
          ? [
              Recipient(
                id: 'me',
                name: user.name ?? '',
                email: user.email,
                role: 'signer',
              )
            ]
          : [],
    );
    state = newRequest;
  }

  Future<void> initOneOnOne() async {
    final newRequest = SignatureRequest(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: '1-on-1 Signature',
      createdAt: DateTime.now(),
      status: RequestStatus.draft,
      type: SignatureRequestType.oneOnOne,
      recipients: [], // User can choose to include themselves later
    );
    state = newRequest;
  }

  Future<void> initMultiParty() async {
    final newRequest = SignatureRequest(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Multi-party Signature',
      createdAt: DateTime.now(),
      status: RequestStatus.draft,
      type: SignatureRequestType.multiParty,
    );
    state = newRequest;
  }

  // Legacy initializer (used by standard flow)
  Future<void> initializeNewDraft() async {
    final newRequest = SignatureRequest(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Untitled Document',
      createdAt: DateTime.now(),
      status: RequestStatus.draft,
    );
    state = newRequest;
  }

  // --- Actions to update the draft ---

  Future<void> updateFile(String filePath, String fileName,
      {Uint8List? fileBytes}) async {
    var current = state;
    if (current == null) {
      await initializeNewDraft();
      current = state;
    }
    if (current == null) return; // Should not happen after initialize

    final transientFileNotifier =
        ref.read(transientFileProvider(current.id).notifier);

    if (fileBytes != null) {
      transientFileNotifier.set(fileBytes);
    }

    final updated = current.copyWith(
      filePath: filePath,
      fileBytes: fileBytes,
      title: fileName.isNotEmpty ? fileName : current.title,
      updatedAt: DateTime.now(),
    );

    state = updated;
    await _persist(updated);
  }

  Future<void> updateRecipients(List<Recipient> recipients) async {
    final current = state;
    if (current == null) return;

    final updated = current.copyWith(
      recipients: recipients,
      updatedAt: DateTime.now(),
    );

    state = updated;
    await _persist(updated);
  }

  Future<void> updateFields(List<PlacedField> fields) async {
    final current = state;
    if (current == null) return;

    final updated = current.copyWith(
      fields: fields,
      updatedAt: DateTime.now(),
    );

    state = updated;
    await _persist(updated);
  }

  Future<void> markAsSent() async {
    final current = state;
    if (current == null) return;

    final requestsNotifier = ref.read(requestsProvider.notifier);
    final transientFileNotifier =
        ref.read(transientFileProvider(current.id).notifier);

    // Generate shareable link (mock)
    final signUrl = 'https://digito.app/sign/${current.id}';

    final updated = current.copyWith(
      status: RequestStatus.sent,
      signUrl: signUrl,
      updatedAt: DateTime.now(),
    );

    await requestsNotifier.addOrUpdate(updated);

    // Cleanup transient bytes but keep the draft in memory for the success screen
    // We update the state with the 'sent' version instead of clearing it immediately
    state = updated;
    transientFileNotifier.set(null);
  }

  void clear() {
    state = null;
  }
}
