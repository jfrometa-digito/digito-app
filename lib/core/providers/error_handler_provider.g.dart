// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'error_handler_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for the error handler service

@ProviderFor(errorHandler)
const errorHandlerProvider = ErrorHandlerProvider._();

/// Provider for the error handler service

final class ErrorHandlerProvider
    extends
        $FunctionalProvider<
          ErrorHandlerService,
          ErrorHandlerService,
          ErrorHandlerService
        >
    with $Provider<ErrorHandlerService> {
  /// Provider for the error handler service
  const ErrorHandlerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'errorHandlerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$errorHandlerHash();

  @$internal
  @override
  $ProviderElement<ErrorHandlerService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ErrorHandlerService create(Ref ref) {
    return errorHandler(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ErrorHandlerService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ErrorHandlerService>(value),
    );
  }
}

String _$errorHandlerHash() => r'd68f4126b287dd95f31ad4a9b3bb17904ee66967';
