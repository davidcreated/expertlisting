import '../constants/app_strings.dart';

class RelativeTime {
  const RelativeTime._();

  static const List<String> _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static String format(DateTime value, {DateTime? now}) {
    final reference = now ?? DateTime.now();
    final elapsed = reference.difference(value);

    if (elapsed.isNegative || elapsed.inSeconds < 60) {
      return AppStrings.feed.justNow;
    }
    if (elapsed.inMinutes < 60) return '${elapsed.inMinutes}m';
    if (elapsed.inHours < 24) return '${elapsed.inHours}h';
    if (elapsed.inDays < 7) return '${elapsed.inDays}d';
    if (elapsed.inDays < 35) return '${(elapsed.inDays / 7).floor()}w';

    return '${value.day} ${_months[value.month - 1]}';
  }
}
