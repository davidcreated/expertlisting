import 'package:dio/dio.dart';

import '../../../core/config/app_env.dart';
import '../../../core/network/response_parsing.dart';
import 'comment.dart';
import 'dto/comment_dto.dart';
import 'dto/post_dto.dart';
import 'paginated_result.dart';
import 'post.dart';
import 'post_draft.dart';
import 'post_filter.dart';
import 'post_repository.dart';

class ApiPostRepository implements PostRepository {
  const ApiPostRepository(this._dio);

  final Dio _dio;

  @override
  Future<PostListResult> getPosts({
    PostFilter filter = const PostFilter(),
    String? cursor,
    int limit = AppEnv.feedPageSize,
  }) {
    const endpoint = '/posts';

    return guardApiCall(() async {
      final response = await _dio.get<Map<String, dynamic>>(
        endpoint,
        queryParameters: {
          'limit': limit,
          'cursor': ?cursor,
          ...filter.toQueryParameters(),
        },
      );

      final page = response.parseObject(
        fromJson: PostPageDto.fromJson,
        toEntity: (dto) => dto,
        endpoint: endpoint,
      );

      final items = page.data.map((dto) => dto.toEntity()).toList();

      return PostListResult(
        items: items,
        nextCursor: page.nextCursor,
        hasReachedMax: !page.hasMore,
      );
    });
  }

  @override
  Future<PostLikeResult> toggleLike(String postId) {
    final endpoint = '/posts/$postId/like';

    return guardApiCall(() async {
      final response = await _dio.post<Map<String, dynamic>>(endpoint);

      final dto = response.parseObject(
        fromJson: PostLikeResponseDto.fromJson,
        toEntity: (dto) => dto,
        endpoint: endpoint,
      );

      return PostLikeResult(isLiked: dto.isLiked, likeCount: dto.likeCount);
    });
  }

  @override
  Future<PostBookmarkResult> toggleBookmark(String postId) {
    final endpoint = '/posts/$postId/bookmark';

    return guardApiCall(() async {
      final response = await _dio.post<Map<String, dynamic>>(endpoint);

      final dto = response.parseObject(
        fromJson: PostBookmarkResponseDto.fromJson,
        toEntity: (dto) => dto,
        endpoint: endpoint,
      );

      return PostBookmarkResult(
        isBookmarked: dto.isBookmarked,
        bookmarkCount: dto.bookmarkCount,
      );
    });
  }

  @override
  Future<CommentListResult> getComments(
    String postId, {
    String? cursor,
    int limit = AppEnv.commentsPageSize,
  }) {
    final endpoint = '/posts/$postId/comments';

    return guardApiCall(() async {
      final response = await _dio.get<Map<String, dynamic>>(
        endpoint,
        queryParameters: {
          'limit': limit,
          'cursor': ?cursor,
        },
      );

      final page = response.parseObject(
        fromJson: CommentPageDto.fromJson,
        toEntity: (dto) => dto,
        endpoint: endpoint,
      );

      return CommentListResult(
        items: page.data.map((dto) => dto.toEntity()).toList(),
        nextCursor: page.nextCursor,
        hasReachedMax: !page.hasMore,
      );
    });
  }

  @override
  Future<Comment> addComment(String postId, String body) {
    final endpoint = '/posts/$postId/comments';

    return guardApiCall(() async {
      final response = await _dio.post<Map<String, dynamic>>(
        endpoint,
        data: {'body': body.trim()},
      );

      return response.parseObject(
        fromJson: CommentDto.fromJson,
        toEntity: (dto) => dto.toEntity(),
        endpoint: endpoint,
      );
    });
  }

  @override
  Future<Post> createPost(PostDraft draft) {
    const endpoint = '/posts';

    return guardApiCall(() async {
      final response = await _dio.post<Map<String, dynamic>>(
        endpoint,
        data: {
          'body': draft.trimmedBody,
          'category': draft.category.wire,
          if (draft.location != null) 'location': draft.location,
          if (draft.transactionType != null)
            'transactionType': draft.transactionType!.wire,
          if (draft.media.isNotEmpty)
            'media': draft.media
                .map((item) => {'url': item.url, 'kind': item.kind.wire})
                .toList(),
        },
      );

      return response.parseObject(
        fromJson: PostDto.fromJson,
        toEntity: (dto) => dto.toEntity(),
        endpoint: endpoint,
      );
    });
  }
}
