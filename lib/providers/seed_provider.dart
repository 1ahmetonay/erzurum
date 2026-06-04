import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/seed_repository.dart';

final seedRepositoryProvider = Provider<SeedRepository>((ref) {
  return SeedRepository();
});

final seedControllerProvider =
    AutoDisposeAsyncNotifierProvider<SeedController, void>(SeedController.new);

class SeedController extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> seedAll() async {
    state = const AsyncLoading();
    try {
      await ref.read(seedRepositoryProvider).seedAll();
      state = const AsyncData(null);
    } on Object catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      Error.throwWithStackTrace(error, stackTrace);
    }
  }
}
