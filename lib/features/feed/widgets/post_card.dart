import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../comments/comments_sheet.dart';
import '../domain/post.dart';
import '../providers/post_interaction_provider.dart';
import 'post_action_bar.dart';
import 'post_card_header.dart';
import 'post_comment_preview.dart';
import 'post_liked_by_row.dart';
import 'post_media.dart';
import 'post_meta_row.dart';

class PostCard extends ConsumerWidget {
  const PostCard({required this.post, super.key});

  final Post post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void openComments() => CommentsSheet.show(context, postId: post.id);

    void toggleLike() =>
        ref.read(postLikeActionProvider.notifier).toggle(post);

    void toggleBookmark() =>
        ref.read(postBookmarkActionProvider.notifier).toggle(post);

    final header = PostCardHeader(post: post);

    final body = Text(post.body, style: context.text.body);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenH,
        vertical: AppSpacing.cardV,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          header,
          const SizedBox(height: AppSpacing.sm),
          body,
          if (post.hasMetaRow) ...[
            const SizedBox(height: AppSpacing.md),
            PostMetaRow(post: post),
          ],
          if (post.hasMedia) ...[
            const SizedBox(height: AppSpacing.md),
            PostMedia(media: post.media),
          ],
          const SizedBox(height: AppSpacing.md),
          PostActionBar(
            post: post,
            onLike: toggleLike,
            onComment: openComments,
            onBookmark: toggleBookmark,
          ),
          if (post.showLikedBy) ...[
            const SizedBox(height: AppSpacing.sm),
            PostLikedByRow(post: post),
          ],
          if (post.showCommentPreview || post.showViewAllComments) ...[
            const SizedBox(height: AppSpacing.sm),
            PostCommentPreview(post: post, onViewAll: openComments),
          ],
        ],
      ),
    );
  }
}
