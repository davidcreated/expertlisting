import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:very_good_infinite_list/very_good_infinite_list.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/theme_extensions.dart';
import '../../core/widgets/app_error_view.dart';
import '../../core/widgets/app_toast.dart';
import '../feed/domain/paginated_result.dart';
import 'providers/comments_provider.dart';
import 'widgets/comment_composer.dart';
import 'widgets/comment_tile.dart';

class CommentsSheet extends ConsumerWidget {
  const CommentsSheet({required this.postId, super.key});

  final String postId;

  static Future<void> show(BuildContext context, {required String postId}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CommentsSheet(postId: postId),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(commentsProvider(postId));
    final notifier = ref.read(commentsProvider(postId).notifier);

    ref.listen(addCommentActionProvider, (_, next) {
      if (next.hasError) {
        AppToast.showError(context, AppStrings.errors.commentFailed);
      }
    });

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: context.color.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadius.lg),
            ),
          ),
          child: Column(
            children: [
              _buildHandle(context),
              _buildTitle(context),
              Divider(color: context.color.border, height: 1),
              Expanded(
                child: switch (state) {
                  AsyncError(:final error) when state.value == null =>
                    AppErrorView(
                      error: error,
                      onRetry: () => ref.invalidate(commentsProvider(postId)),
                    ),
                  AsyncValue(value: null) => const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  AsyncValue(:final value?) => _buildList(
                    context,
                    ref,
                    scrollController,
                    value,
                    notifier,
                  ),
                },
              ),
              CommentComposer(postId: postId),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHandle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: context.color.borderStrong,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Text(AppStrings.comments.title, style: context.text.sheetTitle),
    );
  }

  Widget _buildList(
    BuildContext context,
    WidgetRef ref,
    ScrollController scrollController,
    CommentListResult value,
    Comments notifier,
  ) {
    return InfiniteList(
      scrollController: scrollController,
      itemCount: value.items.length,
      isLoading: value.isLoadingMore,
      hasError: value.loadMoreFailed,
      hasReachedMax: value.hasReachedMax,
      onFetchData: notifier.loadMore,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      itemBuilder: (context, index) => CommentTile(comment: value.items[index]),
      loadingBuilder: (_) => const Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      errorBuilder: (context) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Center(
          child: TextButton(
            onPressed: notifier.loadMore,
            child: Text(
              AppStrings.comments.loadMoreFailed,
              style: context.text.meta,
            ),
          ),
        ),
      ),
      emptyBuilder: (context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppStrings.comments.emptyTitle,
                style: context.text.sheetTitle,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                AppStrings.comments.emptyMessage,
                style: context.text.meta,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
