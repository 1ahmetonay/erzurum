import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/social_demo_data.dart';
import '../models/user_connection_model.dart';
import '../models/user_model.dart';
import '../repositories/user_connection_repository.dart';
import 'auth_provider.dart';

final userConnectionRepositoryProvider = Provider<UserConnectionRepository>((
  ref,
) {
  return UserConnectionRepository();
});

final incomingConnectionRequestsProvider =
    StreamProvider<List<UserConnectionModel>>((ref) {
      final user = ref.watch(authStateProvider).valueOrNull;
      if (user == null) return Stream.value(const []);
      return _withDemoFallback(
        ref
            .watch(userConnectionRepositoryProvider)
            .watchIncomingRequests(user.uid),
        SocialDemoData.incomingRequests(user.uid),
      );
    });

final outgoingConnectionRequestsProvider =
    StreamProvider<List<UserConnectionModel>>((ref) {
      final user = ref.watch(authStateProvider).valueOrNull;
      if (user == null) return Stream.value(const []);
      return _withDemoFallback(
        ref
            .watch(userConnectionRepositoryProvider)
            .watchOutgoingRequests(user.uid),
        SocialDemoData.outgoingRequests(user.uid),
      );
    });

final acceptedConnectionsProvider = StreamProvider<List<UserConnectionModel>>((
  ref,
) {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return Stream.value(const []);
  return _withDemoFallback(
    ref
        .watch(userConnectionRepositoryProvider)
        .watchAcceptedConnections(user.uid),
    SocialDemoData.acceptedConnections(user.uid),
  );
});

Stream<List<UserConnectionModel>> _withDemoFallback(
  Stream<List<UserConnectionModel>> source,
  List<UserConnectionModel> demoData,
) async* {
  try {
    await for (final records in source) {
      yield records.isEmpty ? demoData : records;
    }
  } on Object {
    yield demoData;
  }
}

final userSearchQueryProvider = StateProvider.autoDispose<String>((ref) => '');

final userSearchResultsProvider = FutureProvider.autoDispose<List<UserModel>>((
  ref,
) {
  final query = ref.watch(userSearchQueryProvider);
  final user = ref.watch(authStateProvider).valueOrNull;
  return ref
      .watch(userConnectionRepositoryProvider)
      .searchUsers(query, excludeUid: user?.uid);
});

final userConnectionActionControllerProvider =
    AutoDisposeAsyncNotifierProvider<UserConnectionActionController, void>(
      UserConnectionActionController.new,
    );

class UserConnectionActionController extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> sendRequest({
    required String requesterUserId,
    required String requesterUsername,
    required String receiverUserId,
    required String receiverUsername,
  }) async {
    state = const AsyncLoading();
    try {
      await ref
          .read(userConnectionRepositoryProvider)
          .sendConnectionRequest(
            requesterUserId: requesterUserId,
            requesterUsername: requesterUsername,
            receiverUserId: receiverUserId,
            receiverUsername: receiverUsername,
          );
      state = const AsyncData(null);
    } on Object catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  Future<void> updateStatus({
    required String connectionId,
    required String userId,
    required String status,
  }) async {
    state = const AsyncLoading();
    try {
      await ref
          .read(userConnectionRepositoryProvider)
          .updateRequestStatus(
            connectionId: connectionId,
            userId: userId,
            status: status,
          );
      state = const AsyncData(null);
    } on Object catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      Error.throwWithStackTrace(error, stackTrace);
    }
  }
}
