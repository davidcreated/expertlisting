import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/config/app_env.dart';
import '../domain/paginated_result.dart';
import '../domain/post.dart';
import '../domain/post_repository.dart';
import 'post_filter_provider.dart';
import 'post_repository_provider.dart';

part 'feed_provider.g.dart';

@Riverpod(keepAlive: true)
class Feed extends _$Feed {
  PostRepository get _repository => ref.read(postRepositoryProvider);

  @override
  FutureOr<PostListResult> build() {
    final filter = ref.watch(postFilterControllerProvider);
    return _repository.getPosts(filter: filter, limit: AppEnv.feedPageSize);
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null) return;
    if (current.isLoadingMore || current.hasReachedMax) return;

    state = AsyncData(
      current.copyWith(isLoadingMore: true, loadMoreFailed: false),
    );

    try {
      final filter = ref.read(postFilterControllerProvider);
      final page = await _repository.getPosts(
        filter: filter,
        cursor: current.nextCursor,
        limit: AppEnv.feedPageSize,
      );

      if (!ref.mounted) return;

      final existingIds = current.items.map((post) => post.id).toSet();
      final incoming = page.items.where(
        (post) => !existingIds.contains(post.id),
      );

      state = AsyncData(
        current.copyWith(
          items: [...current.items, ...incoming],
          nextCursor: () => page.nextCursor,
          hasReachedMax: page.hasReachedMax,
          isLoadingMore: false,
          loadMoreFailed: false,
        ),
      );
    } catch (_) {
      if (!ref.mounted) return;
      state = AsyncData(
        current.copyWith(isLoadingMore: false, loadMoreFailed: true),
      );
    }
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }

  void patchPost(String postId, Post Function(Post post) update) {
    final current = state.value;
    if (current == null) return;

    final index = current.items.indexWhere((post) => post.id == postId);
    if (index == -1) return;

    final next = [...current.items];
    next[index] = update(next[index]);
    state = AsyncData(current.copyWith(items: next));
  }

  void prependPost(Post post) {
    final current = state.value;
    if (current == null) {
      state = AsyncData(PostListResult(items: [post], hasReachedMax: false));
      return;
    }
    state = AsyncData(current.copyWith(items: [post, ...current.items]));
  }
}
