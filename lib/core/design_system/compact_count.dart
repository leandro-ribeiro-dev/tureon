/// Formats large member counts for constrained labels such as chat subtitles.
String formatCompactCount(int value) {
  if (value < 1000) return value.toString();
  final scaled = value >= 1000000 ? value / 1000000 : value / 1000;
  final suffix = value >= 1000000 ? 'M' : 'k';
  final decimals = scaled >= 10 ? 0 : 1;
  final formatted = scaled
      .toStringAsFixed(decimals)
      .replaceFirst(RegExp(r'\.0$'), '');
  return '$formatted$suffix';
}
