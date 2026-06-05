import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/user_preferences_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';

class AccountSettingsSheet extends ConsumerStatefulWidget {
  const AccountSettingsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => const AccountSettingsSheet(),
    );
  }

  @override
  ConsumerState<AccountSettingsSheet> createState() =>
      _AccountSettingsSheetState();
}

class _AccountSettingsSheetState extends ConsumerState<AccountSettingsSheet> {
  String? _savingKey;

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(currentUserProvider);
    final user = userState.valueOrNull;
    final firebaseUser = ref.watch(authStateProvider).valueOrNull;
    final uid = user?.uid ?? firebaseUser?.uid;
    final email = _firstNonEmpty([user?.email, firebaseUser?.email]);
    final preferences = user?.preferences ?? const UserPreferencesModel();

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.86,
      minChildSize: 0.5,
      maxChildSize: 0.94,
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
            Text(
              'Hesap Ayarları',
              textAlign: TextAlign.center,
              style: AppTextStyles.title.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            if (userState.isLoading && !userState.hasValue)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              ),
            _SettingsSection(
              title: 'Bildirimler',
              icon: Icons.notifications_none,
              children: [
                _SettingsSwitchTile(
                  icon: Icons.notifications_none,
                  title: 'Bildirimleri Aç',
                  subtitle: 'Görev, ödül ve hatırlatma bildirimlerini al.',
                  value: preferences.notificationsEnabled,
                  isSaving: _savingKey == 'notificationsEnabled',
                  onChanged: uid == null
                      ? null
                      : (value) => _updatePreferences(
                          uid,
                          preferences.copyWith(
                            notificationsEnabled: value,
                            taskRemindersEnabled: value
                                ? preferences.taskRemindersEnabled
                                : false,
                            rewardNotificationsEnabled: value
                                ? preferences.rewardNotificationsEnabled
                                : false,
                          ),
                          'notificationsEnabled',
                        ),
                ),
                _SettingsSwitchTile(
                  icon: Icons.task_alt,
                  title: 'Görev Hatırlatmaları',
                  subtitle: 'Günlük ve haftalık görevleri hatırlat.',
                  value: preferences.taskRemindersEnabled,
                  enabled: preferences.notificationsEnabled,
                  isSaving: _savingKey == 'taskRemindersEnabled',
                  onChanged: uid == null
                      ? null
                      : (value) => _updatePreferences(
                          uid,
                          preferences.copyWith(taskRemindersEnabled: value),
                          'taskRemindersEnabled',
                        ),
                ),
                _SettingsSwitchTile(
                  icon: Icons.card_giftcard,
                  title: 'Ödül Bildirimleri',
                  subtitle: 'Yeni ödüller ve puan fırsatlarını bildir.',
                  value: preferences.rewardNotificationsEnabled,
                  enabled: preferences.notificationsEnabled,
                  isSaving: _savingKey == 'rewardNotificationsEnabled',
                  onChanged: uid == null
                      ? null
                      : (value) => _updatePreferences(
                          uid,
                          preferences.copyWith(
                            rewardNotificationsEnabled: value,
                          ),
                          'rewardNotificationsEnabled',
                        ),
                ),
              ],
            ),
            _SettingsSection(
              title: 'Konum',
              icon: Icons.location_on_outlined,
              children: [
                _SettingsSwitchTile(
                  icon: Icons.location_on_outlined,
                  title: 'Yakındaki Noktaları Göster',
                  subtitle:
                      'Harita ve ana sayfada sana yakın geri dönüşüm noktalarını öne çıkar.',
                  value: preferences.nearbyPointsEnabled,
                  isSaving: _savingKey == 'nearbyPointsEnabled',
                  onChanged: uid == null
                      ? null
                      : (value) => _updatePreferences(
                          uid,
                          preferences.copyWith(nearbyPointsEnabled: value),
                          'nearbyPointsEnabled',
                        ),
                ),
                _SettingsValueTile(
                  icon: Icons.map_outlined,
                  title: 'Varsayılan İlçe',
                  subtitle: 'Harita önerilerinde kullanılacak ilçe.',
                  value: preferences.defaultDistrict,
                  isSaving: _savingKey == 'defaultDistrict',
                  onTap: uid == null
                      ? null
                      : () => _selectDistrict(uid, preferences),
                ),
              ],
            ),
            _SettingsSection(
              title: 'Gizlilik',
              icon: Icons.privacy_tip_outlined,
              children: [
                _SettingsSwitchTile(
                  icon: Icons.leaderboard_outlined,
                  title: 'Sıralamada Görün',
                  subtitle: 'Adın ve puanın sıralama tablosunda görünsün.',
                  value: preferences.showOnLeaderboard,
                  isSaving: _savingKey == 'showOnLeaderboard',
                  onChanged: uid == null
                      ? null
                      : (value) => _updatePreferences(
                          uid,
                          preferences.copyWith(showOnLeaderboard: value),
                          'showOnLeaderboard',
                        ),
                ),
                _SettingsSwitchTile(
                  icon: Icons.account_circle_outlined,
                  title: 'Profil Fotoğrafımı Göster',
                  subtitle: 'Profil fotoğrafın uygulama içinde görünsün.',
                  value: preferences.showProfilePhoto,
                  isSaving: _savingKey == 'showProfilePhoto',
                  onChanged: uid == null
                      ? null
                      : (value) => _updatePreferences(
                          uid,
                          preferences.copyWith(showProfilePhoto: value),
                          'showProfilePhoto',
                        ),
                ),
              ],
            ),
            _SettingsSection(
              title: 'Güvenlik',
              icon: Icons.security_outlined,
              children: [
                _SettingsActionTile(
                  icon: Icons.lock_reset,
                  title: 'Şifre Sıfırlama E-postası Gönder',
                  subtitle: email.isEmpty
                      ? 'E-posta adresi bulunamadı.'
                      : 'Şifre sıfırlama bağlantısı e-posta adresine gönderilir.',
                  isSaving: _savingKey == 'passwordReset',
                  onTap: email.isEmpty
                      ? null
                      : () => _sendPasswordReset(email, firebaseUser),
                ),
                _SettingsActionTile(
                  icon: Icons.delete_outline,
                  title: 'Hesabımı Sil',
                  subtitle: 'Hesabın güvenli şekilde silme isteğine alınır.',
                  color: AppColors.error,
                  isSaving: _savingKey == 'deleteAccount',
                  onTap: uid == null ? null : () => _confirmDelete(uid),
                ),
              ],
            ),
            _SettingsSection(
              title: 'Uygulama',
              icon: Icons.palette_outlined,
              children: [
                _SettingsValueTile(
                  icon: Icons.palette_outlined,
                  title: 'Tema',
                  subtitle:
                      'TODO: Wire themeMode preference to MaterialApp themeMode.',
                  value: _themeLabel(preferences.themeMode),
                  isSaving: _savingKey == 'themeMode',
                  onTap: uid == null
                      ? null
                      : () => _selectTheme(uid, preferences),
                ),
                _SettingsActionTile(
                  icon: Icons.feedback_outlined,
                  title: 'Geri Bildirim Gönder',
                  subtitle: 'Öneri ve sorunlarını bizimle paylaş.',
                  isSaving: _savingKey == 'feedback',
                  onTap: uid == null
                      ? null
                      : () => _showFeedbackDialog(uid: uid, email: email),
                ),
                const _SettingsStaticTile(
                  icon: Icons.info_outline,
                  title: 'Uygulama Sürümü',
                  value: '1.0.0',
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> _updatePreferences(
    String uid,
    UserPreferencesModel preferences,
    String key,
  ) async {
    setState(() => _savingKey = key);
    try {
      await ref
          .read(userRepositoryProvider)
          .updateUserPreferences(uid: uid, preferences: preferences);
    } on Object {
      _showMessage('Ayar güncellenemedi. Lütfen tekrar deneyin.');
    } finally {
      if (mounted) setState(() => _savingKey = null);
    }
  }

  Future<void> _selectDistrict(
    String uid,
    UserPreferencesModel preferences,
  ) async {
    final value = await _showChoiceSheet<String>(
      context: context,
      title: 'Varsayılan İlçe',
      values: const ['Yakutiye', 'Palandöken', 'Aziziye'],
      selectedValue: preferences.defaultDistrict,
      labelBuilder: (value) => value,
    );
    if (value == null) return;
    await _updatePreferences(
      uid,
      preferences.copyWith(defaultDistrict: value),
      'defaultDistrict',
    );
  }

  Future<void> _selectTheme(
    String uid,
    UserPreferencesModel preferences,
  ) async {
    final value = await _showChoiceSheet<String>(
      context: context,
      title: 'Tema',
      values: const ['system', 'light', 'dark'],
      selectedValue: preferences.themeMode,
      labelBuilder: _themeLabel,
    );
    if (value == null) return;
    await _updatePreferences(
      uid,
      preferences.copyWith(themeMode: value),
      'themeMode',
    );
  }

  Future<void> _sendPasswordReset(String email, dynamic firebaseUser) async {
    final providers = firebaseUser?.providerData as List<dynamic>? ?? const [];
    final usesPassword = providers.any(
      (provider) => provider.providerId == 'password',
    );

    if (!usesPassword && providers.isNotEmpty) {
      _showMessage(
        'Google ile giriş yaptığın için şifre işlemlerini Google hesabından yönetebilirsin.',
      );
      return;
    }

    setState(() => _savingKey = 'passwordReset');
    try {
      await ref.read(authRepositoryProvider).sendPasswordResetEmail(email);
      _showMessage('Şifre sıfırlama bağlantısı e-posta adresine gönderildi.');
    } on Object {
      _showMessage('Bir hata oluştu. Lütfen tekrar deneyin.');
    } finally {
      if (mounted) setState(() => _savingKey = null);
    }
  }

  Future<void> _confirmDelete(String uid) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hesabını silmek istiyor musun?'),
          content: const Text(
            'Bu işlem geri alınamaz. Puanların, görev ilerlemen ve kayıtların silinebilir.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Vazgeç'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(backgroundColor: AppColors.error),
              child: const Text('Hesabımı Sil'),
            ),
          ],
        );
      },
    );
    if (confirmed != true) return;

    setState(() => _savingKey = 'deleteAccount');
    try {
      await ref.read(userRepositoryProvider).softDeleteAccount(uid);
      await ref.read(authControllerProvider.notifier).signOut();
      if (!mounted) return;
      Navigator.of(context).pop();
      _showMessage('Hesap silme isteğin alındı.');
    } on Object {
      _showMessage('Bir hata oluştu. Lütfen tekrar deneyin.');
    } finally {
      if (mounted) setState(() => _savingKey = null);
    }
  }

  Future<void> _showFeedbackDialog({
    required String uid,
    required String email,
  }) async {
    final controller = TextEditingController();
    final message = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Geri Bildirim Gönder'),
          content: TextField(
            controller: controller,
            autofocus: true,
            minLines: 3,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: 'Mesajını yaz...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Vazgeç'),
            ),
            FilledButton(
              onPressed: () {
                final text = controller.text.trim();
                if (text.isEmpty) return;
                Navigator.of(context).pop(text);
              },
              child: const Text('Gönder'),
            ),
          ],
        );
      },
    );
    controller.dispose();
    if (message == null) return;

    setState(() => _savingKey = 'feedback');
    try {
      await ref
          .read(userRepositoryProvider)
          .sendFeedback(uid: uid, email: email, message: message);
      _showMessage('Geri bildirimin için teşekkürler!');
    } on Object {
      _showMessage('Bir hata oluştu. Lütfen tekrar deneyin.');
    } finally {
      if (mounted) setState(() => _savingKey = null);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.65)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: AppTextStyles.subtitle.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

class _SettingsSwitchTile extends StatelessWidget {
  const _SettingsSwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.isSaving = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool enabled;
  final bool isSaving;

  @override
  Widget build(BuildContext context) {
    final active = enabled && onChanged != null && !isSaving;
    return SwitchListTile.adaptive(
      value: value,
      onChanged: active ? onChanged : null,
      secondary: Icon(
        icon,
        color: active ? AppColors.primary : AppColors.outline,
      ),
      title: Text(
        title,
        style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w800),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}

class _SettingsValueTile extends StatelessWidget {
  const _SettingsValueTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onTap,
    this.isSaving = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String value;
  final VoidCallback? onTap;
  final bool isSaving;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      enabled: onTap != null && !isSaving,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: Icon(icon, color: AppColors.primary),
      title: Text(
        title,
        style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w800),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: AppTextStyles.label.copyWith(color: AppColors.primary),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right),
        ],
      ),
      onTap: isSaving ? null : onTap,
    );
  }
}

class _SettingsActionTile extends StatelessWidget {
  const _SettingsActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.color = AppColors.primary,
    this.isSaving = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Color color;
  final bool isSaving;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      enabled: onTap != null && !isSaving,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: AppTextStyles.body.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
      ),
      trailing: isSaving
          ? const SizedBox.square(
              dimension: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.chevron_right),
      onTap: isSaving ? null : onTap,
    );
  }
}

class _SettingsStaticTile extends StatelessWidget {
  const _SettingsStaticTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: Icon(icon, color: AppColors.primary),
      title: Text(
        title,
        style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w800),
      ),
      trailing: Text(
        value,
        style: AppTextStyles.label.copyWith(color: AppColors.textSecondary),
      ),
    );
  }
}

Future<T?> _showChoiceSheet<T>({
  required BuildContext context,
  required String title,
  required List<T> values,
  required T selectedValue,
  required String Function(T value) labelBuilder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    useSafeArea: true,
    showDragHandle: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          0,
          20,
          MediaQuery.paddingOf(context).bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: AppTextStyles.title.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: 12),
            for (final value in values)
              ListTile(
                title: Text(labelBuilder(value)),
                trailing: value == selectedValue
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                onTap: () => Navigator.of(context).pop(value),
              ),
          ],
        ),
      );
    },
  );
}

String _themeLabel(String value) {
  return switch (value) {
    'light' => 'Açık',
    'dark' => 'Koyu',
    _ => 'Sistem',
  };
}

String _firstNonEmpty(List<String?> values) {
  for (final value in values) {
    final trimmed = value?.trim();
    if (trimmed != null && trimmed.isNotEmpty) return trimmed;
  }
  return '';
}
