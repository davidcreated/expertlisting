import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/widgets/app_icon.dart';

enum AppTab {
  feed(AppAssets.iconFeed),
  search(AppAssets.iconSearch),
  list(AppAssets.iconList),
  notification(AppAssets.iconNotification),
  profile(AppAssets.iconProfile);

  const AppTab(this.asset);

  final String asset;

  String get label => switch (this) {
    AppTab.feed => AppStrings.nav.feed,
    AppTab.search => AppStrings.nav.search,
    AppTab.list => AppStrings.nav.list,
    AppTab.notification => AppStrings.nav.notification,
    AppTab.profile => AppStrings.nav.profile,
  };
}

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    required this.current,
    required this.onSelected,
    super.key,
  });

  final AppTab current;
  final ValueChanged<AppTab> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.color.surface,
        border: Border(top: BorderSide(color: context.color.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (final tab in AppTab.values)
                _buildTab(context, tab, tab == current),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(BuildContext context, AppTab tab, bool isActive) {
    final tint = isActive ? context.color.primary : context.color.textPrimary;

    return Expanded(
      child: GestureDetector(
        onTap: () => onSelected(tab),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppIcon(tab.asset, size: 24, color: tint),
            const SizedBox(height: AppSpacing.xs),
            Text(
              tab.label,
              maxLines: 1,
              style: context.text.navLabel.copyWith(color: tint),
            ),
          ],
        ),
      ),
    );
  }
}
