import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/config/app_env.dart';
import '../../../core/session/current_user_provider.dart';
import '../../feed/domain/comment.dart';
import '../../feed/domain/paginated_result.dart';
import '../../feed/domain/post_repository.dart';
import '../../feed/providers/feed_provider.dart';
import '../../feed/providers/post_repository_provider.dart';

part 'comments_provider.g.dart';

@riverpod
class Comments extends _$Comments {
  PostRepository get _repository => ref.read(postRepositoryProvider);

  @override
  FutureOr<CommentListResult> build(String postId) {
    return _repository.getComments(postId, limit: AppEnv.commentsPageSize);
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null) return;
    if (current.isLoadingMore || current.hasReachedMax) return;

    state = AsyncData(
      current.copyWith(isLoadingMore: true, loadMoreFailed: false),
    );

    try {
      final page = await _repository.getComments(
        postId,
        cursor: current.nextCursor,
        limit: AppEnv.commentsPageSize,
      );

      if (!ref.mounted) return;

      final existingIds = current.items.map((comment) => comment.id).toSet();
      final incoming = page.items.where(
        (comment) => !existingIds.contains(comment.id),
      );

      state = AsyncData(
        current.copyWith(
          items: [...current.items, ...incoming],
          nextCursor: () => page.nextCursor,
          hasReachedMax: page.hasReachedMax,
          isLoadingMore: false,
        ),
      );
    } catch (_) {
      if (!ref.mounted) return;
      state = AsyncData(
        current.copyWith(isLoadingMore: false, loadMoreFailed: true),
      );
    }
  }

  void insertLocal(Comment comment) {
    final current = state.value ?? const CommentListResult();
    state = AsyncData(
      current.copyWith(items: [comment, ...current.items]),
    );
  }

  void replaceLocal(String pendingId, Comment comment) {
    final current = state.value;
    if (current == null) return;

    final next = [...current.items];
    final index = next.indexWhere((item) => item.id == pendingId);
    if (index == -1) return;

    next[index] = comment;
    state = AsyncData(current.copyWith(items: next));
  }

  void removeLocal(String commentId) {
    final current = state.value;
    if (current == null) return;

    state = AsyncData(
      current.copyWith(
        items: current.items
            .where((comment) => comment.id != commentId)
            .toList(),
      ),
    );
  }
}

@Riverpod(keepAlive: true)
class AddCommentAction extends _$AddCommentAction {
  @override
  FutureOr<void> build() => null;

  Future<void> submit({required String postId, required String body}) async {
    final trimmed = body.trim();
    if (trimmed.isEmpty) return;

    final viewer = ref.read(currentUserProvider);
    final comments = ref.read(commentsProvider(postId).notifier);
    final feed = ref.read(feedProvider.notifier);

    final pendingId = 'pending-${DateTime.now().microsecondsSinceEpoch}';
    final pending = Comment(
      id: pendingId,
      postId: postId,
      author: viewer,
      body: trimmed,
      createdAt: DateTime.now(),
      isPending: true,
    );

    comments.insertLocal(pending);
    feed.patchPost(postId, (post) => post.withCommentAdded(pending));

    state = const AsyncLoading<void>();

    final result = await AsyncValue.guard(
      () => ref.read(postRepositoryProvider).addComment(postId, trimmed),
    );

    if (!ref.mounted) return;

    switch (result) {
      case AsyncError(:final error, :final stackTrace):
        comments.removeLocal(pendingId);
        feed.patchPost(
          postId,
          (post) => post.copyWith(
            commentCount: (post.commentCount - 1).clamp(0, post.commentCount),
            topComment: () =>
                post.topComment?.id == pendingId ? null : post.topComment,
          ),
        );
        state = AsyncError<void>(error, stackTrace);
      case AsyncData(:final value):
        comments.replaceLocal(pendingId, value);
        feed.patchPost(
          postId,
          (post) => post.topComment?.id == pendingId
              ? post.copyWith(topComment: () => value)
              : post,
        );
        state = const AsyncData<void>(null);
      default:
        state = const AsyncData<void>(null);
    }
  }
}
