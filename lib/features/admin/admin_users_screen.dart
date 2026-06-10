import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/admin_functions_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/admin_functions_service.dart';
import '../../shared/widgets/empty_state.dart';

class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
  final _uidController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _uidController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = ref.watch(currentUserIsAdminProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Kullanıcıları')),
      body: SafeArea(
        child: !isAdmin
            ? const Padding(
                padding: EdgeInsets.all(18),
                child: EmptyState(
                  title: 'Yetki gerekli',
                  message: 'Bu ekran yalnızca admin kullanıcılar içindir.',
                  icon: Icons.admin_panel_settings_outlined,
                ),
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.outlineVariant),
                    ),
                    child: Text(
                      'İlk admin bu ekranla atanamaz. İlk admin custom claim’i Firebase Admin SDK veya CLI ile manuel verilmeli.',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: _uidController,
                    decoration: const InputDecoration(
                      labelText: 'Kullanıcı UID',
                      hintText: 'Admin yetkisi verilecek/kaldırılacak UID',
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _isSubmitting
                        ? null
                        : () => _setAdmin(admin: true),
                    icon: const Icon(Icons.admin_panel_settings_outlined),
                    label: const Text('Admin Yap'),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: _isSubmitting
                        ? null
                        : () => _setAdmin(admin: false),
                    icon: const Icon(Icons.remove_moderator_outlined),
                    label: const Text('Admin Yetkisini Kaldır'),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _setAdmin({required bool admin}) async {
    final uid = _uidController.text.trim();
    if (uid.isEmpty) {
      _showMessage('Kullanıcı UID boş olamaz.');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await ref
          .read(adminClaimControllerProvider.notifier)
          .setAdminClaim(targetUid: uid, admin: admin);
      if (!mounted) return;
      _showMessage(
        admin ? 'Admin yetkisi verildi.' : 'Admin yetkisi kaldırıldı.',
      );
    } on AdminFunctionsException catch (error) {
      if (mounted) _showMessage(error.message);
    } on Object {
      if (mounted) _showMessage('Admin yetkisi güncellenemedi.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
