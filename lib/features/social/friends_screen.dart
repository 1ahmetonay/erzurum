import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/social_demo_data.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/user_connection_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_connection_provider.dart';
import '../../providers/user_provider.dart';
import '../../repositories/user_connection_repository.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/notifications_sheet.dart';
import 'widgets/friends_screen_widgets.dart';
import 'widgets/user_connection_card.dart';

class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({super.key});

  @override
  ConsumerState<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).valueOrNull;
    final profile = ref.watch(currentUserProvider).valueOrNull;
    final friendsState = ref.watch(acceptedConnectionsProvider);
    final incomingState = ref.watch(incomingConnectionRequestsProvider);
    final searchState = ref.watch(userSearchResultsProvider);
    final searchQuery = ref.watch(userSearchQueryProvider).trim();
    final requestCount = incomingState.valueOrNull?.length ?? 0;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: false,
        leading: IconButton(
          onPressed: _close,
          icon: const Icon(Icons.arrow_back),
          color: AppColors.primary,
          tooltip: 'Geri',
        ),
        title: Text(
          'Arkadaşlarım',
          style: AppTextStyles.title.copyWith(
            color: AppColors.primary,
            fontSize: 25,
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
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Kullanıcı adı veya e-posta ara',
                      prefixIcon: const Icon(Icons.search, size: 30),
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
                    onChanged: (value) {
                      ref.read(userSearchQueryProvider.notifier).state = value;
                    },
                  ),
                ),
                const SizedBox(width: 10),
                IconButton.filled(
                  onPressed: () => _showMessage(
                    'Arkadaş eklemek için kullanıcı adını veya e-postayı ara.',
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primaryContainer,
                    foregroundColor: AppColors.onPrimary,
                    minimumSize: const Size(68, 64),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.person_add_alt_1_outlined, size: 30),
                  tooltip: 'Arkadaş ekle',
                ),
              ],
            ),
            if (searchQuery.isNotEmpty) ...[
              const SizedBox(height: 12),
              _SearchResults(
                state: searchState,
                onSendRequest: user == null
                    ? null
                    : (receiverId, receiverName) => _sendRequest(
                        requesterUserId: user.uid,
                        requesterUsername:
                            profile?.displayName ?? user.email ?? '',
                        receiverUserId: receiverId,
                        receiverUsername: receiverName,
                      ),
              ),
            ],
            const SizedBox(height: 30),
            FriendsTabBar(
              selectedIndex: _selectedTab,
              requestCount: requestCount,
              onSelected: (index) => setState(() => _selectedTab = index),
            ),
            const SizedBox(height: 24),
            if (_selectedTab == 0)
              _FriendsList(
                state: friendsState,
                currentUserId: user?.uid ?? '',
                onOpen: (name) =>
                    _showMessage('$name profil detayı ileride bağlanacak.'),
                onShare: _shareInviteLink,
              )
            else
              _RequestsList(
                state: incomingState,
                currentUserId: user?.uid,
                onUpdate: _updateRequest,
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
      context.go('/home');
    }
  }

  Future<void> _sendRequest({
    required String requesterUserId,
    required String requesterUsername,
    required String receiverUserId,
    required String receiverUsername,
  }) async {
    try {
      await ref
          .read(userConnectionActionControllerProvider.notifier)
          .sendRequest(
            requesterUserId: requesterUserId,
            requesterUsername: requesterUsername,
            receiverUserId: receiverUserId,
            receiverUsername: receiverUsername,
          );
      if (mounted) _showMessage('Arkadaşlık isteği gönderildi.');
    } on UserConnectionRepositoryException catch (error) {
      if (mounted) _showMessage(error.message);
    } on Object {
      if (mounted) _showMessage('Arkadaşlık isteği gönderilemedi.');
    }
  }

  Future<void> _updateRequest(
    UserConnectionModel request,
    String status,
  ) async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;
    if (SocialDemoData.isDemoId(request.id)) {
      _showMessage('Bu istek demo verisidir. İşlem yalnızca UI’da gösterilir.');
      return;
    }
    try {
      await ref
          .read(userConnectionActionControllerProvider.notifier)
          .updateStatus(
            connectionId: request.id,
            userId: user.uid,
            status: status,
          );
      if (mounted) {
        _showMessage(
          status == UserConnectionStatuses.accepted
              ? 'Arkadaşlık isteği kabul edildi.'
              : 'Arkadaşlık isteği reddedildi.',
        );
      }
    } on Object {
      if (mounted) _showMessage('İstek güncellenemedi. Tekrar dene.');
    }
  }

  Future<void> _shareInviteLink() async {
    const link = 'https://atikavi.app/davet/erzurum';
    await Clipboard.setData(const ClipboardData(text: link));
    if (mounted) _showMessage('Davet linki panoya kopyalandı.');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _FriendsList extends StatelessWidget {
  const _FriendsList({
    required this.state,
    required this.currentUserId,
    required this.onOpen,
    required this.onShare,
  });

  final AsyncValue<List<UserConnectionModel>> state;
  final String currentUserId;
  final ValueChanged<String> onOpen;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return state.when(
      data: (connections) {
        if (connections.isEmpty) {
          return const EmptyState(
            title: 'Arkadaş yok',
            message: 'Kullanıcı arayıp arkadaşlık isteği gönderebilirsin.',
            icon: Icons.people_outline,
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'TÜM ARKADAŞLAR (${connections.length})',
                    style: AppTextStyles.subtitle.copyWith(
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.sort, size: 20),
                  label: const Text('Sırala'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            for (var index = 0; index < connections.length; index++) ...[
              Builder(
                builder: (context) {
                  final data = _friendData(
                    connections[index],
                    currentUserId,
                    index,
                  );
                  return FriendProfileCard(
                    data: data,
                    onOpen: () => onOpen(data.name),
                  );
                },
              ),
              const SizedBox(height: 14),
            ],
            const SizedBox(height: 8),
            InviteFriendsBanner(onShare: onShare),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => const EmptyState(
        title: 'Arkadaşlar yüklenemedi',
        message: 'Bağlantı listesi şu anda alınamadı.',
        icon: Icons.error_outline,
      ),
    );
  }
}

class _RequestsList extends StatelessWidget {
  const _RequestsList({
    required this.state,
    required this.currentUserId,
    required this.onUpdate,
  });

  final AsyncValue<List<UserConnectionModel>> state;
  final String? currentUserId;
  final Future<void> Function(UserConnectionModel, String) onUpdate;

  @override
  Widget build(BuildContext context) {
    return state.when(
      data: (requests) {
        if (requests.isEmpty) {
          return const EmptyState(
            title: 'İstek yok',
            message: 'Gelen arkadaşlık istekleri burada görünecek.',
            icon: Icons.person_add_alt_outlined,
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'GELEN İSTEKLER (${requests.length})',
              style: AppTextStyles.subtitle.copyWith(
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 14),
            for (var index = 0; index < requests.length; index++) ...[
              FriendRequestCard(
                name: requests[index].requesterUsername,
                description: 'Seninle arkadaş olmak istiyor',
                avatarColor: _avatarColors[index % _avatarColors.length],
                onAccept: currentUserId == null
                    ? null
                    : () => onUpdate(
                        requests[index],
                        UserConnectionStatuses.accepted,
                      ),
                onReject: currentUserId == null
                    ? null
                    : () => onUpdate(
                        requests[index],
                        UserConnectionStatuses.rejected,
                      ),
              ),
              const SizedBox(height: 14),
            ],
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => const EmptyState(
        title: 'İstekler yüklenemedi',
        message: 'Gelen istekler şu anda alınamadı.',
        icon: Icons.error_outline,
      ),
    );
  }
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({required this.state, required this.onSendRequest});

  final AsyncValue<List<UserModel>> state;
  final void Function(String userId, String username)? onSendRequest;

  @override
  Widget build(BuildContext context) {
    return state.when(
      data: (results) {
        if (results.isEmpty) {
          return const SizedBox.shrink();
        }
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: Column(
            children: [
              for (final result in results)
                UserConnectionCard(
                  title: result.displayName,
                  subtitle: result.email,
                  primaryLabel: 'İstek Gönder',
                  onPrimary: onSendRequest == null
                      ? null
                      : () => onSendRequest!(result.uid, result.displayName),
                ),
            ],
          ),
        );
      },
      loading: () => const LinearProgressIndicator(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

const _avatarColors = [
  AppColors.primaryContainer,
  AppColors.tertiaryContainer,
  Color(0xFF8C5A32),
  Color(0xFF6B5DA8),
];

FriendCardData _friendData(
  UserConnectionModel connection,
  String currentUserId,
  int index,
) {
  final name = connection.requesterUserId == currentUserId
      ? connection.receiverUsername
      : connection.requesterUsername;
  const badges = ['Doğa Dostu', 'Atık Avcısı', 'Geri Dönüşümcü'];
  const points = [1240, 980, 2150];
  return FriendCardData(
    name: name,
    badge: badges[index % badges.length],
    points: points[index % points.length],
    isOnline: index.isEven,
    avatarColor: _avatarColors[index % _avatarColors.length],
  );
}
