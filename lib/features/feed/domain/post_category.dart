enum PostCategory {
  property('PROPERTY'),
  request('REQUEST'),
  general('GENERAL');

  const PostCategory(this.wire);

  final String wire;

  static PostCategory? fromWire(String? value) {
    if (value == null) return null;
    final normalized = value.trim().toUpperCase();
    for (final category in values) {
      if (category.wire == normalized) return category;
    }
    return null;
  }

  String get label => switch (this) {
    PostCategory.property => 'Property',
    PostCategory.request => 'Request',
    PostCategory.general => 'General',
  };
}
