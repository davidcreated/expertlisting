import 'dart:async';

import 'package:expertlisting/core/config/app_env.dart';
import 'package:expertlisting/features/feed/domain/fake_post_repository.dart';
import 'package:expertlisting/features/feed/providers/feed_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../helpers/test_container.dart';

void main() {
  group('Feed pagination', () {
    test('first page is limited to the configured page size', () async {
      final container = createContainer();

      final first = await container.read(feedProvider.future);

      expect(first.items, hasLength(AppEnv.feedPageSize));
      expect(first.hasReachedMax, isFalse);
      expect(first.nextCursor, first.items.last.id);
    });

    test('loadMore appends the next page without duplicating items', () async {
      final container = createContainer();
      final first = await container.read(feedProvider.future);
      final notifier = container.read(feedProvider.notifier);

      await notifier.loadMore();

      final after = container.read(feedProvider).value!;

      expect(after.items.length, greaterThan(first.items.length));

      final ids = after.items.map((post) => post.id).toList();
      expect(ids.toSet().length, ids.length);

      expect(
        after.items.take(first.items.length).map((p) => p.id),
        first.items.map((p) => p.id),
      );
    });

    test('paging to the end sets hasReachedMax and clears the cursor',
        () async {
      final container = createContainer();
      await container.read(feedProvider.future);
      final notifier = container.read(feedProvider.notifier);

      for (var attempt = 0; attempt < 10; attempt++) {
        final state = container.read(feedProvider).value!;
        if (state.hasReachedMax) break;
        await notifier.loadMore();
      }

      final finalState = container.read(feedProvider).value!;

      expect(finalState.hasReachedMax, isTrue);
      expect(finalState.nextCursor, isNull);
    });

    test('loadMore is a no-op once the end is reached', () async {
      final container = createContainer();
      await container.read(feedProvider.future);
      final notifier = container.read(feedProvider.notifier);

      for (var attempt = 0; attempt < 10; attempt++) {
        final state = container.read(feedProvider).value!;
        if (state.hasReachedMax) break;
        await notifier.loadMore();
      }

      final before = container.read(feedProvider).value!;
      await notifier.loadMore();
      final after = container.read(feedProvider).value!;

      expect(after.items.length, before.items.length);
    });

    test('a concurrent loadMore does not fetch the same page twice', () async {
      final container = createContainer();
      final first = await container.read(feedProvider.future);
      final notifier = container.read(feedProvider.notifier);

      await Future.wait([notifier.loadMore(), notifier.loadMore()]);

      final after = container.read(feedProvider).value!;
      final ids = after.items.map((post) => post.id).toList();

      expect(ids.toSet().length, ids.length);
      expect(
        after.items.length,
        lessThanOrEqualTo(first.items.length + AppEnv.feedPageSize),
      );
    });

    test('a failing page surfaces loadMoreFailed and keeps existing items',
        () async {
      final repository = buildFakeRepository();
      final container = createContainer(repository: repository);

      final first = await container.read(feedProvider.future);
      repository.failures.feed = true;

      await container.read(feedProvider.notifier).loadMore();

      final after = container.read(feedProvider).value!;

      expect(after.loadMoreFailed, isTrue);
      expect(after.isLoadingMore, isFalse);
      expect(after.items.length, first.items.length);
    });

    test('first-load failure leaves the state in error with no value',
        () async {
      final repository = buildFakeRepository(
        failures: FakeFailureSwitches(feed: true),
      );
      final container = createContainer(repository: repository);

      final reachedError = Completer<void>();
      container.listen(feedProvider, (previous, next) {
        if (next.hasError && !reachedError.isCompleted) {
          reachedError.complete();
        }
      }, fireImmediately: true);

      await reachedError.future.timeout(const Duration(seconds: 5));

      expect(container.read(feedProvider).hasError, isTrue);
      expect(container.read(feedProvider).value, isNull);
    });
  });
}
