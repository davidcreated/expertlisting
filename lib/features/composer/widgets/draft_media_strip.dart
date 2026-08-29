import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/widgets/app_media_image.dart';
import '../../feed/domain/media_item.dart';

class DraftMediaStrip extends StatelessWidget {
  const DraftMediaStrip({required this.media, this.onRemove, super.key});

  static const double tileSize = 104;

  final List<MediaItem> media;
  final void Function(String mediaId)? onRemove;

  @override
  Widget build(BuildContext context) {
    if (media.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: tileSize,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: media.length,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final item = media[index];

          return Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: SizedBox(
                  width: tileSize,
                  height: tileSize,
                  child: AppMediaImage(
                    url: item.url,
                    localPath: item.localPath,
                  ),
                ),
              ),
              Positioned(
                top: AppSpacing.xs,
                right: AppSpacing.xs,
                child: GestureDetector(
                  onTap: () => onRemove?.call(item.id),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: context.color.scrim,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: context.color.textOnPrimary,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
