import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/social_demo_seed_service.dart';

final socialDemoSeedServiceProvider = Provider<SocialDemoSeedService>((ref) {
  return SocialDemoSeedService();
});

final socialDemoSeedControllerProvider =
    AutoDisposeAsyncNotifierProvider<SocialDemoSeedController, void>(
      SocialDemoSeedController.new,
    );

class SocialDemoSeedController extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> seedSocialDemoData() async {
    state = const AsyncLoading();
    try {
      await ref.read(socialDemoSeedServiceProvider).seedSocialDemoData();
      state = const AsyncData(null);
    } on Object catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  Future<void> clearSocialDemoData() async {
    state = const AsyncLoading();
    try {
      await ref.read(socialDemoSeedServiceProvider).clearSocialDemoData();
      state = const AsyncData(null);
    } on Object catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      Error.throwWithStackTrace(error, stackTrace);
    }
  }
}
