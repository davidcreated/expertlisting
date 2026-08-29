import 'package:flutter/widgets.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/utils/relative_time.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../feed/domain/comment.dart';

class CommentTile extends StatelessWidget {
  const CommentTile({required this.comment, super.key});

  final Comment comment;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: comment.isPending ? 0.55 : 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenH,
          vertical: AppSpacing.sm + 2,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppAvatar(
              size: 34,
              imageUrl: comment.author.avatarUrl,
              initials: comment.author.initials,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          comment.author.username,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.metaStrong,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        RelativeTime.format(comment.createdAt),
                        style: context.text.meta,
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    comment.body,
                    style: context.text.meta.copyWith(
                      color: context.color.textPrimary,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
