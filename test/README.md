# Test notes

Normal `flutter test` runs the widget smoke test plus focused pure unit tests
for waste point mapping, task progress resolution, one-time task bonus rules,
QR cooldown decisions, and reward redemption eligibility/coupon helper logic.

No Firestore emulator test is currently included. The project does not yet have
an emulator test harness or fake Firestore dependency configured, so repository
transaction decisions are covered through `task_progress_resolver.dart`, which
is also used by the production repositories.

Run:

```bash
dart format lib test
flutter analyze
flutter test
```
