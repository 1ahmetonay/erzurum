import 'package:atikavi_erzurum/core/utils/task_progress_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('isWithinQrCooldown', () {
    const cooldown = Duration(minutes: 10);
    final now = DateTime(2026, 6, 4, 12);

    test('returns true when QR was scanned 3 minutes ago', () {
      expect(
        isWithinQrCooldown(
          now.subtract(const Duration(minutes: 3)),
          now,
          cooldown,
        ),
        isTrue,
      );
    });

    test('returns true when QR was scanned 9 minutes 59 seconds ago', () {
      expect(
        isWithinQrCooldown(
          now.subtract(const Duration(minutes: 9, seconds: 59)),
          now,
          cooldown,
        ),
        isTrue,
      );
    });

    test('returns false when QR was scanned 10 minutes 1 second ago', () {
      expect(
        isWithinQrCooldown(
          now.subtract(const Duration(minutes: 10, seconds: 1)),
          now,
          cooldown,
        ),
        isFalse,
      );
    });

    test('returns false when there is no previous log', () {
      expect(isWithinQrCooldown(null, now, cooldown), isFalse);
    });
  });
}
