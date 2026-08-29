import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../filters/filters_sheet.dart';
import '../providers/post_filter_provider.dart';

class FilterBar extends ConsumerWidget {
  const FilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(postFilterControllerProvider);
    final count = filter.filterCount;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenH,
        AppSpacing.xs,
        AppSpacing.screenH,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => FiltersSheet.show(context),
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm + 1,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.pill),
                border: Border.all(color: context.color.borderStrong),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.tune_rounded,
                    size: 18,
                    color: context.color.textPrimary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    AppStrings.feed.filters,
                    style: context.text.filterLabel,
                  ),
                  if (count > 0) ...[
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: context.color.primary,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Text(
                        '$count',
                        style: context.text.storyLabel.copyWith(
                          color: context.color.textOnPrimary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (count > 0) ...[
            const SizedBox(width: AppSpacing.sm),
            TextButton(
              onPressed: ref
                  .read(postFilterControllerProvider.notifier)
                  .clearAll,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                AppStrings.common.clearAll,
                style: context.text.filterLabel.copyWith(
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
