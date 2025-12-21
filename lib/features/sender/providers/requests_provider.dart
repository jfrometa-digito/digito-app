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
    final id = ref.watch(activeDraftIdProvider);
    final requestsAsync = ref.watch(requestsProvider);

    print(
        '[ActiveDraft.build] id=$id, requestsAsync.hasValue=${requestsAsync.hasValue}');

    if (id == null) {
      print('[ActiveDraft.build] returning null: id is null');
      return null;
    }

    // Use valueOrNull to keep showing data while reloading (e.g., during save)
    final requests = requestsAsync.valueOrNull;
    if (requests == null) {
      print('[ActiveDraft.build] returning null: requests is null');
      return null;
    }

    try {
      final request = requests.firstWhere((r) => r.id == id);
      print(
          '[ActiveDraft.build] found request: filePath="${request.filePath}", hasBytes=${request.fileBytes != null}, bytesLength=${request.fileBytes?.length}');

      // Merge transient bytes if available (mostly for Web)
      final transientBytes = ref.watch(transientFileProvider(id));
      print('[ActiveDraft.build] transientBytes: ${transientBytes?.length}');
      if (transientBytes != null) {
        final merged = request.copyWith(fileBytes: transientBytes);
        print(
            '[ActiveDraft.build] returning merged request with bytes: ${merged.fileBytes?.length}');
        return merged;
      }

      print('[ActiveDraft.build] returning request as-is');
      return request;
    } catch (_) {
      print('[ActiveDraft.build] returning null: request not found in list');
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

    // Capture notifiers before async operations
    final requestsNotifier = ref.read(requestsProvider.notifier);
    final draftIdNotifier = ref.read(activeDraftIdProvider.notifier);

    await requestsNotifier.addOrUpdate(newRequest);
    draftIdNotifier.set(newRequest.id);
  }

  Future<void> updateFile(String filePath, String fileName,
      {Uint8List? fileBytes}) async {
    final current = state;
    if (current == null) return;

    // CRITICAL: Capture these BEFORE any async operations to avoid Riverpod errors
    final requestsNotifier = ref.read(requestsProvider.notifier);
    final transientFileNotifier =
        ref.read(transientFileProvider(current.id).notifier);

    // Save bytes to transient store first
    if (fileBytes != null) {
      transientFileNotifier.set(fileBytes);
    }

    final updated = current.copyWith(
      filePath: filePath,
      // fileBytes in the model is transient, so we don't strictly need to set it here
      // for the repo save, but we do it for consistency before the save strips it.
      fileBytes: fileBytes,
      title: fileName, // Use filename as default title
      updatedAt: DateTime.now(),
    );
    await requestsNotifier.addOrUpdate(updated);
  }

  Future<void> updateRecipients(List<Recipient> recipients) async {
    final current = state;
    if (current == null) return;

    final requestsNotifier = ref.read(requestsProvider.notifier);
    final updated = current.copyWith(
      recipients: recipients,
      updatedAt: DateTime.now(),
    );
    await requestsNotifier.addOrUpdate(updated);
  }

  Future<void> updateFields(List<PlacedField> fields) async {
    final current = state;
    if (current == null) return;

    final requestsNotifier = ref.read(requestsProvider.notifier);
    final updated = current.copyWith(
      fields: fields,
      updatedAt: DateTime.now(),
    );
    await requestsNotifier.addOrUpdate(updated);
  }

  Future<void> markAsSent() async {
    final current = state;
    if (current == null) return;

    // Capture notifiers before async operations
    final requestsNotifier = ref.read(requestsProvider.notifier);
    final transientFileNotifier =
        ref.read(transientFileProvider(current.id).notifier);
    final draftIdNotifier = ref.read(activeDraftIdProvider.notifier);

    final updated = current.copyWith(
      status: RequestStatus.sent,
      updatedAt: DateTime.now(),
    );
    await requestsNotifier.addOrUpdate(updated);

    // Cleanup transient bytes
    transientFileNotifier.set(null);

    // Clear active draft after sending
    draftIdNotifier.set(null);
  }
}
