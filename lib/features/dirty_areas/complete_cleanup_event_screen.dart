import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/cleanup_event_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cleanup_event_provider.dart';
import '../../providers/user_provider.dart';
import '../../repositories/cleanup_event_repository.dart';
import '../../shared/widgets/empty_state.dart';

class CompleteCleanupEventScreen extends ConsumerStatefulWidget {
  const CompleteCleanupEventScreen({required this.cleanupEventId, super.key});

  final String cleanupEventId;

  @override
  ConsumerState<CompleteCleanupEventScreen> createState() =>
      _CompleteCleanupEventScreenState();
}

class _CompleteCleanupEventScreenState
    extends ConsumerState<CompleteCleanupEventScreen> {
  final _noteController = TextEditingController();
  final _pointsController = TextEditingController(text: '50');
  final _picker = ImagePicker();
  XFile? _selectedPhoto;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _noteController.dispose();
    _pointsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eventState = ref.watch(
      cleanupEventDetailProvider(widget.cleanupEventId),
    );
    final firebaseUser = ref.watch(authStateProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(title: const Text('Temizliği Tamamla')),
      body: SafeArea(
        child: eventState.when(
          data: (event) {
            if (event == null) {
              return const Padding(
                padding: EdgeInsets.all(18),
                child: EmptyState(
                  title: 'Etkinlik bulunamadı',
                  message: 'Tamamlanacak etkinlik kaydı bulunamadı.',
                  icon: Icons.event_busy_outlined,
                ),
              );
            }

            final isCreator = firebaseUser?.uid == event.createdByUserId;
            final isCompleted = event.status == CleanupEventStatuses.completed;
            final isCancelled = event.status == CleanupEventStatuses.cancelled;
            final isPendingApproval =
                event.status == CleanupEventStatuses.pendingApproval;
            final canSubmit =
                isCreator &&
                !isCompleted &&
                !isCancelled &&
                !isPendingApproval &&
                event.participantIds.isNotEmpty;

            return ListView(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
              children: [
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
                _SummaryTile(
                  icon: Icons.groups_outlined,
                  title: 'Katılımcı',
                  value: '${event.participantCount} kişi',
                ),
                TextFormField(
                  controller: _pointsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Kişi başı Dadaş puan',
                    helperText: 'Minimum 10, maksimum 200',
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: canSubmit && !_isSubmitting ? _pickPhoto : null,
                  icon: const Icon(Icons.photo_camera_outlined),
                  label: Text(
                    _selectedPhoto == null
                        ? 'Kanıt fotoğrafı seç'
                        : 'Fotoğraf seçildi',
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _noteController,
                  minLines: 3,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Not',
                    hintText: 'Temizlik sonrası kısa not ekleyebilirsin.',
                  ),
                ),
                const SizedBox(height: 22),
                if (!isCreator)
                  const _InlineNotice(
                    message:
                        'Temizliği yalnızca etkinliği oluşturan kullanıcı tamamlayabilir.',
                  )
                else if (isCompleted)
                  const _InlineNotice(
                    message: 'Bu etkinlik onaylandı ve tamamlandı.',
                  )
                else if (isCancelled)
                  const _InlineNotice(
                    message: 'İptal edilen etkinlik tamamlanamaz.',
                  )
                else if (isPendingApproval)
                  const _InlineNotice(
                    message:
                        'Bu etkinliğin temizlik kanıtı admin onayı bekliyor.',
                  )
                else if (event.participantIds.isEmpty)
                  const _InlineNotice(
                    message: 'Katılımcı olmayan etkinlik tamamlanamaz.',
                  ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: canSubmit && !_isSubmitting
                      ? () => _submit(event)
                      : null,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.verified_outlined),
                  label: const Text('Temizlik Kanıtını Onaya Gönder'),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => const Padding(
            padding: EdgeInsets.all(18),
            child: EmptyState(
              title: 'Etkinlik yüklenemedi',
              message: 'Etkinlik bilgisi şu anda alınamadı.',
              icon: Icons.error_outline,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickPhoto() async {
    final photo = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 82,
    );
    if (photo == null || !mounted) return;
    setState(() => _selectedPhoto = photo);
  }

  Future<void> _submit(CleanupEventModel event) async {
    final photo = _selectedPhoto;
    if (photo == null) {
      _showMessage('Tamamlamak için kanıt fotoğrafı seçmelisin.');
      return;
    }
    final points = int.tryParse(_pointsController.text.trim()) ?? 50;
    if (points < 10 || points > 200) {
      _showMessage('Kişi başı puan 10 ile 200 arasında olmalı.');
      return;
    }

    final firebaseUser = ref.read(authStateProvider).valueOrNull;
    if (firebaseUser == null) {
      _showMessage('Temizliği tamamlamak için giriş yapmalısın.');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final repository = ref.read(cleanupEventRepositoryProvider);
      final photoUrl = await repository.uploadCompletionPhoto(
        cleanupEventId: event.id,
        userId: firebaseUser.uid,
        photo: photo,
      );
      final profile = ref.read(currentUserProvider).valueOrNull;
      final username = (profile?.displayName.trim().isNotEmpty ?? false)
          ? profile!.displayName.trim()
          : (firebaseUser.displayName?.trim().isNotEmpty ?? false)
          ? firebaseUser.displayName!.trim()
          : firebaseUser.email ?? 'AtıkAvı kullanıcısı';

      await ref
          .read(cleanupEventCompletionControllerProvider.notifier)
          .complete(
            cleanupEventId: event.id,
            dirtyAreaId: event.dirtyAreaId,
            completedByUserId: firebaseUser.uid,
            completedByUsername: username,
            completionPhotoUrl: photoUrl,
            completionNote: _noteController.text,
            pointsPerParticipant: points,
          );

      if (!mounted) return;
      context.go('/cleanup-events/${event.id}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Temizlik kanıtı admin onayına gönderildi.'),
        ),
      );
    } on CleanupEventRepositoryException catch (error) {
      if (mounted) _showMessage(error.message);
    } on Object {
      if (mounted) _showMessage('Temizlik tamamlanamadı. Tekrar dene.');
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

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Text(value, style: AppTextStyles.subtitle),
        ],
      ),
    );
  }
}

class _InlineNotice extends StatelessWidget {
  const _InlineNotice({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: AppTextStyles.body.copyWith(color: AppColors.error),
    );
  }
}
