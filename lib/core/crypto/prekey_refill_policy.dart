Future<bool> refillOneTimePrekeysIfLow({
  required int count,
  required int lowWatermark,
  required Future<void> Function() refill,
}) async {
  if (count < 0 || lowWatermark < 0) {
    throw ArgumentError('Pre-key counts and watermark cannot be negative.');
  }
  if (count >= lowWatermark) return false;
  await refill();
  return true;
}
