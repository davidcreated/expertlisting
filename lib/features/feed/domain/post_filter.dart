import 'package:equatable/equatable.dart';

import 'post.dart';
import 'post_category.dart';
import 'transaction_type.dart';

class PostFilter extends Equatable {
  const PostFilter({
    this.categories = const {},
    this.transactionTypes = const {},
    this.location,
  });

  final Set<PostCategory> categories;
  final Set<TransactionType> transactionTypes;
  final String? location;

  bool get hasLocation => location != null && location!.trim().isNotEmpty;

  int get filterCount =>
      categories.length + transactionTypes.length + (hasLocation ? 1 : 0);

  bool get hasFilters => filterCount > 0;

  bool matches(Post post) {
    if (categories.isNotEmpty && !categories.contains(post.category)) {
      return false;
    }
    if (transactionTypes.isNotEmpty &&
        !transactionTypes.contains(post.transactionType)) {
      return false;
    }
    if (hasLocation) {
      final postLocation = post.location?.toLowerCase() ?? '';
      if (!postLocation.contains(location!.trim().toLowerCase())) return false;
    }
    return true;
  }

  PostFilter copyWith({
    Set<PostCategory>? categories,
    Set<TransactionType>? transactionTypes,
    String? Function()? location,
  }) {
    return PostFilter(
      categories: categories ?? this.categories,
      transactionTypes: transactionTypes ?? this.transactionTypes,
      location: location != null ? location() : this.location,
    );
  }

  Map<String, String> toQueryParameters() {
    return {
      if (categories.isNotEmpty)
        'category': categories.map((c) => c.wire).join(','),
      if (transactionTypes.isNotEmpty)
        'transactionType': transactionTypes.map((t) => t.wire).join(','),
      if (hasLocation) 'location': location!.trim(),
    };
  }

  @override
  List<Object?> get props => [categories, transactionTypes, location];
}
