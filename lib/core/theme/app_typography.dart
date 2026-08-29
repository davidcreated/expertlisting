import 'package:flutter/widgets.dart';

import 'app_colors.dart';

class AppTypography {
  const AppTypography._();

  static const String fontFamily = 'OpenRunde';

  static const TextStyle _base = TextStyle(
    fontFamily: fontFamily,
    color: AppColors.textPrimary,
    height: 1.35,
    letterSpacing: -0.1,
  );

  static final TextStyle screenTitle = _base.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  static final TextStyle sheetTitle = _base.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  static final TextStyle authorName = _base.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static final TextStyle body = _base.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.45,
  );

  static final TextStyle bodyStrong = body.copyWith(
    fontWeight: FontWeight.w600,
    height: 1.45,
  );

  static final TextStyle meta = _base.copyWith(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
  );

  static final TextStyle metaStrong = meta.copyWith(
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static final TextStyle chipLabel = _base.copyWith(
    fontSize: 13,
    fontWeight: FontWeight.w500,
  );

  static final TextStyle count = _base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static final TextStyle storyLabel = _base.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static final TextStyle navLabel = _base.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w500,
  );

  static final TextStyle placeholder = _base.copyWith(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textPlaceholder,
  );

  static final TextStyle input = _base.copyWith(
    fontSize: 15,
    fontWeight: FontWeight.w400,
  );

  static final TextStyle buttonLabel = _base.copyWith(
    fontSize: 15,
    fontWeight: FontWeight.w600,
  );

  static final TextStyle filterLabel = _base.copyWith(
    fontSize: 15,
    fontWeight: FontWeight.w500,
  );
}
