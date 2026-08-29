import 'package:flutter/widgets.dart';

import 'app_colors.dart';
import 'app_typography.dart';

extension ThemeTokensX on BuildContext {
  AppColorTokens get color => const AppColorTokens();

  AppTextTokens get text => const AppTextTokens();

  double get screenWidth => MediaQuery.sizeOf(this).width;
}

class AppColorTokens {
  const AppColorTokens();

  Color get primary => AppColors.primary;
  Color get primaryMuted => AppColors.primaryMuted;
  Color get storyRing => AppColors.storyRing;

  Color get surface => AppColors.surface;
  Color get surfaceMuted => AppColors.surfaceMuted;
  Color get surfaceSunken => AppColors.surfaceSunken;

  Color get border => AppColors.border;
  Color get borderStrong => AppColors.borderStrong;

  Color get textPrimary => AppColors.textPrimary;
  Color get textSecondary => AppColors.textSecondary;
  Color get textTertiary => AppColors.textTertiary;
  Color get textPlaceholder => AppColors.textPlaceholder;
  Color get textOnPrimary => AppColors.textOnPrimary;

  Color get icon => AppColors.icon;
  Color get iconMuted => AppColors.iconMuted;

  Color get error => AppColors.error;
  Color get errorSurface => AppColors.errorSurface;
  Color get success => AppColors.success;
  Color get likeActive => AppColors.likeActive;

  Color get scrim => AppColors.scrim;
  Color get shimmerBase => AppColors.shimmerBase;
  Color get shimmerHighlight => AppColors.shimmerHighlight;
}

class AppTextTokens {
  const AppTextTokens();

  TextStyle get screenTitle => AppTypography.screenTitle;
  TextStyle get sheetTitle => AppTypography.sheetTitle;
  TextStyle get authorName => AppTypography.authorName;
  TextStyle get body => AppTypography.body;
  TextStyle get bodyStrong => AppTypography.bodyStrong;
  TextStyle get meta => AppTypography.meta;
  TextStyle get metaStrong => AppTypography.metaStrong;
  TextStyle get chipLabel => AppTypography.chipLabel;
  TextStyle get count => AppTypography.count;
  TextStyle get storyLabel => AppTypography.storyLabel;
  TextStyle get navLabel => AppTypography.navLabel;
  TextStyle get placeholder => AppTypography.placeholder;
  TextStyle get input => AppTypography.input;
  TextStyle get buttonLabel => AppTypography.buttonLabel;
  TextStyle get filterLabel => AppTypography.filterLabel;
}
