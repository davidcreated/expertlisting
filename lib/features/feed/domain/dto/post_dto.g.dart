// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostDto _$PostDtoFromJson(Map<String, dynamic> json) => PostDto(
  id: json['id'] as String,
  author: AuthorDto.fromJson(json['author'] as Map<String, dynamic>),
  body: json['body'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  category: json['category'] as String?,
  location: json['location'] as String?,
  transactionType: json['transactionType'] as String?,
  media:
      (json['media'] as List<dynamic>?)
          ?.map((e) => MediaItemDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
  commentCount: (json['commentCount'] as num?)?.toInt() ?? 0,
  viewCount: (json['viewCount'] as num?)?.toInt() ?? 0,
  bookmarkCount: (json['bookmarkCount'] as num?)?.toInt() ?? 0,
  isLiked: json['isLiked'] as bool? ?? false,
  isBookmarked: json['isBookmarked'] as bool? ?? false,
  likedBy:
      (json['likedBy'] as List<dynamic>?)
          ?.map((e) => AuthorDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  topComment: json['topComment'] == null
      ? null
      : CommentDto.fromJson(json['topComment'] as Map<String, dynamic>),
);

PostPageDto _$PostPageDtoFromJson(Map<String, dynamic> json) => PostPageDto(
  data:
      (json['data'] as List<dynamic>?)
          ?.map((e) => PostDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  nextCursor: json['nextCursor'] as String?,
  hasMore: json['hasMore'] as bool? ?? false,
);

PostLikeResponseDto _$PostLikeResponseDtoFromJson(Map<String, dynamic> json) =>
    PostLikeResponseDto(
      isLiked: json['isLiked'] as bool,
      likeCount: (json['likeCount'] as num).toInt(),
    );

PostBookmarkResponseDto _$PostBookmarkResponseDtoFromJson(
  Map<String, dynamic> json,
) => PostBookmarkResponseDto(
  isBookmarked: json['isBookmarked'] as bool,
  bookmarkCount: (json['bookmarkCount'] as num).toInt(),
);
