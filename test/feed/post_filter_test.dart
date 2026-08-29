import 'package:expertlisting/features/feed/domain/post_category.dart';
import 'package:expertlisting/features/feed/domain/post_filter.dart';
import 'package:expertlisting/features/feed/domain/transaction_type.dart';
import 'package:expertlisting/features/feed/providers/feed_provider.dart';
import 'package:expertlisting/features/feed/providers/post_filter_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../helpers/test_container.dart';

void main() {
  group('PostFilter', () {
    test('an empty filter matches everything and counts zero', () {
      const filter = PostFilter();

      expect(filter.hasFilters, isFalse);
      expect(filter.filterCount, 0);
      expect(filter.toQueryParameters(), isEmpty);
    });

    test('filterCount counts each active dimension', () {
      const filter = PostFilter(
        categories: {PostCategory.property, PostCategory.request},
        transactionTypes: {TransactionType.forRent},
        location: 'Lekki',
      );

      expect(filter.filterCount, 4);
      expect(filter.hasFilters, isTrue);
    });

    test('query parameters send wire values, never display labels', () {
      const filter = PostFilter(
        categories: {PostCategory.property},
        transactionTypes: {TransactionType.lookingToBuy},
        location: '  Lekki  ',
      );

      final params = filter.toQueryParameters();

      expect(params['category'], 'PROPERTY');
      expect(params['transactionType'], 'LOOKING_TO_BUY');
      expect(params['location'], 'Lekki');
    });

    test('a blank location is not treated as an active filter', () {
      const filter = PostFilter(location: '   ');

      expect(filter.hasLocation, isFalse);
      expect(filter.filterCount, 0);
      expect(filter.toQueryParameters(), isEmpty);
    });
  });

  group('filter controller', () {
    test('toggling a category adds then removes it', () {
      final container = createContainer();
      final notifier = container.read(postFilterControllerProvider.notifier);

      notifier.toggleCategory(PostCategory.property);
      expect(
        container.read(postFilterControllerProvider).categories,
        {PostCategory.property},
      );

      notifier.toggleCategory(PostCategory.property);
      expect(
        container.read(postFilterControllerProvider).categories,
        isEmpty,
      );
    });

    test('clearAll resets every dimension', () {
      final container = createContainer();
      final notifier = container.read(postFilterControllerProvider.notifier);

      notifier.toggleCategory(PostCategory.request);
      notifier.toggleTransactionType(TransactionType.forSale);
      notifier.setLocation('Yaba');

      expect(container.read(postFilterControllerProvider).filterCount, 3);

      notifier.clearAll();

      expect(container.read(postFilterControllerProvider).hasFilters, isFalse);
    });
  });

  group('filters drive the feed', () {
    test('applying a category filter narrows the feed', () async {
      final container = createContainer();
      final unfiltered = await container.read(feedProvider.future);

      container
          .read(postFilterControllerProvider.notifier)
          .toggleCategory(PostCategory.request);

      final filtered = await container.read(feedProvider.future);

      expect(filtered.items, isNotEmpty);
      expect(
        filtered.items.every((post) => post.category == PostCategory.request),
        isTrue,
      );
      expect(filtered.items.length, lessThan(unfiltered.items.length));
    });

    test('changing a filter resets pagination rather than appending',
        () async {
      final container = createContainer();
      await container.read(feedProvider.future);
      await container.read(feedProvider.notifier).loadMore();

      final paged = container.read(feedProvider).value!;
      expect(paged.items.length, greaterThan(10));

      container
          .read(postFilterControllerProvider.notifier)
          .toggleCategory(PostCategory.property);

      final refiltered = await container.read(feedProvider.future);

      expect(refiltered.items.length, lessThan(paged.items.length));
      expect(
        refiltered.items.every((post) => post.category == PostCategory.property),
        isTrue,
      );
    });

    test('a transaction type filter narrows the feed', () async {
      final container = createContainer();

      container
          .read(postFilterControllerProvider.notifier)
          .toggleTransactionType(TransactionType.forSale);

      final filtered = await container.read(feedProvider.future);

      expect(filtered.items, isNotEmpty);
      expect(
        filtered.items
            .every((post) => post.transactionType == TransactionType.forSale),
        isTrue,
      );
    });

    test('a filter matching nothing yields an empty feed, not an error',
        () async {
      final container = createContainer();

      container
          .read(postFilterControllerProvider.notifier)
          .setLocation('Nowhere At All');

      final filtered = await container.read(feedProvider.future);

      expect(filtered.items, isEmpty);
      expect(filtered.hasReachedMax, isTrue);
      expect(container.read(feedProvider).hasError, isFalse);
    });
  });
}
