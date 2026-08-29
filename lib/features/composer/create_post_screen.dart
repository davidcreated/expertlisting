import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/constants/app_strings.dart';
import '../../core/session/current_user_provider.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/theme_extensions.dart';
import '../../core/widgets/app_avatar.dart';
import '../../core/widgets/app_pill.dart';
import '../../core/widgets/app_toast.dart';
import '../feed/domain/author.dart';
import '../feed/domain/media_item.dart';
import '../feed/domain/post_category.dart';
import '../feed/domain/post_draft.dart';
import '../feed/domain/transaction_type.dart';
import 'providers/create_post_provider.dart';
import 'widgets/draft_media_strip.dart';

class CreatePostScreen extends HookConsumerWidget {
  const CreatePostScreen({super.key});

  static Future<void> push(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const CreatePostScreen()),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewer = ref.watch(currentUserProvider);
    final draft = ref.watch(postDraftControllerProvider);
    final controller = ref.read(postDraftControllerProvider.notifier);
    final isSubmitting = ref.watch(createPostActionProvider).isLoading;

    final bodyController = useTextEditingController(text: draft.body);
    final locationController = useTextEditingController(
      text: draft.location ?? '',
    );
    final picker = useMemoized(ImagePicker.new, []);

    ref.listen(createPostActionProvider, (_, next) {
      if (next.hasError) {
        AppToast.showError(context, AppStrings.errors.postFailed);
      }
    });

    Future<void> pickImages() async {
      if (!draft.canAddMedia) {
        AppToast.showInfo(context, AppStrings.composer.mediaLimitReached);
        return;
      }

      final files = await picker.pickMultiImage();
      if (files.isEmpty) return;

      controller.addMedia(
        files.map(
          (file) => MediaItem(
            id: 'local-${file.path.hashCode}',
            url: file.path,
            localPath: file.path,
          ),
        ),
      );
    }

    Future<void> submit() async {
      controller.setBody(bodyController.text);
      controller.setLocation(locationController.text);

      final success = await ref
          .read(createPostActionProvider.notifier)
          .submit();

      if (success && context.mounted) Navigator.of(context).pop();
    }

    return Scaffold(
      backgroundColor: context.color.surface,
      appBar: _buildAppBar(
        context,
        canSubmit: draft.canSubmit && !isSubmitting,
        isSubmitting: isSubmitting,
        onSubmit: submit,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBodyField(context, viewer, bodyController, controller),
                    if (draft.hasMedia) ...[
                      const SizedBox(height: AppSpacing.lg),
                      DraftMediaStrip(
                        media: draft.media,
                        onRemove: controller.removeMedia,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xl),
                    _buildSection(
                      context,
                      label: AppStrings.composer.category,
                      child: Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          for (final category in PostCategory.values)
                            AppPill(
                              label: category.label,
                              onTap: () => controller.setCategory(category),
                              foreground: draft.category == category
                                  ? context.color.primary
                                  : context.color.textSecondary,
                              background: draft.category == category
                                  ? context.color.primaryMuted
                                  : context.color.surface,
                              borderColor: draft.category == category
                                  ? context.color.primary
                                  : context.color.borderStrong,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _buildSection(
                      context,
                      label: AppStrings.composer.transactionType,
                      child: Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          for (final type in TransactionType.values)
                            AppPill(
                              label: type.label,
                              icon: type.icon,
                              onTap: () =>
                                  controller.setTransactionType(type),
                              foreground: draft.transactionType == type
                                  ? type.foreground
                                  : context.color.textSecondary,
                              background: draft.transactionType == type
                                  ? type.background
                                  : context.color.surface,
                              borderColor: draft.transactionType == type
                                  ? type.foreground
                                  : context.color.borderStrong,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _buildSection(
                      context,
                      label: AppStrings.composer.addLocation,
                      child: _buildLocationField(context, locationController),
                    ),
                    const SizedBox(height: AppSpacing.xxxl),
                  ],
                ),
              ),
            ),
            _buildToolbar(
              context,
              onPickImages: pickImages,
              mediaCount: draft.media.length,
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(
    BuildContext context, {
    required bool canSubmit,
    required bool isSubmitting,
    required VoidCallback onSubmit,
  }) {
    return AppBar(
      backgroundColor: context.color.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.of(context).maybePop(),
        icon: Icon(Icons.close_rounded, color: context.color.textPrimary),
      ),
      title: Text(
        AppStrings.composer.title,
        style: context.text.sheetTitle,
      ),
      centerTitle: true,
      shape: Border(bottom: BorderSide(color: context.color.border)),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.md),
          child: TextButton(
            onPressed: canSubmit ? onSubmit : null,
            style: TextButton.styleFrom(
              backgroundColor: canSubmit
                  ? context.color.primary
                  : context.color.surfaceMuted,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.sm,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
            child: isSubmitting
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: context.color.textOnPrimary,
                    ),
                  )
                : Text(
                    AppStrings.composer.post,
                    style: context.text.buttonLabel.copyWith(
                      color: canSubmit
                          ? context.color.textOnPrimary
                          : context.color.textPlaceholder,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildBodyField(
    BuildContext context,
    Author viewer,
    TextEditingController bodyController,
    PostDraftController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenH,
        AppSpacing.lg,
        AppSpacing.screenH,
        0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppAvatar(
            size: 40,
            imageUrl: viewer.avatarUrl,
            initials: viewer.initials,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: TextField(
              controller: bodyController,
              onChanged: controller.setBody,
              autofocus: true,
              minLines: 4,
              maxLines: null,
              maxLength: PostDraft.maxBodyLength,
              style: context.text.body,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: AppStrings.composer.bodyPlaceholder,
                hintStyle: context.text.placeholder,
                counterText: '',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String label,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: context.text.metaStrong.copyWith(fontSize: 14)),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
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
      child: Row(
        children: [
          Icon(
            Icons.location_on_outlined,
            size: 18,
            color: context.color.iconMuted,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: TextField(
              controller: controller,
              style: context.text.input,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: AppStrings.composer.locationPlaceholder,
                hintStyle: context.text.placeholder,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.md,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar(
    BuildContext context, {
    required VoidCallback onPickImages,
    required int mediaCount,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenH,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: context.color.border)),
      ),
      child: Row(
        children: [
          AppPill(
            label: AppStrings.composer.addPhotos,
            icon: Icons.photo_library_outlined,
            onTap: onPickImages,
            foreground: context.color.textSecondary,
            borderColor: context.color.borderStrong,
          ),
          const Spacer(),
          Text(
            '$mediaCount/${PostDraft.maxMedia}',
            style: context.text.meta,
          ),
        ],
      ),
    );
  }
}
