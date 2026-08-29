import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../features/shell/app_shell.dart';

class ExpertListingApp extends StatelessWidget {
  const ExpertListingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expert Listing',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      builder: AppTheme.lockTextScale,
      home: const AppShell(),
    );
  }
}
