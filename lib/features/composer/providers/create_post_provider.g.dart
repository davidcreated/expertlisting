// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_post_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PostDraftController)
final postDraftControllerProvider = PostDraftControllerProvider._();

final class PostDraftControllerProvider
    extends $NotifierProvider<PostDraftController, PostDraft> {
  PostDraftControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'postDraftControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$postDraftControllerHash();

  @$internal
  @override
  PostDraftController create() => PostDraftController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PostDraft value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PostDraft>(value),
    );
  }
}

String _$postDraftControllerHash() =>
    r'04fe30406487c32ff2591c78bd10d5bc4bf2078b';

abstract class _$PostDraftController extends $Notifier<PostDraft> {
  PostDraft build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<PostDraft, PostDraft>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PostDraft, PostDraft>,
              PostDraft,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(CreatePostAction)
final createPostActionProvider = CreatePostActionProvider._();

final class CreatePostActionProvider
    extends $AsyncNotifierProvider<CreatePostAction, void> {
  CreatePostActionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createPostActionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createPostActionHash();

  @$internal
  @override
  CreatePostAction create() => CreatePostAction();
}

String _$createPostActionHash() => r'2e63971ef478fc44d2bc6e7976f856146172e533';

abstract class _$CreatePostAction extends $AsyncNotifier<void> {
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
