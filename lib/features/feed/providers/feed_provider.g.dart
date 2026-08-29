// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Feed)
final feedProvider = FeedProvider._();

final class FeedProvider extends $AsyncNotifierProvider<Feed, PostListResult> {
  FeedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'feedProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$feedHash();

  @$internal
  @override
  Feed create() => Feed();
}

String _$feedHash() => r'97570c872d326f4c5b82f8675ccf3c5857b86d71';

abstract class _$Feed extends $AsyncNotifier<PostListResult> {
  FutureOr<PostListResult> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<PostListResult>, PostListResult>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<PostListResult>, PostListResult>,
              AsyncValue<PostListResult>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
