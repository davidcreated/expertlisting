import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/widgets/app_icon.dart';

class FeedAppBar extends StatelessWidget {
  const FeedAppBar({this.onMessagesPressed, super.key});

  final VoidCallback? onMessagesPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenH,
        AppSpacing.sm,
        AppSpacing.screenH,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          SvgPicture.asset(AppAssets.logo, height: 22),
          const Spacer(),
          GestureDetector(
            onTap: onMessagesPressed,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: context.color.surfaceMuted,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: AppIcon(
                  AppAssets.iconMailbox,
                  size: 20,
                  color: context.color.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
