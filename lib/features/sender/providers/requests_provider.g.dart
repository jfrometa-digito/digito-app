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
String _$activeDraftHash() => r'9599aed366c95858d8cd7b0d17a5df9734b9307f';

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
