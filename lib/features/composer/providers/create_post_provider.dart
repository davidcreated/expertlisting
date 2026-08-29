import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../feed/domain/media_item.dart';
import '../../feed/domain/post_category.dart';
import '../../feed/domain/post_draft.dart';
import '../../feed/domain/transaction_type.dart';
import '../../feed/providers/feed_provider.dart';
import '../../feed/providers/post_repository_provider.dart';

part 'create_post_provider.g.dart';

@riverpod
class PostDraftController extends _$PostDraftController {
  @override
  PostDraft build() => const PostDraft();

  void setBody(String body) => state = state.copyWith(body: body);

  void setCategory(PostCategory category) =>
      state = state.copyWith(category: category);

  void setLocation(String? location) {
    final trimmed = location?.trim();
    state = state.copyWith(
      location: () => (trimmed == null || trimmed.isEmpty) ? null : trimmed,
    );
  }

  void setTransactionType(TransactionType? type) {
    final next = state.transactionType == type ? null : type;
    state = state.copyWith(transactionType: () => next);
  }

  void addMedia(Iterable<MediaItem> items) {
    final remaining = PostDraft.maxMedia - state.media.length;
    if (remaining <= 0) return;
    state = state.copyWith(
      media: [...state.media, ...items.take(remaining)],
    );
  }

  void removeMedia(String mediaId) {
    state = state.copyWith(
      media: state.media.where((item) => item.id != mediaId).toList(),
    );
  }

  void reset() => state = const PostDraft();
}

@Riverpod(keepAlive: true)
class CreatePostAction extends _$CreatePostAction {
  @override
  FutureOr<void> build() => null;

  Future<bool> submit() async {
    final draft = ref.read(postDraftControllerProvider);
    if (!draft.canSubmit) return false;

    state = const AsyncLoading<void>();

    final result = await AsyncValue.guard(
      () => ref.read(postRepositoryProvider).createPost(draft),
    );

    if (!ref.mounted) return false;

    switch (result) {
      case AsyncError(:final error, :final stackTrace):
        state = AsyncError<void>(error, stackTrace);
        return false;
      case AsyncData(:final value):
        ref.read(feedProvider.notifier).prependPost(value);
        ref.read(postDraftControllerProvider.notifier).reset();
        state = const AsyncData<void>(null);
        return true;
      default:
        state = const AsyncData<void>(null);
        return false;
    }
  }
}
