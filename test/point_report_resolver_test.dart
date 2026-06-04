import 'package:atikavi_erzurum/core/utils/point_report_resolver.dart';
import 'package:atikavi_erzurum/models/point_report_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('isWithinReportCooldown', () {
    const cooldown = Duration(minutes: 30);
    final now = DateTime(2026, 6, 4, 12);

    test('returns true when report was sent 10 minutes ago', () {
      expect(
        isWithinReportCooldown(
          now.subtract(const Duration(minutes: 10)),
          now,
          cooldown,
        ),
        isTrue,
      );
    });

    test('returns true when report was sent 29 minutes 59 seconds ago', () {
      expect(
        isWithinReportCooldown(
          now.subtract(const Duration(minutes: 29, seconds: 59)),
          now,
          cooldown,
        ),
        isTrue,
      );
    });

    test('returns false when report was sent 30 minutes 1 second ago', () {
      expect(
        isWithinReportCooldown(
          now.subtract(const Duration(minutes: 30, seconds: 1)),
          now,
          cooldown,
        ),
        isFalse,
      );
    });

    test('returns false when there is no previous report', () {
      expect(isWithinReportCooldown(null, now, cooldown), isFalse);
    });
  });

  group('isValidReportType', () {
    test('returns true for known report types', () {
      expect(isValidReportType(PointReportTypes.broken), isTrue);
      expect(isValidReportType(PointReportTypes.full), isTrue);
      expect(isValidReportType(PointReportTypes.missing), isTrue);
      expect(isValidReportType(PointReportTypes.wrongLocation), isTrue);
      expect(isValidReportType(PointReportTypes.other), isTrue);
    });

    test('returns false for unknown report types', () {
      expect(isValidReportType('unknown'), isFalse);
    });
  });

  group('reportTypeLabel', () {
    test('returns Turkish labels', () {
      expect(reportTypeLabel(PointReportTypes.broken), 'Bozuk');
      expect(reportTypeLabel(PointReportTypes.full), 'Dolu');
      expect(reportTypeLabel(PointReportTypes.missing), 'Eksik');
      expect(reportTypeLabel(PointReportTypes.wrongLocation), 'Konum yanlış');
      expect(reportTypeLabel(PointReportTypes.other), 'Diğer');
      expect(reportTypeLabel('unknown'), 'Bilinmeyen');
    });
  });
}
