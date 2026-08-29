import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/session/current_user_provider.dart';
import '../../../core/theme/app_spacing.dart';
import '../providers/story_provider.dart';
import 'story_avatar.dart';

class StoryRail extends ConsumerWidget {
  const StoryRail({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewer = ref.watch(currentUserProvider);
    final authors = ref.watch(storyAuthorsProvider);

    return SizedBox(
      height: 96,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenH - AppSpacing.xs,
        ),
        itemCount: authors.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return StoryAvatar(
              author: viewer,
              label: AppStrings.feed.yourStory,
              showRing: false,
              showAddBadge: true,
            );
          }

          final author = authors[index - 1];
          return StoryAvatar(author: author, label: author.name);
        },
      ),
    );
  }
}
