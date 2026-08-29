import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/theme_extensions.dart';

class AppPill extends StatelessWidget {
  const AppPill({
    required this.label,
    this.icon,
    this.foreground,
    this.background,
    this.borderColor,
    this.onTap,
    this.trailing,
    super.key,
  });

  final String label;
  final IconData? icon;
  final Color? foreground;
  final Color? background;
  final Color? borderColor;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final fg = foreground ?? context.color.textPrimary;

    final content = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: background ?? Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: borderColor == null
            ? null
            : Border.all(color: borderColor!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 15, color: fg),
            const SizedBox(width: AppSpacing.xs + 2),
          ],
          Text(
            label,
            style: context.text.chipLabel.copyWith(color: fg),
          ),
          if (trailing != null) ...[
            const SizedBox(width: AppSpacing.xs + 2),
            trailing!,
          ],
        ],
      ),
    );

    if (onTap == null) return content;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: content,
    );
  }
}
