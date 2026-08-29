import 'dart:convert';

import 'package:expertlisting/features/feed/domain/author.dart';
import 'package:expertlisting/features/feed/domain/dto/post_dto.dart';
import 'package:expertlisting/features/feed/domain/media_item.dart';
import 'package:expertlisting/features/feed/domain/post_category.dart';
import 'package:expertlisting/features/feed/domain/transaction_type.dart';
import 'package:flutter_test/flutter_test.dart';

const String _pageJson = '''
{
  "data": [
    {
      "id": "post-3",
      "author": {
        "id": "user-boyd",
        "name": "Boyd From",
        "username": "boyd.from",
        "avatarUrl": "https://cdn.example.com/boyd.jpg",
        "role": "DEVELOPER"
      },
      "category": "PROPERTY",
      "body": "Newly serviced 3-bedroom apartment.",
      "location": "Lekki Phase 1, Lagos",
      "transactionType": "FOR_RENT",
      "media": [
        {
          "id": "media-3-1",
          "url": "https://cdn.example.com/card.png",
          "kind": "IMAGE",
          "aspectRatio": 1.05
        }
      ],
      "createdAt": "2026-08-28T09:15:00.000Z",
      "likeCount": 23,
      "commentCount": 4,
      "viewCount": 1000,
      "bookmarkCount": 2,
      "isLiked": true,
      "isBookmarked": false,
      "likedBy": [
        {
          "id": "user-miracle",
          "name": "Miracle Hassan",
          "username": "miracle.h"
        }
      ],
      "topComment": {
        "id": "comment-3-1",
        "postId": "post-3",
        "author": {
          "id": "user-tunde",
          "name": "Tunde Bakare",
          "username": "tunde_b"
        },
        "body": "Is the inspection fee refundable?",
        "createdAt": "2026-08-28T10:00:00.000Z"
      }
    }
  ],
  "nextCursor": "post-3",
  "hasMore": true
}
''';

void main() {
  group('PostPageDto parsing', () {
    test('a representative payload maps to a fully populated entity', () {
      final page = PostPageDto.fromJson(
        jsonDecode(_pageJson) as Map<String, dynamic>,
      );

      expect(page.hasMore, isTrue);
      expect(page.nextCursor, 'post-3');
      expect(page.data, hasLength(1));

      final post = page.data.single.toEntity();

      expect(post.id, 'post-3');
      expect(post.body, 'Newly serviced 3-bedroom apartment.');
      expect(post.category, PostCategory.property);
      expect(post.transactionType, TransactionType.forRent);
      expect(post.location, 'Lekki Phase 1, Lagos');
      expect(post.likeCount, 23);
      expect(post.commentCount, 4);
      expect(post.viewCount, 1000);
      expect(post.bookmarkCount, 2);
      expect(post.isLiked, isTrue);
      expect(post.isBookmarked, isFalse);
      expect(post.createdAt.toUtc().hour, 9);

      expect(post.author.name, 'Boyd From');
      expect(post.author.username, 'boyd.from');
      expect(post.author.role, AuthorRole.developer);
      expect(post.author.avatarUrl, isNotNull);

      expect(post.media, hasLength(1));
      expect(post.media.single.kind, MediaKind.image);
      expect(post.media.single.aspectRatio, closeTo(1.05, 0.001));

      expect(post.likedBy, hasLength(1));
      expect(post.likedBy.single.username, 'miracle.h');
      expect(post.likedBy.single.role, isNull);

      expect(post.topComment, isNotNull);
      expect(post.topComment!.author.username, 'tunde_b');
      expect(post.topComment!.body, 'Is the inspection fee refundable?');
    });

    test('a minimal payload parses without throwing', () {
      final json = {
        'id': 'post-9',
        'author': {'id': 'u1', 'name': 'Maurice U', 'username': 'maurice.u'},
        'body': 'Reminder for anyone renting this season.',
        'createdAt': '2026-08-28T09:15:00.000Z',
      };

      final post = PostDto.fromJson(json).toEntity();

      expect(post.category, PostCategory.general);
      expect(post.transactionType, isNull);
      expect(post.location, isNull);
      expect(post.media, isEmpty);
      expect(post.likedBy, isEmpty);
      expect(post.topComment, isNull);
      expect(post.likeCount, 0);
      expect(post.isLiked, isFalse);
      expect(post.hasMedia, isFalse);
      expect(post.hasMetaRow, isFalse);
    });

    test('an unknown transactionType does not discard the rest of the post',
        () {
      final json = {
        'id': 'post-x',
        'author': {'id': 'u1', 'name': 'A B', 'username': 'a.b'},
        'body': 'Body survives an unknown enum.',
        'createdAt': '2026-08-28T09:15:00.000Z',
        'transactionType': 'RENT_TO_OWN',
        'category': 'SOMETHING_NEW',
      };

      final post = PostDto.fromJson(json).toEntity();

      expect(post.transactionType, isNull);
      expect(post.category, PostCategory.general);
      expect(post.body, 'Body survives an unknown enum.');
    });
  });

  group('PostLikeResponseDto parsing', () {
    test('reads the server as the authority on like state', () {
      final dto = PostLikeResponseDto.fromJson(
        jsonDecode('{"isLiked": false, "likeCount": 22}')
            as Map<String, dynamic>,
      );

      expect(dto.isLiked, isFalse);
      expect(dto.likeCount, 22);
    });
  });
}
