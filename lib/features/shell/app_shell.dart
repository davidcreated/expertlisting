import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../core/theme/theme_extensions.dart';
import '../composer/create_post_screen.dart';
import '../feed/feed_screen.dart';
import 'widgets/app_bottom_nav.dart';
import 'widgets/tab_placeholder.dart';

class AppShell extends HookWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    final current = useState(AppTab.feed);

    void onTabSelected(AppTab tab) {
      if (tab == AppTab.list) {
        CreatePostScreen.push(context);
        return;
      }
      current.value = tab;
    }

    return Scaffold(
      backgroundColor: context.color.surface,
      body: switch (current.value) {
        AppTab.feed => const FeedScreen(),
        AppTab.list => const FeedScreen(),
        final tab => TabPlaceholder(tab: tab),
      },
      bottomNavigationBar: AppBottomNav(
        current: current.value,
        onSelected: onTabSelected,
      ),
    );
  }
}
