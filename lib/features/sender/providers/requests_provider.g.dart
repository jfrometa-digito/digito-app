// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'requests_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(requestsRepository)
const requestsRepositoryProvider = RequestsRepositoryProvider._();

final class RequestsRepositoryProvider
    extends
        $FunctionalProvider<
          RequestsRepository,
          RequestsRepository,
          RequestsRepository
        >
    with $Provider<RequestsRepository> {
  const RequestsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'requestsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$requestsRepositoryHash();

  @$internal
  @override
  $ProviderElement<RequestsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RequestsRepository create(Ref ref) {
    return requestsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RequestsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RequestsRepository>(value),
    );
  }
}

String _$requestsRepositoryHash() =>
    r'0b510811a342afee4aced4c13a132a8325c859a1';

@ProviderFor(Requests)
const requestsProvider = RequestsProvider._();

final class RequestsProvider
    extends $AsyncNotifierProvider<Requests, List<SignatureRequest>> {
  const RequestsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'requestsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$requestsHash();

  @$internal
  @override
  Requests create() => Requests();
}

String _$requestsHash() => r'17493033d085e23609de22e5cb698d6f7b15426d';

abstract class _$Requests extends $AsyncNotifier<List<SignatureRequest>> {
  FutureOr<List<SignatureRequest>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<AsyncValue<List<SignatureRequest>>, List<SignatureRequest>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<SignatureRequest>>,
                List<SignatureRequest>
              >,
              AsyncValue<List<SignatureRequest>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(ActiveDraftId)
const activeDraftIdProvider = ActiveDraftIdProvider._();

final class ActiveDraftIdProvider
    extends $NotifierProvider<ActiveDraftId, String?> {
  const ActiveDraftIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeDraftIdProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeDraftIdHash();

  @$internal
  @override
  ActiveDraftId create() => ActiveDraftId();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$activeDraftIdHash() => r'53a27138185e390fa9f9a4e06b1842c602068c9b';

abstract class _$ActiveDraftId extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(TransientFile)
const transientFileProvider = TransientFileFamily._();

final class TransientFileProvider
    extends $NotifierProvider<TransientFile, Uint8List?> {
  const TransientFileProvider._({
    required TransientFileFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'transientFileProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$transientFileHash();

  @override
  String toString() {
    return r'transientFileProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  TransientFile create() => TransientFile();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Uint8List? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Uint8List?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TransientFileProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$transientFileHash() => r'd35036125249fd62db9e5558164f91a619ec9b3f';

final class TransientFileFamily extends $Family
    with
        $ClassFamilyOverride<
          TransientFile,
          Uint8List?,
          Uint8List?,
          Uint8List?,
          String
        > {
  const TransientFileFamily._()
    : super(
        retry: null,
        name: r'transientFileProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TransientFileProvider call(String requestId) =>
      TransientFileProvider._(argument: requestId, from: this);

  @override
  String toString() => r'transientFileProvider';
}

abstract class _$TransientFile extends $Notifier<Uint8List?> {
  late final _$args = ref.$arg as String;
  String get requestId => _$args;

  Uint8List? build(String requestId);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<Uint8List?, Uint8List?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Uint8List?, Uint8List?>,
              Uint8List?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(ActiveDraft)
const activeDraftProvider = ActiveDraftProvider._();

final class ActiveDraftProvider
    extends $NotifierProvider<ActiveDraft, SignatureRequest?> {
  const ActiveDraftProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeDraftProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeDraftHash();

  @$internal
  @override
  ActiveDraft create() => ActiveDraft();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SignatureRequest? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SignatureRequest?>(value),
    );
  }
}

String _$activeDraftHash() => r'de05a7ec554760ea2756c6d569bd09b97327984f';

abstract class _$ActiveDraft extends $Notifier<SignatureRequest?> {
  SignatureRequest? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<SignatureRequest?, SignatureRequest?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SignatureRequest?, SignatureRequest?>,
              SignatureRequest?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
