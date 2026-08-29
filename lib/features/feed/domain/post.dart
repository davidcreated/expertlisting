import 'package:equatable/equatable.dart';

import 'author.dart';
import 'comment.dart';
import 'media_item.dart';
import 'post_category.dart';
import 'transaction_type.dart';

class Post extends Equatable {
  const Post({
    required this.id,
    required this.author,
    required this.category,
    required this.body,
    required this.createdAt,
    this.location,
    this.transactionType,
    this.media = const [],
    this.likeCount = 0,
    this.commentCount = 0,
    this.viewCount = 0,
    this.bookmarkCount = 0,
    this.isLiked = false,
    this.isBookmarked = false,
    this.likedBy = const [],
    this.topComment,
    this.isPending = false,
  });

  final String id;
  final Author author;
  final PostCategory category;
  final String body;
  final DateTime createdAt;
  final String? location;
  final TransactionType? transactionType;
  final List<MediaItem> media;
  final int likeCount;
  final int commentCount;
  final int viewCount;
  final int bookmarkCount;
  final bool isLiked;
  final bool isBookmarked;
  final List<Author> likedBy;
  final Comment? topComment;
  final bool isPending;

  bool get hasMedia => media.isNotEmpty;

  bool get hasLocation => location != null && location!.trim().isNotEmpty;

  bool get hasMetaRow => hasLocation || transactionType != null;

  bool get hasViews => viewCount > 0;

  bool get hasBookmarks => bookmarkCount > 0;

  bool get hasLikes => likeCount > 0;

  bool get hasComments => commentCount > 0;

  bool get showCommentPreview => topComment != null;

  int get viewAllCommentsCount =>
      commentCount - (topComment != null ? 1 : 0);

  bool get showViewAllComments => viewAllCommentsCount > 0;

  bool get showLikedBy => hasLikes && likedBy.isNotEmpty;

  String? get likedByLeader => showLikedBy ? likedBy.first.username : null;

  int get likedByOthers => showLikedBy ? likeCount - 1 : 0;

  String? get likedByLabel {
    if (!showLikedBy) return null;
    final others = likedByOthers;
    if (others <= 0) return 'Liked by $likedByLeader';
    return 'Liked by $likedByLeader and $others '
        '${others == 1 ? 'other' : 'others'}';
  }

  Post withLikeToggled(Author viewer) {
    final nextLiked = !isLiked;
    return withLikeState(
      isLiked: nextLiked,
      likeCount: nextLiked ? likeCount + 1 : (likeCount - 1).clamp(0, likeCount),
      viewer: viewer,
    );
  }

  Post withLikeState({
    required bool isLiked,
    required int likeCount,
    required Author viewer,
  }) {
    final nextLikedBy = likedBy
        .where((author) => author.id != viewer.id)
        .toList();
    if (isLiked) nextLikedBy.insert(0, viewer);

    return copyWith(
      isLiked: isLiked,
      likeCount: likeCount < 0 ? 0 : likeCount,
      likedBy: nextLikedBy,
    );
  }

  Post withBookmarkToggled() {
    final nextBookmarked = !isBookmarked;
    return copyWith(
      isBookmarked: nextBookmarked,
      bookmarkCount: nextBookmarked
          ? bookmarkCount + 1
          : (bookmarkCount - 1).clamp(0, bookmarkCount),
    );
  }

  Post withCommentAdded(Comment comment) {
    return copyWith(
      commentCount: commentCount + 1,
      topComment: () => topComment ?? comment,
    );
  }

  Post copyWith({
    String? id,
    Author? author,
    PostCategory? category,
    String? body,
    DateTime? createdAt,
    String? Function()? location,
    TransactionType? Function()? transactionType,
    List<MediaItem>? media,
    int? likeCount,
    int? commentCount,
    int? viewCount,
    int? bookmarkCount,
    bool? isLiked,
    bool? isBookmarked,
    List<Author>? likedBy,
    Comment? Function()? topComment,
    bool? isPending,
  }) {
    return Post(
      id: id ?? this.id,
      author: author ?? this.author,
      category: category ?? this.category,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      location: location != null ? location() : this.location,
      transactionType: transactionType != null
          ? transactionType()
          : this.transactionType,
      media: media ?? this.media,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      viewCount: viewCount ?? this.viewCount,
      bookmarkCount: bookmarkCount ?? this.bookmarkCount,
      isLiked: isLiked ?? this.isLiked,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      likedBy: likedBy ?? this.likedBy,
      topComment: topComment != null ? topComment() : this.topComment,
      isPending: isPending ?? this.isPending,
    );
  }

  @override
  List<Object?> get props => [
    id,
    author,
    category,
    body,
    createdAt,
    location,
    transactionType,
    media,
    likeCount,
    commentCount,
    viewCount,
    bookmarkCount,
    isLiked,
    isBookmarked,
    likedBy,
    topComment,
    isPending,
  ];
}
