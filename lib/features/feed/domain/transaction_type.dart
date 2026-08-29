import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

enum TransactionType {
  forSale('FOR_SALE'),
  forRent('FOR_RENT'),
  lookingToBuy('LOOKING_TO_BUY'),
  lookingToRent('LOOKING_TO_RENT');

  const TransactionType(this.wire);

  final String wire;

  static TransactionType? fromWire(String? value) {
    if (value == null) return null;
    final normalized = value.trim().toUpperCase();
    for (final type in values) {
      if (type.wire == normalized) return type;
    }
    return null;
  }

  String get label => switch (this) {
    TransactionType.forSale => 'For Sale',
    TransactionType.forRent => 'For Rent',
    TransactionType.lookingToBuy => 'Looking to Buy',
    TransactionType.lookingToRent => 'Looking to Rent',
  };

  IconData get icon => switch (this) {
    TransactionType.forSale => Icons.local_offer_outlined,
    TransactionType.lookingToBuy => Icons.local_offer_outlined,
    TransactionType.forRent => Icons.vpn_key_outlined,
    TransactionType.lookingToRent => Icons.vpn_key_outlined,
  };

  Color get foreground => switch (this) {
    TransactionType.forSale => AppColors.blue,
    TransactionType.forRent => AppColors.green,
    TransactionType.lookingToBuy => AppColors.purple,
    TransactionType.lookingToRent => AppColors.amber,
  };

  Color get background => switch (this) {
    TransactionType.forSale => AppColors.blueSurface,
    TransactionType.forRent => AppColors.greenSurface,
    TransactionType.lookingToBuy => AppColors.purpleSurface,
    TransactionType.lookingToRent => AppColors.amberSurface,
  };
}
