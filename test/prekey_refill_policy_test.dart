import 'package:flutter_test/flutter_test.dart';
import 'package:tureon/core/crypto/prekey_refill_policy.dart';

void main() {
  test(
    'automatically refills only when count falls below server watermark',
    () async {
      var refillCount = 0;

      final refilled = await refillOneTimePrekeysIfLow(
        count: 9,
        lowWatermark: 10,
        refill: () async {
          refillCount++;
        },
      );
      final kept = await refillOneTimePrekeysIfLow(
        count: 10,
        lowWatermark: 10,
        refill: () async {
          refillCount++;
        },
      );

      expect(refilled, isTrue);
      expect(kept, isFalse);
      expect(refillCount, 1);
    },
  );
}
