// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_interaction_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PostLikeAction)
final postLikeActionProvider = PostLikeActionProvider._();

final class PostLikeActionProvider
    extends $AsyncNotifierProvider<PostLikeAction, void> {
  PostLikeActionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'postLikeActionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$postLikeActionHash();

  @$internal
  @override
  PostLikeAction create() => PostLikeAction();
}

String _$postLikeActionHash() => r'e8c0f446e3442b0d0d0fde7167ba82d0b3ab40c5';

abstract class _$PostLikeAction extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(PostBookmarkAction)
final postBookmarkActionProvider = PostBookmarkActionProvider._();

final class PostBookmarkActionProvider
    extends $AsyncNotifierProvider<PostBookmarkAction, void> {
  PostBookmarkActionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'postBookmarkActionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$postBookmarkActionHash();

  @$internal
  @override
  PostBookmarkAction create() => PostBookmarkAction();
}

String _$postBookmarkActionHash() =>
    r'dbef168986c167134478ddb44218ba0d98ded5bb';

abstract class _$PostBookmarkAction extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
