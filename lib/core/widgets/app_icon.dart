import 'package:flutter/widgets.dart';

import '../theme/theme_extensions.dart';

class AppIcon extends StatelessWidget {
  const AppIcon(this.asset, {this.size = 24, this.color, super.key});

  final String asset;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      asset,
      width: size,
      height: size,
      color: color ?? context.color.icon,
      filterQuality: FilterQuality.medium,
      isAntiAlias: true,
    );
  }
}
