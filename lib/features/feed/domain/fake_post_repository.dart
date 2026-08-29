import '../../../core/config/app_env.dart';
import '../../../core/error/app_exception.dart';
import 'author.dart';
import 'comment.dart';
import 'fake_feed_seed.dart';
import 'media_item.dart';
import 'paginated_result.dart';
import 'post.dart';
import 'post_draft.dart';
import 'post_filter.dart';
import 'post_repository.dart';

class FakeFailureSwitches {
  FakeFailureSwitches({
    this.feed = false,
    this.like = false,
    this.bookmark = false,
    this.comments = false,
    this.addComment = false,
    this.createPost = false,
  });

  bool feed;
  bool like;
  bool bookmark;
  bool comments;
  bool addComment;
  bool createPost;
}

class FakePostRepository implements PostRepository {
  FakePostRepository({
    required this.currentUser,
    FakeFailureSwitches? failures,
    this.latency = const Duration(milliseconds: 450),
    DateTime? now,
  }) : failures = failures ?? FakeFailureSwitches(),
       _posts = FakeFeedSeed.posts(now: now),
       _comments = FakeFeedSeed.comments(now: now);

  final Author currentUser;
  final FakeFailureSwitches failures;
  final Duration latency;

  final List<Post> _posts;
  final Map<String, List<Comment>> _comments;

  int _idSeed = 0;

  List<Post> get posts => List.unmodifiable(_posts);

  @override
  Future<PostListResult> getPosts({
    PostFilter filter = const PostFilter(),
    String? cursor,
    int limit = AppEnv.feedPageSize,
  }) async {
    await _wait();
    if (failures.feed) {
      throw const ApiException(statusCode: 500, endpoint: '/posts');
    }

    final matching = _posts.where(filter.matches).toList();
    final start = _indexAfterCursor(matching, cursor);
    if (start >= matching.length) {
      return const PostListResult(hasReachedMax: true);
    }

    final end = (start + limit).clamp(0, matching.length);
    final page = matching.sublist(start, end);
    final reachedMax = end >= matching.length;

    return PostListResult(
      items: page,
      nextCursor: reachedMax ? null : page.last.id,
      hasReachedMax: reachedMax,
    );
  }

  @override
  Future<PostLikeResult> toggleLike(String postId) async {
    await _wait(const Duration(milliseconds: 260));
    if (failures.like) {
      throw const ApiException(statusCode: 500, endpoint: '/posts/:id/like');
    }

    final index = _posts.indexWhere((post) => post.id == postId);
    if (index == -1) {
      throw const ApiException(statusCode: 404, endpoint: '/posts/:id/like');
    }

    final current = _posts[index];
    final nextLiked = !current.isLiked;
    final nextCount = (current.likeCount + (nextLiked ? 1 : -1))
        .clamp(0, 1 << 31);
    final nextLikedBy = _applyLikedBy(current.likedBy, liked: nextLiked);

    _posts[index] = current.copyWith(
      isLiked: nextLiked,
      likeCount: nextCount,
      likedBy: nextLikedBy,
    );

    return PostLikeResult(isLiked: nextLiked, likeCount: nextCount);
  }

  @override
  Future<PostBookmarkResult> toggleBookmark(String postId) async {
    await _wait(const Duration(milliseconds: 260));
    if (failures.bookmark) {
      throw const ApiException(
        statusCode: 500,
        endpoint: '/posts/:id/bookmark',
      );
    }

    final index = _posts.indexWhere((post) => post.id == postId);
    if (index == -1) {
      throw const ApiException(
        statusCode: 404,
        endpoint: '/posts/:id/bookmark',
      );
    }

    final current = _posts[index];
    final next = current.withBookmarkToggled();
    _posts[index] = next;

    return PostBookmarkResult(
      isBookmarked: next.isBookmarked,
      bookmarkCount: next.bookmarkCount,
    );
  }

  @override
  Future<CommentListResult> getComments(
    String postId, {
    String? cursor,
    int limit = AppEnv.commentsPageSize,
  }) async {
    await _wait();
    if (failures.comments) {
      throw const ApiException(
        statusCode: 500,
        endpoint: '/posts/:id/comments',
      );
    }

    final all = _comments[postId] ?? const <Comment>[];
    final start = _indexAfterCursor(all, cursor, idOf: (c) => c.id);
    if (start >= all.length) {
      return const CommentListResult(hasReachedMax: true);
    }

    final end = (start + limit).clamp(0, all.length);
    final page = all.sublist(start, end);
    final reachedMax = end >= all.length;

    return CommentListResult(
      items: page,
      nextCursor: reachedMax ? null : page.last.id,
      hasReachedMax: reachedMax,
    );
  }

  @override
  Future<Comment> addComment(String postId, String body) async {
    await _wait(const Duration(milliseconds: 320));
    if (failures.addComment) {
      throw const ApiException(
        statusCode: 500,
        endpoint: '/posts/:id/comments',
      );
    }

    final comment = Comment(
      id: 'comment-$postId-new-${_nextId()}',
      postId: postId,
      author: currentUser,
      body: body.trim(),
      createdAt: DateTime.now(),
    );

    _comments.putIfAbsent(postId, () => <Comment>[]).insert(0, comment);

    final index = _posts.indexWhere((post) => post.id == postId);
    if (index != -1) {
      final current = _posts[index];
      _posts[index] = current.copyWith(
        commentCount: current.commentCount + 1,
        topComment: () => current.topComment ?? comment,
      );
    }

    return comment;
  }

  @override
  Future<Post> createPost(PostDraft draft) async {
    await _wait(const Duration(milliseconds: 520));
    if (failures.createPost) {
      throw const ApiException(statusCode: 500, endpoint: '/posts');
    }

    final id = 'post-new-${_nextId()}';
    final post = Post(
      id: id,
      author: currentUser,
      category: draft.category,
      body: draft.trimmedBody,
      createdAt: DateTime.now(),
      location: draft.location,
      transactionType: draft.transactionType,
      media: draft.media
          .map(
            (item) => MediaItem(
              id: '$id-${item.id}',
              url: item.url,
              kind: item.kind,
              aspectRatio: item.aspectRatio,
              localPath: item.localPath,
            ),
          )
          .toList(),
    );

    _posts.insert(0, post);
    return post;
  }

  List<Author> _applyLikedBy(List<Author> current, {required bool liked}) {
    final next = [...current];
    next.removeWhere((author) => author.id == currentUser.id);
    if (liked) next.insert(0, currentUser);
    return next;
  }

  int _indexAfterCursor<T>(
    List<T> items,
    String? cursor, {
    String Function(T item)? idOf,
  }) {
    if (cursor == null) return 0;
    final resolve = idOf ?? (item) => (item as Post).id;
    final index = items.indexWhere((item) => resolve(item) == cursor);
    return index == -1 ? items.length : index + 1;
  }

  int _nextId() => ++_idSeed;

  Future<void> _wait([Duration? override]) =>
      Future<void>.delayed(override ?? latency);
}
