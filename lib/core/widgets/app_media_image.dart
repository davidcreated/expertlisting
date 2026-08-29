import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../constants/app_assets.dart';
import '../theme/theme_extensions.dart';

class AppMediaImage extends StatelessWidget {
  const AppMediaImage({
    required this.url,
    this.localPath,
    this.fit = BoxFit.cover,
    super.key,
  });

  final String url;
  final String? localPath;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final path = localPath;
    if (path != null) {
      return Image.file(
        File(path),
        fit: fit,
        errorBuilder: (context, _, _) => _buildFallback(context),
      );
    }

    if (AppAssets.isAssetUrl(url)) {
      return Image.asset(
        AppAssets.assetPathOf(url),
        fit: fit,
        errorBuilder: (context, _, _) => _buildFallback(context),
      );
    }

    return CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      fadeInDuration: const Duration(milliseconds: 180),
      placeholder: (context, _) => ColoredBox(color: context.color.shimmerBase),
      errorWidget: (context, _, _) => _buildFallback(context),
    );
  }

  Widget _buildFallback(BuildContext context) {
    return ColoredBox(
      color: context.color.surfaceMuted,
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          size: 28,
          color: context.color.iconMuted,
        ),
      ),
    );
  }
}
