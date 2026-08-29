import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/widgets/app_icon.dart';
import 'app_bottom_nav.dart';

class TabPlaceholder extends StatelessWidget {
  const TabPlaceholder({required this.tab, super.key});

  final AppTab tab;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppIcon(tab.asset, size: 32, color: context.color.textTertiary),
            const SizedBox(height: AppSpacing.lg),
            Text(
              '${tab.label} · ${AppStrings.common.comingSoon}',
              style: context.text.sheetTitle,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              AppStrings.common.comingSoonBody,
              textAlign: TextAlign.center,
              style: context.text.meta,
            ),
          ],
        ),
      ),
    );
  }
}
