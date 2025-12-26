// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ProfileState)
const profileStateProvider = ProfileStateProvider._();

final class ProfileStateProvider
    extends $NotifierProvider<ProfileState, AsyncValue<UserProfile?>> {
  const ProfileStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileStateHash();

  @$internal
  @override
  ProfileState create() => ProfileState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<UserProfile?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<UserProfile?>>(value),
    );
  }
}

String _$profileStateHash() => r'19862d1b9fd74b26e81cd1ee0ea5dacd00652deb';

abstract class _$ProfileState extends $Notifier<AsyncValue<UserProfile?>> {
  AsyncValue<UserProfile?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<AsyncValue<UserProfile?>, AsyncValue<UserProfile?>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<UserProfile?>, AsyncValue<UserProfile?>>,
              AsyncValue<UserProfile?>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
