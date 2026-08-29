import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/theme_extensions.dart';

class PostCardSkeleton extends StatelessWidget {
  const PostCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.color.shimmerBase,
      highlightColor: context.color.shimmerHighlight,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenH,
          vertical: AppSpacing.cardV,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _box(const Size(40, 40), radius: AppRadius.pill),
                const SizedBox(width: AppSpacing.md),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _box(const Size(120, 14)),
                    const SizedBox(height: AppSpacing.sm),
                    _box(const Size(84, 11)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            _box(const Size(double.infinity, 13)),
            const SizedBox(height: AppSpacing.sm),
            _box(const Size(double.infinity, 13)),
            const SizedBox(height: AppSpacing.sm),
            _box(const Size(220, 13)),
            const SizedBox(height: AppSpacing.lg),
            _box(const Size(160, 24), radius: AppRadius.pill),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                _box(const Size(52, 20), radius: AppRadius.pill),
                const SizedBox(width: AppSpacing.lg),
                _box(const Size(52, 20), radius: AppRadius.pill),
                const SizedBox(width: AppSpacing.lg),
                _box(const Size(24, 20), radius: AppRadius.pill),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _box(Size size, {double radius = AppRadius.sm}) {
    return Container(
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
