import 'package:atikavi_erzurum/core/utils/redemption_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('canRedeemReward', () {
    test('returns true when points are enough and reward is active', () {
      expect(
        canRedeemReward(
          userPoints: 500,
          requiredPoints: 250,
          isActive: true,
          stockCount: 3,
        ),
        isTrue,
      );
    });

    test('returns false when points are not enough', () {
      expect(
        canRedeemReward(
          userPoints: 100,
          requiredPoints: 250,
          isActive: true,
          stockCount: 3,
        ),
        isFalse,
      );
      expect(
        getRedeemDisabledReason(
          userPoints: 100,
          requiredPoints: 250,
          isActive: true,
          stockCount: 3,
        ),
        'Bu ödül için yeterli Dadaş Puanın yok.',
      );
    });

    test('returns false when reward is inactive', () {
      expect(
        canRedeemReward(
          userPoints: 500,
          requiredPoints: 250,
          isActive: false,
          stockCount: 3,
        ),
        isFalse,
      );
    });

    test('returns false when stock is zero', () {
      expect(
        canRedeemReward(
          userPoints: 500,
          requiredPoints: 250,
          isActive: true,
          stockCount: 0,
        ),
        isFalse,
      );
      expect(
        getRedeemDisabledReason(
          userPoints: 500,
          requiredPoints: 250,
          isActive: true,
          stockCount: 0,
        ),
        'Bu ödülün stoğu kalmadı.',
      );
    });

    test('treats null stock as unlimited', () {
      expect(
        canRedeemReward(
          userPoints: 500,
          requiredPoints: 250,
          isActive: true,
          stockCount: null,
        ),
        isTrue,
      );
    });
  });

  test('calculateRemainingPoints subtracts required points', () {
    expect(calculateRemainingPoints(500, 250), 250);
  });

  test('generateCouponCode uses ATIKAVI prefix and non-empty suffix', () {
    final code = generateCouponCode();

    expect(code, startsWith('ATIKAVI-'));
    expect(code.length, greaterThan('ATIKAVI-'.length));
  });
}
