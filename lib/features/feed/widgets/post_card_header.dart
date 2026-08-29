import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/utils/relative_time.dart';
import '../../../core/widgets/app_avatar.dart';
import '../domain/post.dart';

class PostCardHeader extends StatelessWidget {
  const PostCardHeader({required this.post, this.onMorePressed, super.key});

  static const double avatarSize = 40;

  final Post post;
  final VoidCallback? onMorePressed;

  @override
  Widget build(BuildContext context) {
    final role = post.author.role;
    final timestamp = RelativeTime.format(post.createdAt);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppAvatar(
          size: avatarSize,
          imageUrl: post.author.avatarUrl,
          initials: post.author.initials,
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
                      post.author.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.authorName,
                    ),
                  ),
                  if (role != null)
                    Text(
                      '  •  ${role.label}',
                      maxLines: 1,
                      style: context.text.meta,
                    ),
                ],
              ),
              const SizedBox(height: 1),
              Text(
                '${post.category.label} • $timestamp',
                style: context.text.meta,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        GestureDetector(
          onTap: onMorePressed,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.only(left: AppSpacing.xs),
            child: Icon(
              Icons.more_horiz,
              size: 24,
              color: context.color.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
