import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/widgets/app_avatar.dart';
import '../domain/author.dart';

class StoryAvatar extends StatelessWidget {
  const StoryAvatar({
    required this.author,
    required this.label,
    this.showRing = true,
    this.showAddBadge = false,
    this.onTap,
    super.key,
  });

  static const double size = 62;
  static const double itemWidth = 76;

  final Author author;
  final String label;
  final bool showRing;
  final bool showAddBadge;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: itemWidth,
        child: Column(
          children: [
            SizedBox(
              width: size,
              height: size,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  AppAvatar(
                    size: size,
                    imageUrl: author.avatarUrl,
                    initials: author.initials,
                    ringColor: showRing ? context.color.storyRing : null,
                    ringWidth: 2.5,
                  ),
                  if (showAddBadge)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: context.color.storyRing,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: context.color.surface,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.add,
                          size: 14,
                          color: context.color.textOnPrimary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xs + 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: context.text.storyLabel,
            ),
          ],
        ),
      ),
    );
  }
}
