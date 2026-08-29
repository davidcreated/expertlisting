import 'package:equatable/equatable.dart';

import 'author.dart';

class Comment extends Equatable {
  const Comment({
    required this.id,
    required this.postId,
    required this.author,
    required this.body,
    required this.createdAt,
    this.isPending = false,
  });

  final String id;
  final String postId;
  final Author author;
  final String body;
  final DateTime createdAt;
  final bool isPending;

  Comment copyWith({
    String? id,
    String? postId,
    Author? author,
    String? body,
    DateTime? createdAt,
    bool? isPending,
  }) {
    return Comment(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      author: author ?? this.author,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      isPending: isPending ?? this.isPending,
    );
  }

  @override
  List<Object?> get props => [id, postId, author, body, createdAt, isPending];
}
