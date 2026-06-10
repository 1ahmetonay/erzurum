import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/cleanup_event_model.dart';
import '../../providers/admin_functions_provider.dart';
import '../../providers/cleanup_event_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/admin_functions_service.dart';
import '../../shared/widgets/empty_state.dart';

class CleanupApprovalDetailScreen extends ConsumerStatefulWidget {
  const CleanupApprovalDetailScreen({required this.cleanupEventId, super.key});

  final String cleanupEventId;

  @override
  ConsumerState<CleanupApprovalDetailScreen> createState() =>
      _CleanupApprovalDetailScreenState();
}

class _CleanupApprovalDetailScreenState
    extends ConsumerState<CleanupApprovalDetailScreen> {
  final _reasonController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = ref.watch(currentUserIsAdminProvider);
    final eventState = ref.watch(
      cleanupEventDetailProvider(widget.cleanupEventId),
    );
    final proofState = ref.watch(
      cleanupProofForEventProvider(widget.cleanupEventId),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Temizlik Kanıtı İncele')),
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
            : eventState.when(
                data: (event) {
                  if (event == null) {
                    return const Padding(
                      padding: EdgeInsets.all(18),
                      child: EmptyState(
                        title: 'Etkinlik bulunamadı',
                        message: 'Onaylanacak etkinlik kaydı bulunamadı.',
                        icon: Icons.event_busy_outlined,
                      ),
                    );
                  }
                  final proof = proofState.valueOrNull;
                  final totalPoints =
                      event.participantCount * event.pointsPerParticipant;
                  final canReview =
                      event.status == CleanupEventStatuses.pendingApproval &&
                      !_isSubmitting;

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
                    children: [
                      if (event.completionPhotoUrl != null &&
                          event.completionPhotoUrl!.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: Image.network(
                              event.completionPhotoUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => const ColoredBox(
                                color: AppColors.surfaceContainer,
                                child: Center(
                                  child: Icon(Icons.image_not_supported),
                                ),
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 18),
                      Text(
                        event.title,
                        style: AppTextStyles.title.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        event.description,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 18),
                      _DetailTile(
                        title: 'Yükleyen',
                        value: event.createdByUsername,
                        icon: Icons.person_outline,
                      ),
                      _DetailTile(
                        title: 'Katılımcı',
                        value: '${event.participantCount} kişi',
                        icon: Icons.groups_outlined,
                      ),
                      _DetailTile(
                        title: 'Toplam puan',
                        value:
                            '$totalPoints Dadaş puan (${event.pointsPerParticipant} x ${event.participantCount})',
                        icon: Icons.stars_outlined,
                      ),
                      _DetailTile(
                        title: 'Dirty area',
                        value: event.dirtyAreaId,
                        icon: Icons.location_on_outlined,
                      ),
                      if (event.completedAt != null)
                        _DetailTile(
                          title: 'Gönderim tarihi',
                          value: DateFormat(
                            'd MMMM y, HH:mm',
                          ).format(event.completedAt!),
                          icon: Icons.schedule_outlined,
                        ),
                      _DetailTile(
                        title: 'Kanıt notu',
                        value: proof?.note?.trim().isNotEmpty == true
                            ? proof!.note!
                            : '-',
                        icon: Icons.notes_outlined,
                      ),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: canReview ? () => _approve(event) : null,
                        icon: _isSubmitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.check_circle_outline),
                        label: const Text('Onayla ve Puanları Dağıt'),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: canReview
                            ? () => _showRejectDialog(event)
                            : null,
                        icon: const Icon(Icons.cancel_outlined),
                        label: const Text('Reddet'),
                      ),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, _) => const Padding(
                  padding: EdgeInsets.all(18),
                  child: EmptyState(
                    title: 'Detay yüklenemedi',
                    message: 'Onay detayı şu anda alınamadı.',
                    icon: Icons.error_outline,
                  ),
                ),
              ),
      ),
    );
  }

  Future<void> _approve(CleanupEventModel event) async {
    setState(() => _isSubmitting = true);
    try {
      await ref
          .read(cleanupApprovalFunctionsControllerProvider.notifier)
          .approve(event.id);
      if (!mounted) return;
      context.go('/admin/cleanup-approvals');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Temizlik onaylandı ve Dadaş puanları dağıtıldı.'),
        ),
      );
    } on AdminFunctionsException catch (error) {
      if (mounted) _showMessage(error.message);
    } on Object {
      if (mounted) _showMessage('Onay işlemi tamamlanamadı.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _showRejectDialog(CleanupEventModel event) async {
    _reasonController.clear();
    final reason = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Red sebebi'),
          content: TextField(
            controller: _reasonController,
            minLines: 3,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: 'Kanıtın neden reddedildiğini yaz.',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Vazgeç'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(context).pop(_reasonController.text),
              child: const Text('Reddet'),
            ),
          ],
        );
      },
    );
    if (reason == null || reason.trim().isEmpty) return;
    await _reject(event, reason.trim());
  }

  Future<void> _reject(CleanupEventModel event, String reason) async {
    setState(() => _isSubmitting = true);
    try {
      await ref
          .read(cleanupApprovalFunctionsControllerProvider.notifier)
          .reject(event.id, reason);
      if (!mounted) return;
      context.go('/admin/cleanup-approvals');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Temizlik kanıtı reddedildi.')),
      );
    } on AdminFunctionsException catch (error) {
      if (mounted) _showMessage(error.message);
    } on Object {
      if (mounted) _showMessage('Red işlemi tamamlanamadı.');
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

class _DetailTile extends StatelessWidget {
  const _DetailTile({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(value, style: AppTextStyles.body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
