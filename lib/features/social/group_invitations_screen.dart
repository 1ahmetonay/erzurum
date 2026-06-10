import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/social_demo_data.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/group_invitation_model.dart';
import '../../models/user_connection_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cleanup_group_provider.dart';
import '../../providers/user_connection_provider.dart';
import '../../providers/user_provider.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/notifications_sheet.dart';
import '../../shared/widgets/profile_menu_sheet.dart';
import 'widgets/group_invitations_sections.dart';

class GroupInvitationsScreen extends ConsumerStatefulWidget {
  const GroupInvitationsScreen({super.key});

  @override
  ConsumerState<GroupInvitationsScreen> createState() =>
      _GroupInvitationsScreenState();
}

class _GroupInvitationsScreenState
    extends ConsumerState<GroupInvitationsScreen> {
  final _searchController = TextEditingController();
  final Set<String> _selectedFriendIds = {};
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final invitationsState = ref.watch(incomingGroupInvitationsProvider);
    final friendsState = ref.watch(acceptedConnectionsProvider);
    final firebaseUser = ref.watch(authStateProvider).valueOrNull;
    final profile = ref.watch(currentUserProvider).valueOrNull;
    final friends =
        _friendItems(
          friendsState.valueOrNull ?? const [],
          firebaseUser?.uid ?? '',
        ).where((friend) {
          final query = _query.toLowerCase();
          return query.isEmpty ||
              friend.name.toLowerCase().contains(query) ||
              friend.subtitle.toLowerCase().contains(query);
        }).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          onPressed: _close,
          icon: const Icon(Icons.arrow_back),
          color: AppColors.primary,
          tooltip: 'Geri',
        ),
        title: Text(
          'Grup Davetleri',
          style: AppTextStyles.title.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => NotificationsSheet.show(context),
            icon: const Icon(Icons.notifications_none_outlined),
            color: AppColors.primary,
            tooltip: 'Bildirimler',
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              onTap: () => ProfileMenuSheet.show(context),
              customBorder: const CircleBorder(),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primaryFixed,
                foregroundImage:
                    profile?.photoUrl == null || profile!.photoUrl!.isEmpty
                    ? null
                    : NetworkImage(profile.photoUrl!),
                child: profile?.photoUrl == null || profile!.photoUrl!.isEmpty
                    ? Text(
                        _initial(profile?.displayName ?? firebaseUser?.email),
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.primaryDark,
                        ),
                      )
                    : null,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
          children: [
            const GroupSummaryCard(),
            const SizedBox(height: 26),
            const WeeklyGoalCard(),
            const SizedBox(height: 30),
            _SectionTitle(title: 'Bekleyen Davetler'),
            const SizedBox(height: 14),
            invitationsState.when(
              data: (invitations) {
                if (invitations.isEmpty) {
                  return const EmptyState(
                    title: 'Davet yok',
                    message: 'Temizlik grubu davetleri burada görünecek.',
                    icon: Icons.group_add_outlined,
                  );
                }
                return Column(
                  children: [
                    for (final invitation in invitations) ...[
                      PendingGroupInvitationCard(
                        invitation: invitation,
                        onAccept: () => _updateInvitation(
                          invitation,
                          GroupInvitationStatuses.accepted,
                        ),
                        onReject: () => _updateInvitation(
                          invitation,
                          GroupInvitationStatuses.rejected,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => const EmptyState(
                title: 'Davetler yüklenemedi',
                message: 'Grup davetleri şu anda alınamadı.',
                icon: Icons.error_outline,
              ),
            ),
            const SizedBox(height: 26),
            _SectionTitle(
              title: 'Arkadaşlarını Davet Et',
              action: TextButton(
                onPressed: friends.isEmpty ? null : () => _toggleAll(friends),
                child: Text(
                  friends.every(
                        (friend) => _selectedFriendIds.contains(friend.id),
                      )
                      ? 'Seçimi Kaldır'
                      : 'Tümünü Seç',
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Arkadaş ara...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: AppColors.surfaceContainer,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) => setState(() => _query = value.trim()),
            ),
            const SizedBox(height: 14),
            if (friendsState.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (friends.isEmpty)
              const EmptyState(
                title: 'Arkadaş bulunamadı',
                message: 'Arama kriterine uygun arkadaş yok.',
                icon: Icons.people_outline,
              )
            else
              for (final friend in friends) ...[
                SelectableInviteFriendCard(
                  data: friend,
                  selected: _selectedFriendIds.contains(friend.id),
                  onChanged: (selected) => _toggleFriend(friend.id, selected),
                ),
                const SizedBox(height: 12),
              ],
            const SizedBox(height: 14),
            FilledButton(
              onPressed: _selectedFriendIds.isEmpty ? null : _inviteSelected,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(62),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: AppTextStyles.subtitle.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              child: Text(
                'Seçilenleri Davet Et (${_selectedFriendIds.length})',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _close() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/friends');
    }
  }

  void _toggleFriend(String id, bool selected) {
    setState(() {
      if (selected) {
        _selectedFriendIds.add(id);
      } else {
        _selectedFriendIds.remove(id);
      }
    });
  }

  void _toggleAll(List<InviteFriendData> friends) {
    final allSelected = friends.every(
      (friend) => _selectedFriendIds.contains(friend.id),
    );
    setState(() {
      for (final friend in friends) {
        if (allSelected) {
          _selectedFriendIds.remove(friend.id);
        } else {
          _selectedFriendIds.add(friend.id);
        }
      }
    });
  }

  Future<void> _updateInvitation(
    GroupInvitationModel invitation,
    String status,
  ) async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (SocialDemoData.isDemoId(invitation.id) || user == null) {
      _showMessage('Bu davet demo verisidir. İşlem yalnızca UI’da gösterilir.');
      return;
    }
    try {
      final controller = ref.read(
        cleanupGroupActionControllerProvider.notifier,
      );
      if (status == GroupInvitationStatuses.accepted) {
        await controller.acceptInvitation(
          invitationId: invitation.id,
          userId: user.uid,
        );
      } else {
        await controller.rejectInvitation(
          invitationId: invitation.id,
          userId: user.uid,
        );
      }
      if (mounted) {
        _showMessage(
          status == GroupInvitationStatuses.accepted
              ? 'Grup daveti kabul edildi.'
              : 'Grup daveti reddedildi.',
        );
      }
    } on Object {
      if (mounted) _showMessage('Davet işlemi tamamlanamadı.');
    }
  }

  void _inviteSelected() {
    // TODO: Connect multi-friend invitation to a selected cleanup group.
    _showMessage('${_selectedFriendIds.length} arkadaş için davet hazırlandı.');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.action});

  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.title.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        ?action,
      ],
    );
  }
}

List<InviteFriendData> _friendItems(
  List<UserConnectionModel> connections,
  String currentUserId,
) {
  const subtitles = [
    'Çevre Dostu • 850 Puan',
    'Geri Dönüşüm Ustası • 1.120 Puan',
    'Atık Avcısı • 980 Puan',
  ];
  const colors = [
    Color(0xFF8C5A32),
    Color(0xFF338477),
    AppColors.tertiaryContainer,
  ];
  return [
    for (var index = 0; index < connections.length; index++)
      InviteFriendData(
        id: _friendId(connections[index], currentUserId),
        name: _friendName(connections[index], currentUserId),
        subtitle: subtitles[index % subtitles.length],
        color: colors[index % colors.length],
      ),
  ];
}

String _friendId(UserConnectionModel connection, String currentUserId) {
  return connection.requesterUserId == currentUserId
      ? connection.receiverUserId
      : connection.requesterUserId;
}

String _friendName(UserConnectionModel connection, String currentUserId) {
  return connection.requesterUserId == currentUserId
      ? connection.receiverUsername
      : connection.requesterUsername;
}

String _initial(String? value) {
  final normalized = value?.trim() ?? '';
  return normalized.isEmpty ? 'A' : normalized.characters.first.toUpperCase();
}
