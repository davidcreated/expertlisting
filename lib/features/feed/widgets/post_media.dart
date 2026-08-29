import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/widgets/app_media_image.dart';
import '../domain/media_item.dart';

class PostMedia extends StatelessWidget {
  const PostMedia({required this.media, super.key});

  final List<MediaItem> media;

  @override
  Widget build(BuildContext context) {
    if (media.isEmpty) return const SizedBox.shrink();
    if (media.length == 1) return _buildSingle(context, media.first);

    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: media.length,
        padding: EdgeInsets.zero,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: SizedBox(
              width: 220,
              child: _buildTile(context, media[index]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSingle(BuildContext context, MediaItem item) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: AspectRatio(
        aspectRatio: item.aspectRatio <= 0 ? 1 : item.aspectRatio,
        child: _buildTile(context, item),
      ),
    );
  }

  Widget _buildTile(BuildContext context, MediaItem item) {
    final image = AppMediaImage(url: item.url, localPath: item.localPath);
    if (!item.isVideo) return image;

    return Stack(
      fit: StackFit.expand,
      children: [
        image,
        Center(
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: context.color.scrim,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.play_arrow_rounded,
              size: 32,
              color: context.color.textOnPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
