import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../theme/app_typography.dart';
import '../theme/theme_extensions.dart';

class AppAvatar extends StatelessWidget {
  const AppAvatar({
    required this.size,
    this.imageUrl,
    this.initials,
    this.ringColor,
    this.ringWidth = 2,
    this.ringGap = 2,
    super.key,
  });

  final double size;
  final String? imageUrl;
  final String? initials;
  final Color? ringColor;
  final double ringWidth;
  final double ringGap;

  @override
  Widget build(BuildContext context) {
    final hasRing = ringColor != null;
    final inset = hasRing ? ringWidth + ringGap : 0.0;
    final innerSize = size - inset * 2;

    final avatar = ClipOval(
      child: SizedBox(
        width: innerSize,
        height: innerSize,
        child: _buildImage(context, innerSize),
      ),
    );

    if (!hasRing) return avatar;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: ringColor!, width: ringWidth),
      ),
      child: Center(child: avatar),
    );
  }

  Widget _buildImage(BuildContext context, double innerSize) {
    final url = imageUrl;
    if (url == null || url.isEmpty) return _buildFallback(context, innerSize);

    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      width: innerSize,
      height: innerSize,
      fadeInDuration: const Duration(milliseconds: 150),
      placeholder: (_, _) => ColoredBox(color: context.color.shimmerBase),
      errorWidget: (_, _, _) => _buildFallback(context, innerSize),
    );
  }

  Widget _buildFallback(BuildContext context, double innerSize) {
    return ColoredBox(
      color: context.color.primaryMuted,
      child: Center(
        child: Text(
          initials ?? '',
          style: AppTypography.authorName.copyWith(
            fontSize: innerSize * 0.38,
            color: context.color.primary,
          ),
        ),
      ),
    );
  }
}
