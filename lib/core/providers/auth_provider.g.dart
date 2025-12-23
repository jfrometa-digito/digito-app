// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for the authentication service

@ProviderFor(authService)
const authServiceProvider = AuthServiceProvider._();

/// Provider for the authentication service

final class AuthServiceProvider
    extends $FunctionalProvider<AuthService, AuthService, AuthService>
    with $Provider<AuthService> {
  /// Provider for the authentication service
  const AuthServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authServiceHash();

  @$internal
  @override
  $ProviderElement<AuthService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthService create(Ref ref) {
    return authService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthService>(value),
    );
  }
}

String _$authServiceHash() => r'2dacf20cec62ded7d304e5c144c83ff7252da9a0';

/// Provider for the current authenticated user

@ProviderFor(currentUser)
const currentUserProvider = CurrentUserProvider._();

/// Provider for the current authenticated user

final class CurrentUserProvider
    extends
        $FunctionalProvider<
          AsyncValue<AuthUser?>,
          AuthUser?,
          FutureOr<AuthUser?>
        >
    with $FutureModifier<AuthUser?>, $FutureProvider<AuthUser?> {
  /// Provider for the current authenticated user
  const CurrentUserProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentUserProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentUserHash();

  @$internal
  @override
  $FutureProviderElement<AuthUser?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<AuthUser?> create(Ref ref) {
    return currentUser(ref);
  }
}

String _$currentUserHash() => r'c7c8646483d34d1cc4e5c7416f25c1d12f9f4754';

/// Provider for authentication status

@ProviderFor(isAuthenticated)
const isAuthenticatedProvider = IsAuthenticatedProvider._();

/// Provider for authentication status

final class IsAuthenticatedProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Provider for authentication status
  const IsAuthenticatedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isAuthenticatedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isAuthenticatedHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return isAuthenticated(ref);
  }
}

String _$isAuthenticatedHash() => r'7bc4de11d0753ca84665ea9892c3484460651968';
