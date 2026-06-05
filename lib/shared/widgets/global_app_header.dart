import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import 'notifications_sheet.dart';
import 'profile_menu_sheet.dart';

class GlobalAppHeader extends ConsumerWidget {
  const GlobalAppHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = _HeaderProfile.fromProviders(ref);
    final firstName = _firstName(profile.displayName);

    return SafeArea(
      bottom: false,
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        child: Row(
          children: [
            _HeaderAvatar(profile: profile),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Hoş Geldin 👋',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    firstName.isEmpty ? 'Merhaba' : 'Merhaba, $firstName',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.title.copyWith(
                      color: AppColors.primary,
                      fontSize: 23,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Bildirimler',
              onPressed: () => NotificationsSheet.show(context),
              icon: const Icon(
                Icons.notifications_none,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderAvatar extends StatelessWidget {
  const _HeaderAvatar({required this.profile});

  final _HeaderProfile profile;

  @override
  Widget build(BuildContext context) {
    final photoUrl = profile.photoUrl;
    final initial = _initial(profile.displayName, profile.email);

    return InkWell(
      customBorder: const CircleBorder(),
      onTap: () => ProfileMenuSheet.show(context),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primary, width: 1.4),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryDark.withValues(alpha: 0.14),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: CircleAvatar(
          backgroundColor: AppColors.primaryLight,
          foregroundImage: photoUrl == null || photoUrl.isEmpty
              ? null
              : NetworkImage(photoUrl),
          child: photoUrl == null || photoUrl.isEmpty
              ? Text(
                  initial,
                  style: AppTextStyles.subtitle.copyWith(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w900,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}

class _HeaderProfile {
  const _HeaderProfile({
    required this.displayName,
    required this.email,
    this.photoUrl,
  });

  final String displayName;
  final String email;
  final String? photoUrl;

  factory _HeaderProfile.fromProviders(WidgetRef ref) {
    final userProfile = ref.watch(currentUserProvider).valueOrNull;
    final firebaseUser = ref.watch(authStateProvider).valueOrNull;

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

    return _HeaderProfile(
      displayName: displayName,
      email: email,
      photoUrl: photoUrl,
    );
  }
}

String _firstName(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return '';
  return trimmed.split(RegExp(r'\s+')).first;
}

String _initial(String displayName, String email) {
  final source = displayName.trim().isNotEmpty ? displayName : email;
  if (source.trim().isEmpty) return '';
  return source.trim().characters.first.toUpperCase();
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
