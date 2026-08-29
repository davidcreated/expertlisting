import 'comment.dart';
import 'paginated_result.dart';
import 'post.dart';
import 'post_draft.dart';
import 'post_filter.dart';

abstract interface class PostRepository {
  Future<PostListResult> getPosts({
    PostFilter filter = const PostFilter(),
    String? cursor,
    int limit,
  });

  Future<PostLikeResult> toggleLike(String postId);

  Future<PostBookmarkResult> toggleBookmark(String postId);

  Future<CommentListResult> getComments(
    String postId, {
    String? cursor,
    int limit,
  });

  Future<Comment> addComment(String postId, String body);

  Future<Post> createPost(PostDraft draft);
}
