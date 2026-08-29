import 'package:equatable/equatable.dart';

import 'media_item.dart';
import 'post_category.dart';
import 'transaction_type.dart';

class PostDraft extends Equatable {
  const PostDraft({
    this.body = '',
    this.category = PostCategory.general,
    this.location,
    this.transactionType,
    this.media = const [],
  });

  final String body;
  final PostCategory category;
  final String? location;
  final TransactionType? transactionType;
  final List<MediaItem> media;

  static const int maxMedia = 4;
  static const int maxBodyLength = 2000;

  String get trimmedBody => body.trim();

  bool get hasBody => trimmedBody.isNotEmpty;

  bool get hasMedia => media.isNotEmpty;

  bool get canAddMedia => media.length < maxMedia;

  bool get canSubmit => (hasBody || hasMedia) && !isOverLength;

  bool get isOverLength => trimmedBody.length > maxBodyLength;

  int get remainingCharacters => maxBodyLength - trimmedBody.length;

  PostDraft copyWith({
    String? body,
    PostCategory? category,
    String? Function()? location,
    TransactionType? Function()? transactionType,
    List<MediaItem>? media,
  }) {
    return PostDraft(
      body: body ?? this.body,
      category: category ?? this.category,
      location: location != null ? location() : this.location,
      transactionType: transactionType != null
          ? transactionType()
          : this.transactionType,
      media: media ?? this.media,
    );
  }

  @override
  List<Object?> get props => [body, category, location, transactionType, media];
}
