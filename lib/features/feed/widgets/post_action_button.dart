import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/utils/count_formatter.dart';
import '../../../core/widgets/app_icon.dart';

class PostActionButton extends HookWidget {
  const PostActionButton({
    required this.asset,
    this.activeIcon,
    this.isActive = false,
    this.count = 0,
    this.activeColor,
    this.iconSize = 20,
    this.onTap,
    super.key,
  });

  final String asset;
  final IconData? activeIcon;
  final bool isActive;
  final int count;
  final Color? activeColor;
  final double iconSize;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(
      duration: const Duration(milliseconds: 110),
    );

    final scale = useMemoized(
      () => Tween<double>(begin: 1, end: 0.82).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOut),
      ),
      [controller],
    );

    useEffect(() {
      void onStatusChanged(AnimationStatus status) {
        if (status == AnimationStatus.completed) controller.reverse();
      }

      controller.addStatusListener(onStatusChanged);
      return () => controller.removeStatusListener(onStatusChanged);
    }, [controller]);

    final tint = isActive
        ? (activeColor ?? context.color.primary)
        : context.color.textPrimary;

    final icon = isActive && activeIcon != null
        ? Icon(activeIcon, size: iconSize, color: tint)
        : AppIcon(asset, size: iconSize, color: tint);

    return GestureDetector(
      onTap: onTap == null
          ? null
          : () {
              controller.forward(from: 0);
              onTap!();
            },
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          ScaleTransition(scale: scale, child: icon),
          if (count > 0) ...[
            const SizedBox(width: AppSpacing.xs + 2),
            Text(
              CountFormatter.compact(count),
              style: context.text.count,
            ),
          ],
        ],
      ),
    );
  }
}
