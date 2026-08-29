class AppStrings {
  const AppStrings._();

  static const AppErrorStrings errors = AppErrorStrings._();
  static const AppFeedStrings feed = AppFeedStrings._();
  static const AppComposerStrings composer = AppComposerStrings._();
  static const AppCommentStrings comments = AppCommentStrings._();
  static const AppFilterStrings filters = AppFilterStrings._();
  static const AppNavStrings nav = AppNavStrings._();
  static const AppCommonStrings common = AppCommonStrings._();
}

class AppCommonStrings {
  const AppCommonStrings._();

  String get tryAgain => 'Try again';
  String get retry => 'Retry';
  String get cancel => 'Cancel';
  String get done => 'Done';
  String get apply => 'Apply';
  String get clearAll => 'Clear all';
  String get comingSoon => 'Coming soon';
  String get comingSoonBody =>
      'This section is not part of the current build yet.';
}

class AppErrorStrings {
  const AppErrorStrings._();

  String get noInternetTitle => 'No connection';
  String get noInternetMessage =>
      'Check your internet connection and try again.';
  String get networkTitle => 'Connection problem';
  String get networkMessage => 'We could not reach the server. Try again.';
  String get serverTitle => 'Something went wrong';
  String get serverMessage =>
      'The server could not complete that request. Try again.';
  String get parsingTitle => 'Unexpected data';
  String get parsingMessage => 'We could not read the response from the server.';
  String get unexpectedTitle => 'Something went wrong';
  String get unexpectedMessage => 'Please try again in a moment.';
  String get likeFailed => 'Could not update your like. Try again.';
  String get bookmarkFailed => 'Could not update your bookmark. Try again.';
  String get commentFailed => 'Your comment was not posted. Try again.';
  String get postFailed => 'Your post was not published. Try again.';
  String get loadMoreFailed => 'Could not load more posts.';
}

class AppFeedStrings {
  const AppFeedStrings._();

  String get yourStory => 'Your Story';
  String get filters => 'Filters';
  String get composerPlaceholder =>
      'Share a property, Make a request or say something...';
  String get emptyTitle => 'Nothing here yet';
  String get emptyMessage => 'New posts from your network will show up here.';
  String get emptyFilteredTitle => 'No posts match those filters';
  String get emptyFilteredMessage => 'Try widening your search.';
  String get justNow => 'Just Now';

  String views(String count) => '$count Views';

  String viewAllComments(int count) => 'View all $count comments';
}

class AppComposerStrings {
  const AppComposerStrings._();

  String get title => 'Create post';
  String get post => 'Post';
  String get bodyPlaceholder =>
      'Share a property, Make a request or say something...';
  String get addPhotos => 'Photos';
  String get addLocation => 'Location';
  String get locationPlaceholder => 'Add a location';
  String get transactionType => 'Transaction type';
  String get category => 'Post type';
  String get mediaLimitReached => 'You can attach up to 4 photos.';
  String get discardTitle => 'Discard this post?';
  String get discardMessage => 'Your draft will not be saved.';
  String get discard => 'Discard';
  String get keepEditing => 'Keep editing';
}

class AppCommentStrings {
  const AppCommentStrings._();

  String get title => 'Comments';
  String get placeholder => 'Add a comment...';
  String get send => 'Send';
  String get emptyTitle => 'No comments yet';
  String get emptyMessage => 'Be the first to say something.';
  String get loadMoreFailed => 'Could not load more comments.';
}

class AppFilterStrings {
  const AppFilterStrings._();

  String get title => 'Filters';
  String get category => 'Post type';
  String get transactionType => 'Transaction type';
  String get location => 'Location';
  String get locationPlaceholder => 'Any location';

  String showResults(int count) => 'Show results ($count)';
}

class AppNavStrings {
  const AppNavStrings._();

  String get feed => 'Feed';
  String get search => 'Search';
  String get list => 'List';
  String get notification => 'Notification';
  String get profile => 'Profile';
}
