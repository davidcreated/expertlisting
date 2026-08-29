import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/post_category.dart';
import '../domain/post_filter.dart';
import '../domain/transaction_type.dart';

part 'post_filter_provider.g.dart';

@Riverpod(keepAlive: true)
class PostFilterController extends _$PostFilterController {
  @override
  PostFilter build() => const PostFilter();

  void toggleCategory(PostCategory category) {
    final next = <PostCategory>{...state.categories};
    if (!next.remove(category)) next.add(category);
    state = state.copyWith(categories: next);
  }

  void toggleTransactionType(TransactionType type) {
    final next = <TransactionType>{...state.transactionTypes};
    if (!next.remove(type)) next.add(type);
    state = state.copyWith(transactionTypes: next);
  }

  void setLocation(String? location) {
    final trimmed = location?.trim();
    state = state.copyWith(
      location: () => (trimmed == null || trimmed.isEmpty) ? null : trimmed,
    );
  }

  void replace(PostFilter filter) => state = filter;

  void clearAll() => state = const PostFilter();
}
