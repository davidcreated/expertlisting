import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/utils/count_formatter.dart';
import '../domain/post.dart';
import 'post_action_button.dart';

class PostActionBar extends StatelessWidget {
  const PostActionBar({
    required this.post,
    this.onLike,
    this.onComment,
    this.onShare,
    this.onBookmark,
    super.key,
  });

  final Post post;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final VoidCallback? onBookmark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        PostActionButton(
          asset: AppAssets.iconLike,
          activeIcon: Icons.favorite,
          isActive: post.isLiked,
          count: post.likeCount,
          activeColor: context.color.likeActive,
          onTap: onLike,
        ),
        const SizedBox(width: AppSpacing.lg),
        PostActionButton(
          asset: AppAssets.iconComments,
          count: post.commentCount,
          onTap: onComment,
        ),
        const SizedBox(width: AppSpacing.lg),
        PostActionButton(asset: AppAssets.iconShare, onTap: onShare),
        if (post.hasViews) ...[
          const SizedBox(width: AppSpacing.lg),
          Text(
            AppStrings.feed.views(CountFormatter.compact(post.viewCount)),
            style: context.text.count,
          ),
        ],
        const Spacer(),
        PostActionButton(
          asset: AppAssets.iconSave,
          activeIcon: Icons.bookmark,
          isActive: post.isBookmarked,
          count: post.bookmarkCount,
          activeColor: context.color.textPrimary,
          onTap: onBookmark,
        ),
      ],
    );
  }
}
