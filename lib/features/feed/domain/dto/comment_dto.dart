import 'package:json_annotation/json_annotation.dart';

import '../comment.dart';
import 'author_dto.dart';

part 'comment_dto.g.dart';

@JsonSerializable(createToJson: false)
class CommentDto {
  const CommentDto({
    required this.id,
    required this.postId,
    required this.author,
    required this.body,
    required this.createdAt,
  });

  factory CommentDto.fromJson(Map<String, dynamic> json) =>
      _$CommentDtoFromJson(json);

  final String id;
  final String postId;
  final AuthorDto author;
  final String body;
  final DateTime createdAt;

  Comment toEntity() => Comment(
    id: id,
    postId: postId,
    author: author.toEntity(),
    body: body,
    createdAt: createdAt.toLocal(),
  );
}

@JsonSerializable(createToJson: false)
class CommentPageDto {
  const CommentPageDto({
    this.data = const [],
    this.nextCursor,
    this.hasMore = false,
  });

  factory CommentPageDto.fromJson(Map<String, dynamic> json) =>
      _$CommentPageDtoFromJson(json);

  final List<CommentDto> data;
  final String? nextCursor;
  final bool hasMore;
}
