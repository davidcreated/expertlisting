class CountFormatter {
  const CountFormatter._();

  static String compact(int value) {
    if (value < 0) return '0';
    if (value < 1000) return '$value';
    if (value < 1000000) return '${_trim(value / 1000)}K';
    return '${_trim(value / 1000000)}M';
  }

  static String _trim(double value) {
    if (value >= 100) return value.round().toString();
    final rounded = (value * 10).round() / 10;
    if (rounded == rounded.roundToDouble()) return rounded.round().toString();
    return rounded.toStringAsFixed(1);
  }
}
