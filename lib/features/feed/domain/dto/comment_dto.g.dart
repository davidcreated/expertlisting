// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommentDto _$CommentDtoFromJson(Map<String, dynamic> json) => CommentDto(
  id: json['id'] as String,
  postId: json['postId'] as String,
  author: AuthorDto.fromJson(json['author'] as Map<String, dynamic>),
  body: json['body'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

CommentPageDto _$CommentPageDtoFromJson(Map<String, dynamic> json) =>
    CommentPageDto(
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => CommentDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      nextCursor: json['nextCursor'] as String?,
      hasMore: json['hasMore'] as bool? ?? false,
    );
