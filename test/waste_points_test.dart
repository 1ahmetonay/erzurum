import 'package:atikavi_erzurum/core/utils/task_progress_resolver.dart';
import 'package:atikavi_erzurum/models/waste_log_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('calculateWastePoints', () {
    test('maps supported waste types to Dadas points', () {
      expect(calculateWastePoints(WasteTypes.plastic), 10);
      expect(calculateWastePoints(WasteTypes.paper), 10);
      expect(calculateWastePoints(WasteTypes.glass), 12);
      expect(calculateWastePoints(WasteTypes.battery), 20);
      expect(calculateWastePoints(WasteTypes.oil), 25);
      expect(calculateWastePoints(WasteTypes.electronic), 30);
    });

    test('falls back to 10 points for unknown waste types', () {
      expect(calculateWastePoints('unknown'), 10);
    });
  });
}
