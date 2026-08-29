// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_filter_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PostFilterController)
final postFilterControllerProvider = PostFilterControllerProvider._();

final class PostFilterControllerProvider
    extends $NotifierProvider<PostFilterController, PostFilter> {
  PostFilterControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'postFilterControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$postFilterControllerHash();

  @$internal
  @override
  PostFilterController create() => PostFilterController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PostFilter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PostFilter>(value),
    );
  }
}

String _$postFilterControllerHash() =>
    r'b5d674f8a51bb74a031a3029630be4d91e6c368c';

abstract class _$PostFilterController extends $Notifier<PostFilter> {
  PostFilter build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<PostFilter, PostFilter>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PostFilter, PostFilter>,
              PostFilter,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
