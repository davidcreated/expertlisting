import 'package:flutter/material.dart';

import '../constants/app_strings.dart';
import '../error/app_exception.dart';
import '../theme/app_spacing.dart';
import '../theme/theme_extensions.dart';

class AppErrorView extends StatelessWidget {
  const AppErrorView({required this.error, this.onRetry, super.key});

  final Object error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final mapped = asAppException(error);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: context.color.errorSurface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.wifi_off_rounded,
              size: 24,
              color: context.color.error,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            mapped.title,
            textAlign: TextAlign.center,
            style: context.text.sheetTitle,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            mapped.message,
            textAlign: TextAlign.center,
            style: context.text.meta,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: AppSpacing.xl),
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                backgroundColor: context.color.primary,
                foregroundColor: context.color.textOnPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xxl,
                  vertical: AppSpacing.md,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
              child: Text(
                AppStrings.common.tryAgain,
                style: context.text.buttonLabel.copyWith(
                  color: context.color.textOnPrimary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
