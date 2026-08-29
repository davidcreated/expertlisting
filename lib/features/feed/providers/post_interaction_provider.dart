import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/session/current_user_provider.dart';
import '../domain/post.dart';
import 'feed_provider.dart';
import 'post_repository_provider.dart';

part 'post_interaction_provider.g.dart';

@Riverpod(keepAlive: true)
class PostLikeAction extends _$PostLikeAction {
  @override
  FutureOr<void> build() => null;

  Future<void> toggle(Post post) async {
    final viewer = ref.read(currentUserProvider);
    final feed = ref.read(feedProvider.notifier);

    feed.patchPost(post.id, (current) => current.withLikeToggled(viewer));

    state = const AsyncLoading<void>();

    final result = await AsyncValue.guard(
      () => ref.read(postRepositoryProvider).toggleLike(post.id),
    );

    if (!ref.mounted) return;

    switch (result) {
      case AsyncError(:final error, :final stackTrace):
        feed.patchPost(
          post.id,
          (current) => current.withLikeState(
            isLiked: post.isLiked,
            likeCount: post.likeCount,
            viewer: viewer,
          ),
        );
        state = AsyncError<void>(error, stackTrace);
      case AsyncData(:final value):
        feed.patchPost(
          post.id,
          (current) => current.withLikeState(
            isLiked: value.isLiked,
            likeCount: value.likeCount,
            viewer: viewer,
          ),
        );
        state = const AsyncData<void>(null);
      default:
        state = const AsyncData<void>(null);
    }
  }
}

@Riverpod(keepAlive: true)
class PostBookmarkAction extends _$PostBookmarkAction {
  @override
  FutureOr<void> build() => null;

  Future<void> toggle(Post post) async {
    final feed = ref.read(feedProvider.notifier);

    feed.patchPost(post.id, (current) => current.withBookmarkToggled());

    state = const AsyncLoading<void>();

    final result = await AsyncValue.guard(
      () => ref.read(postRepositoryProvider).toggleBookmark(post.id),
    );

    if (!ref.mounted) return;

    switch (result) {
      case AsyncError(:final error, :final stackTrace):
        feed.patchPost(
          post.id,
          (current) => current.copyWith(
            isBookmarked: post.isBookmarked,
            bookmarkCount: post.bookmarkCount,
          ),
        );
        state = AsyncError<void>(error, stackTrace);
      case AsyncData(:final value):
        feed.patchPost(
          post.id,
          (current) => current.copyWith(
            isBookmarked: value.isBookmarked,
            bookmarkCount: value.bookmarkCount,
          ),
        );
        state = const AsyncData<void>(null);
      default:
        state = const AsyncData<void>(null);
    }
  }
}
