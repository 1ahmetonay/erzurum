import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/social_demo_data.dart';
import '../models/cleanup_group_model.dart';
import '../models/group_invitation_model.dart';
import '../repositories/cleanup_group_repository.dart';
import 'auth_provider.dart';

final cleanupGroupRepositoryProvider = Provider<CleanupGroupRepository>((ref) {
  return CleanupGroupRepository();
});

final cleanupGroupsForEventProvider =
    StreamProvider.family<List<CleanupGroupModel>, String>((ref, eventId) {
      final user = ref.watch(authStateProvider).valueOrNull;
      if (user == null) return Stream.value(const []);
      return _withGroupDemoFallback(
        ref.watch(cleanupGroupRepositoryProvider).watchGroupsForEvent(eventId),
        SocialDemoData.groupsForEvent(eventId, user.uid),
      );
    });

final cleanupGroupDetailProvider =
    StreamProvider.family<CleanupGroupModel?, String>((ref, groupId) {
      final user = ref.watch(authStateProvider).valueOrNull;
      if (user != null && SocialDemoData.isDemoId(groupId)) {
        return Stream.value(SocialDemoData.groupById(groupId, user.uid));
      }
      return ref.watch(cleanupGroupRepositoryProvider).watchGroup(groupId);
    });

final incomingGroupInvitationsProvider =
    StreamProvider<List<GroupInvitationModel>>((ref) {
      final user = ref.watch(authStateProvider).valueOrNull;
      if (user == null) return Stream.value(const []);
      return _withInvitationDemoFallback(
        ref
            .watch(cleanupGroupRepositoryProvider)
            .watchIncomingInvitations(user.uid),
        SocialDemoData.incomingInvitations(user.uid),
      );
    });

Stream<List<CleanupGroupModel>> _withGroupDemoFallback(
  Stream<List<CleanupGroupModel>> source,
  List<CleanupGroupModel> demoData,
) async* {
  try {
    await for (final records in source) {
      yield records.isEmpty ? demoData : records;
    }
  } on Object {
    yield demoData;
  }
}

Stream<List<GroupInvitationModel>> _withInvitationDemoFallback(
  Stream<List<GroupInvitationModel>> source,
  List<GroupInvitationModel> demoData,
) async* {
  try {
    await for (final records in source) {
      yield records.isEmpty ? demoData : records;
    }
  } on Object {
    yield demoData;
  }
}

final cleanupGroupActionControllerProvider =
    AutoDisposeAsyncNotifierProvider<CleanupGroupActionController, void>(
      CleanupGroupActionController.new,
    );

class CleanupGroupActionController extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<String> createGroup(CleanupGroupModel group) async {
    state = const AsyncLoading();
    try {
      final id = await ref
          .read(cleanupGroupRepositoryProvider)
          .createGroup(group);
      state = const AsyncData(null);
      return id;
    } on Object catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  Future<void> joinGroup({
    required String groupId,
    required String userId,
  }) async {
    await _run(() {
      return ref
          .read(cleanupGroupRepositoryProvider)
          .joinGroup(groupId: groupId, userId: userId);
    });
  }

  Future<void> leaveGroup({
    required String groupId,
    required String userId,
  }) async {
    await _run(() {
      return ref
          .read(cleanupGroupRepositoryProvider)
          .leaveGroup(groupId: groupId, userId: userId);
    });
  }

  Future<void> invite({
    required CleanupGroupModel group,
    required String invitedByUserId,
    required String invitedByUsername,
    required String invitedUserId,
    required String invitedUsername,
  }) async {
    await _run(() {
      return ref
          .read(cleanupGroupRepositoryProvider)
          .createInvitation(
            group: group,
            invitedByUserId: invitedByUserId,
            invitedByUsername: invitedByUsername,
            invitedUserId: invitedUserId,
            invitedUsername: invitedUsername,
          );
    });
  }

  Future<void> acceptInvitation({
    required String invitationId,
    required String userId,
  }) async {
    await _run(() {
      return ref
          .read(cleanupGroupRepositoryProvider)
          .acceptInvitation(invitationId: invitationId, userId: userId);
    });
  }

  Future<void> rejectInvitation({
    required String invitationId,
    required String userId,
  }) async {
    await _run(() {
      return ref
          .read(cleanupGroupRepositoryProvider)
          .rejectInvitation(invitationId: invitationId, userId: userId);
    });
  }

  Future<void> _run(Future<void> Function() action) async {
    state = const AsyncLoading();
    try {
      await action();
      state = const AsyncData(null);
    } on Object catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      Error.throwWithStackTrace(error, stackTrace);
    }
  }
}
