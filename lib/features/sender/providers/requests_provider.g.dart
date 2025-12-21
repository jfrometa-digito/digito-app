// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'requests_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$requestsRepositoryHash() =>
    r'b1da5db66412c17324e966845b62ad8b8e16d157';

/// See also [requestsRepository].
@ProviderFor(requestsRepository)
final requestsRepositoryProvider =
    AutoDisposeProvider<RequestsRepository>.internal(
  requestsRepository,
  name: r'requestsRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$requestsRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RequestsRepositoryRef = AutoDisposeProviderRef<RequestsRepository>;
String _$requestsHash() => r'a199086a473230aaf2db0226059b7c8e7025866b';

/// See also [Requests].
@ProviderFor(Requests)
final requestsProvider =
    AutoDisposeAsyncNotifierProvider<Requests, List<SignatureRequest>>.internal(
  Requests.new,
  name: r'requestsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$requestsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Requests = AutoDisposeAsyncNotifier<List<SignatureRequest>>;
String _$activeDraftIdHash() => r'53a27138185e390fa9f9a4e06b1842c602068c9b';

/// See also [ActiveDraftId].
@ProviderFor(ActiveDraftId)
final activeDraftIdProvider =
    AutoDisposeNotifierProvider<ActiveDraftId, String?>.internal(
  ActiveDraftId.new,
  name: r'activeDraftIdProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activeDraftIdHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ActiveDraftId = AutoDisposeNotifier<String?>;
String _$transientFileHash() => r'd35036125249fd62db9e5558164f91a619ec9b3f';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$TransientFile
    extends BuildlessAutoDisposeNotifier<Uint8List?> {
  late final String requestId;

  Uint8List? build(
    String requestId,
  );
}

/// See also [TransientFile].
@ProviderFor(TransientFile)
const transientFileProvider = TransientFileFamily();

/// See also [TransientFile].
class TransientFileFamily extends Family<Uint8List?> {
  /// See also [TransientFile].
  const TransientFileFamily();

  /// See also [TransientFile].
  TransientFileProvider call(
    String requestId,
  ) {
    return TransientFileProvider(
      requestId,
    );
  }

  @override
  TransientFileProvider getProviderOverride(
    covariant TransientFileProvider provider,
  ) {
    return call(
      provider.requestId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'transientFileProvider';
}

/// See also [TransientFile].
class TransientFileProvider
    extends AutoDisposeNotifierProviderImpl<TransientFile, Uint8List?> {
  /// See also [TransientFile].
  TransientFileProvider(
    String requestId,
  ) : this._internal(
          () => TransientFile()..requestId = requestId,
          from: transientFileProvider,
          name: r'transientFileProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$transientFileHash,
          dependencies: TransientFileFamily._dependencies,
          allTransitiveDependencies:
              TransientFileFamily._allTransitiveDependencies,
          requestId: requestId,
        );

  TransientFileProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.requestId,
  }) : super.internal();

  final String requestId;

  @override
  Uint8List? runNotifierBuild(
    covariant TransientFile notifier,
  ) {
    return notifier.build(
      requestId,
    );
  }

  @override
  Override overrideWith(TransientFile Function() create) {
    return ProviderOverride(
      origin: this,
      override: TransientFileProvider._internal(
        () => create()..requestId = requestId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        requestId: requestId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<TransientFile, Uint8List?>
      createElement() {
    return _TransientFileProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TransientFileProvider && other.requestId == requestId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, requestId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TransientFileRef on AutoDisposeNotifierProviderRef<Uint8List?> {
  /// The parameter `requestId` of this provider.
  String get requestId;
}

class _TransientFileProviderElement
    extends AutoDisposeNotifierProviderElement<TransientFile, Uint8List?>
    with TransientFileRef {
  _TransientFileProviderElement(super.provider);

  @override
  String get requestId => (origin as TransientFileProvider).requestId;
}

String _$activeDraftHash() => r'2eb8da2127faf3bcc902037f4f164787a19952a3';

/// See also [ActiveDraft].
@ProviderFor(ActiveDraft)
final activeDraftProvider =
    AutoDisposeNotifierProvider<ActiveDraft, SignatureRequest?>.internal(
  ActiveDraft.new,
  name: r'activeDraftProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$activeDraftHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ActiveDraft = AutoDisposeNotifier<SignatureRequest?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
