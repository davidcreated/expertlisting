import 'package:flutter/widgets.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/widgets/app_avatar_stack.dart';
import '../domain/post.dart';

class PostLikedByRow extends StatelessWidget {
  const PostLikedByRow({required this.post, super.key});

  final Post post;

  @override
  Widget build(BuildContext context) {
    if (!post.showLikedBy) return const SizedBox.shrink();

    final others = post.likedByOthers;
    final base = context.text.meta.copyWith(
      color: context.color.textSecondary,
    );

    return Row(
      children: [
        AppAvatarStack(authors: post.likedBy),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text.rich(
            TextSpan(
              style: base,
              children: [
                const TextSpan(text: 'Liked by '),
                TextSpan(
                  text: post.likedByLeader,
                  style: base.copyWith(
                    color: context.color.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (others > 0)
                  TextSpan(
                    text: ' and $others ${others == 1 ? 'other' : 'others'}',
                  ),
              ],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
