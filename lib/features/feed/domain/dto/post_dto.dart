import 'package:json_annotation/json_annotation.dart';

import '../post.dart';
import '../post_category.dart';
import '../transaction_type.dart';
import 'author_dto.dart';
import 'comment_dto.dart';
import 'media_item_dto.dart';

part 'post_dto.g.dart';

@JsonSerializable(createToJson: false)
class PostDto {
  const PostDto({
    required this.id,
    required this.author,
    required this.body,
    required this.createdAt,
    this.category,
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
  });

  factory PostDto.fromJson(Map<String, dynamic> json) =>
      _$PostDtoFromJson(json);

  final String id;
  final AuthorDto author;
  final String body;
  final DateTime createdAt;
  final String? category;
  final String? location;
  final String? transactionType;
  final List<MediaItemDto> media;
  final int likeCount;
  final int commentCount;
  final int viewCount;
  final int bookmarkCount;
  final bool isLiked;
  final bool isBookmarked;
  final List<AuthorDto> likedBy;
  final CommentDto? topComment;

  Post toEntity() => Post(
    id: id,
    author: author.toEntity(),
    category: PostCategory.fromWire(category) ?? PostCategory.general,
    body: body,
    createdAt: createdAt.toLocal(),
    location: location,
    transactionType: TransactionType.fromWire(transactionType),
    media: media.map((item) => item.toEntity()).toList(),
    likeCount: likeCount,
    commentCount: commentCount,
    viewCount: viewCount,
    bookmarkCount: bookmarkCount,
    isLiked: isLiked,
    isBookmarked: isBookmarked,
    likedBy: likedBy.map((item) => item.toEntity()).toList(),
    topComment: topComment?.toEntity(),
  );
}

@JsonSerializable(createToJson: false)
class PostPageDto {
  const PostPageDto({
    this.data = const [],
    this.nextCursor,
    this.hasMore = false,
  });

  factory PostPageDto.fromJson(Map<String, dynamic> json) =>
      _$PostPageDtoFromJson(json);

  final List<PostDto> data;
  final String? nextCursor;
  final bool hasMore;
}

@JsonSerializable(createToJson: false)
class PostLikeResponseDto {
  const PostLikeResponseDto({required this.isLiked, required this.likeCount});

  factory PostLikeResponseDto.fromJson(Map<String, dynamic> json) =>
      _$PostLikeResponseDtoFromJson(json);

  final bool isLiked;
  final int likeCount;
}

@JsonSerializable(createToJson: false)
class PostBookmarkResponseDto {
  const PostBookmarkResponseDto({
    required this.isBookmarked,
    required this.bookmarkCount,
  });

  factory PostBookmarkResponseDto.fromJson(Map<String, dynamic> json) =>
      _$PostBookmarkResponseDtoFromJson(json);

  final bool isBookmarked;
  final int bookmarkCount;
}
