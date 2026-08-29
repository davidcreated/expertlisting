class AppAssets {
  const AppAssets._();

  static const String logo = 'assets/images/logo.svg';
  static const String propertyCard = 'assets/images/property_card.png';

  static const String iconComments = 'assets/icons/comments.png';
  static const String iconFeed = 'assets/icons/feed.png';
  static const String iconFilter = 'assets/icons/filter.png';
  static const String iconLike = 'assets/icons/like.png';
  static const String iconList = 'assets/icons/list.png';
  static const String iconMailbox = 'assets/icons/mailbox.png';
  static const String iconMapPin = 'assets/icons/map_pin.png';
  static const String iconNotification = 'assets/icons/notification.png';
  static const String iconProfile = 'assets/icons/profile.png';
  static const String iconSave = 'assets/icons/save.png';
  static const String iconSearch = 'assets/icons/search.png';
  static const String iconShare = 'assets/icons/share.png';

  static const String assetScheme = 'asset://';

  static bool isAssetUrl(String url) => url.startsWith(assetScheme);

  static String assetPathOf(String url) =>
      url.substring(assetScheme.length);
}
