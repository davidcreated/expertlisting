import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:very_good_infinite_list/very_good_infinite_list.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/theme_extensions.dart';
import '../../core/widgets/app_error_view.dart';
import '../../core/widgets/app_toast.dart';
import '../composer/create_post_screen.dart';
import 'domain/paginated_result.dart';
import 'providers/feed_provider.dart';
import 'providers/post_filter_provider.dart';
import 'providers/post_interaction_provider.dart';
import 'widgets/composer_field.dart';
import 'widgets/feed_app_bar.dart';
import 'widgets/filter_bar.dart';
import 'widgets/post_card.dart';
import 'widgets/post_card_skeleton.dart';
import 'widgets/story_rail.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(feedProvider);
    final notifier = ref.read(feedProvider.notifier);

    ref.listen(postLikeActionProvider, (_, next) {
      if (next.hasError) {
        AppToast.showError(context, AppStrings.errors.likeFailed);
      }
    });

    final header = Column(
      children: [
        const FeedAppBar(),
        const StoryRail(),
        const FilterBar(),
        ComposerField(onTap: () => CreatePostScreen.push(context)),
        Container(height: 6, color: context.color.surfaceSunken),
      ],
    );

    return Scaffold(
      backgroundColor: context.color.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            header,
            Expanded(
              child: switch (state) {
                AsyncError(:final error) when state.value == null =>
                  AppErrorView(
                    error: error,
                    onRetry: () => ref.invalidate(feedProvider),
                  ),
                AsyncValue(value: null) => _buildInitialLoading(),
                AsyncValue(:final value?) => _buildList(
                  context,
                  ref,
                  value,
                  notifier,
                ),
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialLoading() {
    return ListView.builder(
      itemCount: 4,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (_, _) => const PostCardSkeleton(),
    );
  }

  Widget _buildList(
    BuildContext context,
    WidgetRef ref,
    PostListResult value,
    Feed notifier,
  ) {
    return RefreshIndicator(
      onRefresh: notifier.refresh,
      color: context.color.primary,
      child: InfiniteList(
        itemCount: value.items.length,
        isLoading: value.isLoadingMore,
        hasError: value.loadMoreFailed,
        hasReachedMax: value.hasReachedMax,
        onFetchData: notifier.loadMore,
        padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
        separatorBuilder: (context, _) =>
            Divider(color: context.color.border, height: 1),
        itemBuilder: (context, index) => PostCard(post: value.items[index]),
        loadingBuilder: (_) => const PostCardSkeleton(),
        errorBuilder: (context) => _buildLoadMoreError(context, notifier),
        emptyBuilder: (context) => _buildEmpty(context, ref),
        centerEmpty: true,
      ),
    );
  }

  Widget _buildLoadMoreError(BuildContext context, Feed notifier) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Text(
            AppStrings.errors.loadMoreFailed,
            style: context.text.meta,
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton(
            onPressed: notifier.loadMore,
            child: Text(
              AppStrings.common.tryAgain,
              style: context.text.buttonLabel.copyWith(
                color: context.color.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(postFilterControllerProvider);
    final hasFilters = filter.hasFilters;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            hasFilters
                ? AppStrings.feed.emptyFilteredTitle
                : AppStrings.feed.emptyTitle,
            textAlign: TextAlign.center,
            style: context.text.sheetTitle,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            hasFilters
                ? AppStrings.feed.emptyFilteredMessage
                : AppStrings.feed.emptyMessage,
            textAlign: TextAlign.center,
            style: context.text.meta,
          ),
          if (hasFilters) ...[
            const SizedBox(height: AppSpacing.lg),
            TextButton(
              onPressed: ref
                  .read(postFilterControllerProvider.notifier)
                  .clearAll,
              child: Text(
                AppStrings.common.clearAll,
                style: context.text.buttonLabel.copyWith(
                  color: context.color.primary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
