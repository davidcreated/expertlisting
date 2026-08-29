import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/theme_extensions.dart';
import '../../core/widgets/app_pill.dart';
import '../feed/domain/post_category.dart';
import '../feed/domain/post_filter.dart';
import '../feed/domain/transaction_type.dart';
import '../feed/providers/post_filter_provider.dart';

class FiltersSheet extends HookConsumerWidget {
  const FiltersSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const FiltersSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applied = ref.read(postFilterControllerProvider);
    final draft = useState(applied);
    final locationController = useTextEditingController(
      text: applied.location ?? '',
    );

    void toggleCategory(PostCategory category) {
      final next = <PostCategory>{...draft.value.categories};
      if (!next.remove(category)) next.add(category);
      draft.value = draft.value.copyWith(categories: next);
    }

    void toggleTransactionType(TransactionType type) {
      final next = <TransactionType>{...draft.value.transactionTypes};
      if (!next.remove(type)) next.add(type);
      draft.value = draft.value.copyWith(transactionTypes: next);
    }

    void clearAll() {
      draft.value = const PostFilter();
      locationController.clear();
    }

    void apply() {
      final trimmed = locationController.text.trim();
      ref.read(postFilterControllerProvider.notifier).replace(
        draft.value.copyWith(
          location: () => trimmed.isEmpty ? null : trimmed,
        ),
      );
      Navigator.of(context).pop();
    }

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: context.color.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.lg),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, onClear: clearAll),
            Divider(color: context.color.border, height: 1),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.screenH),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionLabel(context, AppStrings.filters.category),
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      for (final category in PostCategory.values)
                        _buildChoice(
                          context,
                          label: category.label,
                          selected: draft.value.categories.contains(category),
                          onTap: () => toggleCategory(category),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _buildSectionLabel(
                    context,
                    AppStrings.filters.transactionType,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      for (final type in TransactionType.values)
                        _buildChoice(
                          context,
                          label: type.label,
                          icon: type.icon,
                          selected: draft.value.transactionTypes.contains(type),
                          selectedForeground: type.foreground,
                          selectedBackground: type.background,
                          onTap: () => toggleTransactionType(type),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _buildSectionLabel(context, AppStrings.filters.location),
                  const SizedBox(height: AppSpacing.md),
                  _buildLocationField(context, locationController),
                  const SizedBox(height: AppSpacing.xxl),
                  _buildApplyButton(context, onTap: apply),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, {required VoidCallback onClear}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenH,
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
      ),
      child: Row(
        children: [
          Text(AppStrings.filters.title, style: context.text.sheetTitle),
          const Spacer(),
          TextButton(
            onPressed: onClear,
            child: Text(
              AppStrings.common.clearAll,
              style: context.text.filterLabel.copyWith(
                color: context.color.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(BuildContext context, String label) {
    return Text(
      label,
      style: context.text.metaStrong.copyWith(fontSize: 14),
    );
  }

  Widget _buildChoice(
    BuildContext context, {
    required String label,
    required bool selected,
    required VoidCallback onTap,
    IconData? icon,
    Color? selectedForeground,
    Color? selectedBackground,
  }) {
    return AppPill(
      label: label,
      icon: icon,
      onTap: onTap,
      foreground: selected
          ? (selectedForeground ?? context.color.primary)
          : context.color.textSecondary,
      background: selected
          ? (selectedBackground ?? context.color.primaryMuted)
          : context.color.surface,
      borderColor: selected
          ? (selectedForeground ?? context.color.primary)
          : context.color.borderStrong,
    );
  }

  Widget _buildLocationField(
    BuildContext context,
    TextEditingController controller,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.color.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: TextField(
        controller: controller,
        style: context.text.input,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: AppStrings.filters.locationPlaceholder,
          hintStyle: context.text.placeholder,
          contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        ),
      ),
    );
  }

  Widget _buildApplyButton(
    BuildContext context, {
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          backgroundColor: context.color.primary,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
        ),
        child: Text(
          AppStrings.common.apply,
          style: context.text.buttonLabel.copyWith(
            color: context.color.textOnPrimary,
          ),
        ),
      ),
    );
  }
}
