import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/cleanup_event_model.dart';
import '../../models/cleanup_group_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cleanup_event_provider.dart';
import '../../providers/cleanup_group_provider.dart';
import '../../providers/user_provider.dart';
import '../../repositories/cleanup_group_repository.dart';
import '../../shared/widgets/empty_state.dart';

class CreateCleanupGroupScreen extends ConsumerStatefulWidget {
  const CreateCleanupGroupScreen({required this.cleanupEventId, super.key});

  final String cleanupEventId;

  @override
  ConsumerState<CreateCleanupGroupScreen> createState() =>
      _CreateCleanupGroupScreenState();
}

class _CreateCleanupGroupScreenState
    extends ConsumerState<CreateCleanupGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'Temizlik Ekibi');
  final _descriptionController = TextEditingController();
  final _maxMembersController = TextEditingController(text: '5');

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _maxMembersController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eventState = ref.watch(
      cleanupEventDetailProvider(widget.cleanupEventId),
    );
    final isSaving = ref.watch(cleanupGroupActionControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Grup Oluştur')),
      body: SafeArea(
        child: eventState.when(
          data: (event) {
            if (event == null) {
              return const Padding(
                padding: EdgeInsets.all(18),
                child: EmptyState(
                  title: 'Etkinlik bulunamadı',
                  message: 'Grup oluşturulacak temizlik etkinliği alınamadı.',
                  icon: Icons.event_busy_outlined,
                ),
              );
            }

            return Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
                children: [
                  _EventSummary(event: event),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: _nameController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Grup adı',
                      prefixIcon: Icon(Icons.groups_outlined),
                    ),
                    maxLength: 80,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Grup adı gerekli.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descriptionController,
                    minLines: 3,
                    maxLines: 5,
                    maxLength: 300,
                    decoration: const InputDecoration(
                      labelText: 'Kısa açıklama',
                      prefixIcon: Icon(Icons.notes_outlined),
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _maxMembersController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'Maksimum üye',
                      prefixIcon: Icon(Icons.person_add_alt_outlined),
                    ),
                    validator: (value) {
                      final parsed = int.tryParse(value ?? '');
                      if (parsed == null || parsed < 2 || parsed > 20) {
                        return '2 ile 20 arasında olmalı.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: isSaving ? null : () => _submit(event),
                    icon: isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.group_add_outlined),
                    label: const Text('Grubu Oluştur'),
                  ),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => const Padding(
            padding: EdgeInsets.all(18),
            child: EmptyState(
              title: 'Etkinlik yüklenemedi',
              message: 'Grup oluşturma bilgileri şu anda alınamadı.',
              icon: Icons.error_outline,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit(CleanupEventModel event) async {
    if (!_formKey.currentState!.validate()) return;
    final firebaseUser = ref.read(authStateProvider).valueOrNull;
    final currentUser = ref.read(currentUserProvider).valueOrNull;
    if (firebaseUser == null) {
      _showMessage('Grup oluşturmak için giriş yapmalısın.');
      return;
    }

    final username = currentUser?.displayName.trim().isNotEmpty == true
        ? currentUser!.displayName
        : firebaseUser.displayName ?? 'AtıkAvı Üyesi';
    final maxMembers = int.parse(_maxMembersController.text);
    final now = DateTime.now();

    try {
      final groupId = await ref
          .read(cleanupGroupActionControllerProvider.notifier)
          .createGroup(
            CleanupGroupModel(
              id: '',
              cleanupEventId: event.id,
              dirtyAreaId: event.dirtyAreaId,
              name: _nameController.text.trim(),
              description: _descriptionController.text.trim(),
              createdByUserId: firebaseUser.uid,
              createdByUsername: username,
              memberIds: [firebaseUser.uid],
              memberCount: 1,
              maxMembers: maxMembers,
              status: CleanupGroupStatuses.active,
              createdAt: now,
              updatedAt: now,
            ),
          );
      if (!mounted) return;
      _showMessage('Grup oluşturuldu.');
      context.go('/cleanup-groups/$groupId');
    } on CleanupGroupRepositoryException catch (error) {
      _showMessage(error.message);
    } on Object {
      _showMessage('Grup oluşturulamadı. Tekrar dene.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _EventSummary extends StatelessWidget {
  const _EventSummary({required this.event});

  final CleanupEventModel event;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        children: [
          const Icon(Icons.event_available_outlined, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.subtitle.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${event.participantCount}/${event.maxParticipants} katılımcı',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
