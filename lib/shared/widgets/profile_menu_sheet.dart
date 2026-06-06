import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import 'account_settings_sheet.dart';
import 'edit_profile_sheet.dart';

class ProfileMenuSheet extends ConsumerWidget {
  const ProfileMenuSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => const ProfileMenuSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(currentUserProvider).valueOrNull;
    final firebaseUser = ref.watch(authStateProvider).valueOrNull;
    final authAction = ref.watch(authControllerProvider);
    final displayName = _firstNonEmpty([
      userProfile?.displayName,
      firebaseUser?.displayName,
      _nameFromEmail(firebaseUser?.email),
    ]);
    final email = _firstNonEmpty([userProfile?.email, firebaseUser?.email]);
    final showProfilePhoto = userProfile?.preferences.showProfilePhoto ?? true;
    final photoUrl = showProfilePhoto
        ? _firstNonEmptyNullable([
            userProfile?.photoUrl,
            firebaseUser?.photoURL,
          ])
        : null;
    final points = userProfile?.totalPoints ?? 0;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.58,
      minChildSize: 0.38,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return ListView(
          controller: scrollController,
          padding: EdgeInsets.fromLTRB(
            20,
            0,
            20,
            MediaQuery.paddingOf(context).bottom + 28,
          ),
          children: [
            Center(
              child: CircleAvatar(
                radius: 36,
                backgroundColor: AppColors.primaryFixed,
                foregroundImage: photoUrl == null
                    ? null
                    : NetworkImage(photoUrl),
                child: photoUrl == null
                    ? _ProfileAvatarFallback(
                        displayName: displayName,
                        email: email,
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              displayName.isEmpty ? 'AtıkAvı Kullanıcısı' : displayName,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.title.copyWith(color: AppColors.primary),
            ),
            if (email.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                email,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: 18),
            _MenuTile(
              icon: Icons.edit_outlined,
              label: 'Profili Düzenle',
              onTap: () async {
                Navigator.of(context).pop();
                await EditProfileSheet.show(context);
              },
            ),
            _MenuTile(
              icon: Icons.eco_outlined,
              label: 'Puanlarım',
              onTap: () {
                Navigator.of(context).pop();
                _showInfoSheet(
                  context,
                  icon: Icons.eco_outlined,
                  title: 'Puanlarım',
                  message: '$points Dadaş Puan',
                );
              },
            ),
            _MenuTile(
              icon: Icons.settings_outlined,
              label: 'Hesap Ayarları',
              onTap: () async {
                Navigator.of(context).pop();
                await AccountSettingsSheet.show(context);
              },
            ),
            const Divider(height: 18),
            _MenuTile(
              icon: Icons.logout,
              label: authAction.isLoading ? 'Çıkış yapılıyor...' : 'Çıkış Yap',
              color: AppColors.error,
              enabled: !authAction.isLoading,
              onTap: () => _signOut(context, ref),
            ),
          ],
        );
      },
    );
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(authControllerProvider.notifier).signOut();
      if (context.mounted) Navigator.of(context).pop();
    } on Object {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Çıkış yapılırken bir hata oluştu. Lütfen tekrar deneyin.',
          ),
        ),
      );
    }
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = AppColors.primary,
    this.enabled = true,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = enabled ? color : AppColors.textSecondary;
    return ListTile(
      enabled: enabled,
      leading: Icon(icon, color: effectiveColor),
      title: Text(
        label,
        style: AppTextStyles.body.copyWith(
          color: effectiveColor,
          fontWeight: FontWeight.w700,
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onTap: enabled ? onTap : null,
    );
  }
}

class _ProfileAvatarFallback extends StatelessWidget {
  const _ProfileAvatarFallback({
    required this.displayName,
    required this.email,
  });

  final String displayName;
  final String email;

  @override
  Widget build(BuildContext context) {
    final source = displayName.trim().isNotEmpty ? displayName : email;
    if (source.trim().isEmpty) {
      return const Icon(Icons.person, color: AppColors.primaryDark, size: 34);
    }
    return Text(
      source.trim().characters.first.toUpperCase(),
      style: AppTextStyles.title.copyWith(
        color: AppColors.primaryDark,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

void _showInfoSheet(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String message,
}) {
  showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    showDragHandle: true,
    backgroundColor: AppColors.surfaceContainerLowest,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.primary, size: 42),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppTextStyles.title.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    },
  );
}

String _firstNonEmpty(List<String?> values) {
  for (final value in values) {
    final trimmed = value?.trim();
    if (trimmed != null && trimmed.isNotEmpty) return trimmed;
  }
  return '';
}

String? _firstNonEmptyNullable(List<String?> values) {
  final value = _firstNonEmpty(values);
  return value.isEmpty ? null : value;
}

String? _nameFromEmail(String? email) {
  final trimmed = email?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  return trimmed.split('@').first;
}
