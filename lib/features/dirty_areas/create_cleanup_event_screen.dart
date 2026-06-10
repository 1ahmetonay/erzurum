import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../models/cleanup_event_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cleanup_event_provider.dart';
import '../../providers/user_provider.dart';
import '../../repositories/cleanup_event_repository.dart';

class CreateCleanupEventScreen extends ConsumerStatefulWidget {
  const CreateCleanupEventScreen({required this.dirtyAreaId, super.key});

  final String dirtyAreaId;

  @override
  ConsumerState<CreateCleanupEventScreen> createState() =>
      _CreateCleanupEventScreenState();
}

class _CreateCleanupEventScreenState
    extends ConsumerState<CreateCleanupEventScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  final _descriptionController = TextEditingController();
  final _meetingPointController = TextEditingController();
  final _maxParticipantsController = TextEditingController(text: '10');
  late DateTime _scheduledAt;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: 'Temizlik Buluşması');
    _scheduledAt = DateTime.now().add(const Duration(days: 1, hours: 1));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _meetingPointController.dispose();
    _maxParticipantsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Temizlik Etkinliği Oluştur')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
            children: [
              TextFormField(
                controller: _titleController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Etkinlik başlığı',
                ),
                validator: (value) =>
                    _requiredText(value, 'Başlık boş olamaz.'),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _descriptionController,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(labelText: 'Açıklama'),
                validator: (value) =>
                    _requiredText(value, 'Açıklama boş olamaz.'),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _meetingPointController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Buluşma noktası'),
                validator: (value) =>
                    _requiredText(value, 'Buluşma noktası boş olamaz.'),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _maxParticipantsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Maksimum katılımcı sayısı',
                ),
                validator: (value) {
                  final count = int.tryParse(value?.trim() ?? '');
                  if (count == null || count < 2) {
                    return 'Maksimum katılımcı en az 2 olmalı.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),
              OutlinedButton.icon(
                onPressed: _pickDateTime,
                icon: const Icon(Icons.event_outlined),
                label: Text(DateFormat('d MMMM y, HH:mm').format(_scheduledAt)),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _isSubmitting ? null : _submit,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.event_available_outlined),
                label: const Text('Etkinliği Oluştur'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _scheduledAt.isAfter(now)
          ? _scheduledAt
          : now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_scheduledAt),
    );
    if (time == null || !mounted) return;

    setState(() {
      _scheduledAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_scheduledAt.isBefore(DateTime.now())) {
      _showMessage('Etkinlik tarihi geçmişte olamaz.');
      return;
    }

    final firebaseUser = ref.read(authStateProvider).valueOrNull;
    if (firebaseUser == null) {
      _showMessage('Etkinlik oluşturmak için giriş yapmalısın.');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final profile = ref.read(currentUserProvider).valueOrNull;
      final username = (profile?.displayName.trim().isNotEmpty ?? false)
          ? profile!.displayName.trim()
          : (firebaseUser.displayName?.trim().isNotEmpty ?? false)
          ? firebaseUser.displayName!.trim()
          : firebaseUser.email ?? 'AtıkAvı kullanıcısı';
      final now = DateTime.now();
      final event = CleanupEventModel(
        id: '',
        dirtyAreaId: widget.dirtyAreaId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        createdByUserId: firebaseUser.uid,
        createdByUsername: username,
        meetingPointText: _meetingPointController.text.trim(),
        scheduledAt: _scheduledAt,
        status: CleanupEventStatuses.planned,
        maxParticipants: int.parse(_maxParticipantsController.text.trim()),
        participantCount: 1,
        participantIds: [firebaseUser.uid],
        createdAt: now,
        updatedAt: now,
      );

      await ref.read(cleanupEventRepositoryProvider).createCleanupEvent(event);
      if (!mounted) return;
      context.go('/dirty-areas/${widget.dirtyAreaId}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Temizlik etkinliği oluşturuldu.')),
      );
    } on CleanupEventRepositoryException catch (error) {
      if (mounted) _showMessage(error.message);
    } on Object {
      if (mounted) {
        _showMessage('Temizlik etkinliği oluşturulamadı. Tekrar dene.');
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  String? _requiredText(String? value, String message) {
    if (value == null || value.trim().isEmpty) return message;
    return null;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
