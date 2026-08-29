import 'package:flutter/widgets.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/app_pill.dart';
import '../domain/post.dart';

class PostMetaRow extends StatelessWidget {
  const PostMetaRow({required this.post, super.key});

  final Post post;

  @override
  Widget build(BuildContext context) {
    final transactionType = post.transactionType;

    return Row(
      children: [
        if (post.hasLocation) ...[
          AppIcon(
            AppAssets.iconMapPin,
            size: 16,
            color: context.color.iconMuted,
          ),
          const SizedBox(width: AppSpacing.xs + 2),
          Flexible(
            child: Text(
              post.location!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.text.meta.copyWith(
                color: context.color.textSecondary,
              ),
            ),
          ),
        ],
        if (transactionType != null) ...[
          if (post.hasLocation) const SizedBox(width: AppSpacing.sm),
          AppPill(
            label: transactionType.label,
            icon: transactionType.icon,
            foreground: transactionType.foreground,
            background: transactionType.background,
          ),
        ],
      ],
    );
  }
}
