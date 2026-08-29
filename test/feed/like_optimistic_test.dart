import 'package:expertlisting/core/session/current_user_provider.dart';
import 'package:expertlisting/features/feed/domain/fake_post_repository.dart';
import 'package:expertlisting/features/feed/providers/feed_provider.dart';
import 'package:expertlisting/features/feed/providers/post_interaction_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../helpers/test_container.dart';

void main() {
  group('optimistic like', () {
    test('a successful like increments the count and marks the viewer',
        () async {
      final container = createContainer();
      final feed = await container.read(feedProvider.future);
      final post = feed.items.first;

      expect(post.isLiked, isFalse);
      final startingCount = post.likeCount;

      await container.read(postLikeActionProvider.notifier).toggle(post);

      final updated = container
          .read(feedProvider)
          .value!
          .items
          .firstWhere((item) => item.id == post.id);

      expect(updated.isLiked, isTrue);
      expect(updated.likeCount, startingCount + 1);
      expect(
        updated.likedBy.first.id,
        container.read(currentUserProvider).id,
      );
      expect(container.read(postLikeActionProvider).hasError, isFalse);
    });

    test('liking twice returns to the original state', () async {
      final container = createContainer();
      final feed = await container.read(feedProvider.future);
      final post = feed.items.first;
      final notifier = container.read(postLikeActionProvider.notifier);

      await notifier.toggle(post);

      final liked = container
          .read(feedProvider)
          .value!
          .items
          .firstWhere((item) => item.id == post.id);

      await notifier.toggle(liked);

      final unliked = container
          .read(feedProvider)
          .value!
          .items
          .firstWhere((item) => item.id == post.id);

      expect(unliked.isLiked, post.isLiked);
      expect(unliked.likeCount, post.likeCount);
      expect(
        unliked.likedBy.map((author) => author.id),
        post.likedBy.map((author) => author.id),
      );
    });

    test('the UI updates before the request resolves', () async {
      final repository = FakePostRepository(
        currentUser: kMockCurrentUser,
        latency: const Duration(milliseconds: 80),
        now: DateTime(2026, 8, 28, 12),
      );
      final container = createContainer(repository: repository);

      final feed = await container.read(feedProvider.future);
      final post = feed.items.first;

      final pending = container
          .read(postLikeActionProvider.notifier)
          .toggle(post);

      final immediately = container
          .read(feedProvider)
          .value!
          .items
          .firstWhere((item) => item.id == post.id);

      expect(immediately.isLiked, isTrue);
      expect(immediately.likeCount, post.likeCount + 1);

      await pending;
    });

    test('a failed like rolls the card back and reports the error', () async {
      final repository = buildFakeRepository(
        failures: FakeFailureSwitches(like: true),
      );
      final container = createContainer(repository: repository);

      final feed = await container.read(feedProvider.future);
      final post = feed.items.first;

      await container.read(postLikeActionProvider.notifier).toggle(post);

      final rolledBack = container
          .read(feedProvider)
          .value!
          .items
          .firstWhere((item) => item.id == post.id);

      expect(rolledBack.isLiked, post.isLiked);
      expect(rolledBack.likeCount, post.likeCount);
      expect(
        rolledBack.likedBy.map((author) => author.id),
        post.likedBy.map((author) => author.id),
      );
      expect(container.read(postLikeActionProvider).hasError, isTrue);
    });

    test('the server response wins over the optimistic guess', () async {
      final container = createContainer();
      final feed = await container.read(feedProvider.future);
      final post = feed.items.firstWhere((item) => item.likeCount > 1);

      await container.read(postLikeActionProvider.notifier).toggle(post);

      final updated = container
          .read(feedProvider)
          .value!
          .items
          .firstWhere((item) => item.id == post.id);

      final repositoryPost = (container.read(feedProvider).value!.items)
          .firstWhere((item) => item.id == post.id);

      expect(updated.likeCount, repositoryPost.likeCount);
      expect(updated.isLiked, repositoryPost.isLiked);
    });
  });

  group('optimistic bookmark', () {
    test('a failed bookmark rolls the card back', () async {
      final repository = buildFakeRepository(
        failures: FakeFailureSwitches(bookmark: true),
      );
      final container = createContainer(repository: repository);

      final feed = await container.read(feedProvider.future);
      final post = feed.items.first;

      await container.read(postBookmarkActionProvider.notifier).toggle(post);

      final rolledBack = container
          .read(feedProvider)
          .value!
          .items
          .firstWhere((item) => item.id == post.id);

      expect(rolledBack.isBookmarked, post.isBookmarked);
      expect(rolledBack.bookmarkCount, post.bookmarkCount);
      expect(container.read(postBookmarkActionProvider).hasError, isTrue);
    });
  });
}
