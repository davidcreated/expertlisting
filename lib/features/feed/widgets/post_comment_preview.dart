import 'package:flutter/widgets.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/theme_extensions.dart';
import '../domain/post.dart';

class PostCommentPreview extends StatelessWidget {
  const PostCommentPreview({required this.post, this.onViewAll, super.key});

  final Post post;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    final comment = post.topComment;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (comment != null)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Text.rich(
              TextSpan(
                style: context.text.meta.copyWith(
                  color: context.color.textPrimary,
                  height: 1.4,
                ),
                children: [
                  TextSpan(
                    text: comment.author.username,
                    style: context.text.meta.copyWith(
                      color: context.color.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const TextSpan(text: '   '),
                  TextSpan(text: comment.body),
                ],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        if (post.showViewAllComments)
          GestureDetector(
            onTap: onViewAll,
            behavior: HitTestBehavior.opaque,
            child: Text(
              AppStrings.feed.viewAllComments(post.viewAllCommentsCount),
              style: context.text.meta,
            ),
          ),
      ],
    );
  }
}
