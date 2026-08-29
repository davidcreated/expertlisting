import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/session/current_user_provider.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/widgets/app_avatar.dart';
import '../providers/comments_provider.dart';

class CommentComposer extends HookConsumerWidget {
  const CommentComposer({required this.postId, super.key});

  final String postId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewer = ref.watch(currentUserProvider);
    final isSubmitting = ref.watch(addCommentActionProvider).isLoading;

    final controller = useTextEditingController();
    final text = useValueListenable(controller).text;
    final canSubmit = text.trim().isNotEmpty && !isSubmitting;

    Future<void> submit() async {
      if (!canSubmit) return;
      final body = controller.text;
      controller.clear();
      await ref
          .read(addCommentActionProvider.notifier)
          .submit(postId: postId, body: body);
    }

    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.screenH,
        right: AppSpacing.screenH,
        top: AppSpacing.md,
        bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: context.color.surface,
        border: Border(top: BorderSide(color: context.color.border)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          AppAvatar(
            size: 34,
            imageUrl: viewer.avatarUrl,
            initials: viewer.initials,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minHeight: 40),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: context.color.surfaceMuted,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => submit(),
                style: context.text.input,
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  hintText: AppStrings.comments.placeholder,
                  hintStyle: context.text.placeholder,
                  contentPadding: const EdgeInsets.symmetric(vertical: 9),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          _buildSendButton(context, canSubmit: canSubmit, onTap: submit),
        ],
      ),
    );
  }

  Widget _buildSendButton(
    BuildContext context, {
    required bool canSubmit,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: canSubmit ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: canSubmit ? context.color.primary : context.color.surfaceMuted,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.arrow_upward_rounded,
          size: 20,
          color: canSubmit
              ? context.color.textOnPrimary
              : context.color.textPlaceholder,
        ),
      ),
    );
  }
}
