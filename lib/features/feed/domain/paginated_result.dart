import 'package:equatable/equatable.dart';

import 'comment.dart';
import 'post.dart';

class PostListResult extends Equatable {
  const PostListResult({
    this.items = const [],
    this.nextCursor,
    this.hasReachedMax = true,
    this.isLoadingMore = false,
    this.loadMoreFailed = false,
  });

  final List<Post> items;
  final String? nextCursor;
  final bool hasReachedMax;
  final bool isLoadingMore;
  final bool loadMoreFailed;

  bool get isEmpty => items.isEmpty;

  PostListResult copyWith({
    List<Post>? items,
    String? Function()? nextCursor,
    bool? hasReachedMax,
    bool? isLoadingMore,
    bool? loadMoreFailed,
  }) {
    return PostListResult(
      items: items ?? this.items,
      nextCursor: nextCursor != null ? nextCursor() : this.nextCursor,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadMoreFailed: loadMoreFailed ?? this.loadMoreFailed,
    );
  }

  @override
  List<Object?> get props => [
    items,
    nextCursor,
    hasReachedMax,
    isLoadingMore,
    loadMoreFailed,
  ];
}

class CommentListResult extends Equatable {
  const CommentListResult({
    this.items = const [],
    this.nextCursor,
    this.hasReachedMax = true,
    this.isLoadingMore = false,
    this.loadMoreFailed = false,
  });

  final List<Comment> items;
  final String? nextCursor;
  final bool hasReachedMax;
  final bool isLoadingMore;
  final bool loadMoreFailed;

  bool get isEmpty => items.isEmpty;

  CommentListResult copyWith({
    List<Comment>? items,
    String? Function()? nextCursor,
    bool? hasReachedMax,
    bool? isLoadingMore,
    bool? loadMoreFailed,
  }) {
    return CommentListResult(
      items: items ?? this.items,
      nextCursor: nextCursor != null ? nextCursor() : this.nextCursor,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadMoreFailed: loadMoreFailed ?? this.loadMoreFailed,
    );
  }

  @override
  List<Object?> get props => [
    items,
    nextCursor,
    hasReachedMax,
    isLoadingMore,
    loadMoreFailed,
  ];
}

class PostLikeResult extends Equatable {
  const PostLikeResult({required this.isLiked, required this.likeCount});

  final bool isLiked;
  final int likeCount;

  @override
  List<Object?> get props => [isLiked, likeCount];
}

class PostBookmarkResult extends Equatable {
  const PostBookmarkResult({
    required this.isBookmarked,
    required this.bookmarkCount,
  });

  final bool isBookmarked;
  final int bookmarkCount;

  @override
  List<Object?> get props => [isBookmarked, bookmarkCount];
}
