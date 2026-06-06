import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/mock_data.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/task_model.dart';
import '../../providers/task_provider.dart';
import '../../shared/widgets/section_header.dart';
import 'widgets/task_card.dart';
import 'widgets/winter_task_banner.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({this.initialTaskId, super.key});

  final String? initialTaskId;

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  var _selectedType = TaskTypes.daily;
  String? _handledInitialTaskId;

  @override
  Widget build(BuildContext context) {
    final tasksState = ref.watch(tasksWithProgressProvider);
    final allTasks = _sortedTasks(tasksState.valueOrNull ?? MockData.tasks);
    final initialTask = _taskById(allTasks, widget.initialTaskId);
    if (initialTask != null && _handledInitialTaskId != widget.initialTaskId) {
      _handledInitialTaskId = widget.initialTaskId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() => _selectedType = initialTask.type);
        _showTaskDetail(initialTask);
      });
    }
    final tasks = allTasks.where((task) => task.type == _selectedType).toList();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            const SectionHeader(
              title: 'Görevler',
              subtitle: 'Dadaş Puan kazanmak için günlük hedeflerini tamamla.',
            ),
            const SizedBox(height: 16),
            const WinterTaskBanner(),
            const SizedBox(height: 16),
            _TaskCategoryChips(
              selectedType: _selectedType,
              onSelected: (type) => setState(() => _selectedType = type),
            ),
            const SizedBox(height: 20),
            if (tasksState.isLoading && !tasksState.hasValue)
              const _LoadingState()
            else ...[
              if (tasksState.hasError) ...[
                _ErrorState(message: _friendlyError(tasksState.error)),
                const SizedBox(height: 12),
              ],
              if (tasks.isEmpty)
                const _EmptyState(message: 'Bu kategoride aktif görev yok.')
              else
                for (final task in tasks) ...[
                  TaskCard(
                    task: task,
                    highlighted: task.id == widget.initialTaskId,
                    onTap: () => _showTaskDetail(task),
                  ),
                  const SizedBox(height: 12),
                ],
            ],
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.winterLight,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.winterIce),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.school_outlined,
                    color: AppColors.winterBlue,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Karton bardakların kapakları plastik kutuya, gövdesi kağıt kutusuna atılmalı.',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<TaskModel> _sortedTasks(List<TaskModel> tasks) {
    return [...tasks]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  TaskModel? _taskById(List<TaskModel> tasks, String? taskId) {
    if (taskId == null || taskId.isEmpty) return null;
    for (final task in tasks) {
      if (task.id == taskId) return task;
    }
    return null;
  }

  Future<void> _showTaskDetail(TaskModel task) {
    return showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => _TaskDetailSheet(task: task),
    );
  }

  String _friendlyError(Object? error) {
    return 'Görevler yüklenemedi. Demo görevlerle devam edebilirsin.';
  }
}

class _TaskDetailSheet extends StatelessWidget {
  const _TaskDetailSheet({required this.task});

  final TaskModel task;

  @override
  Widget build(BuildContext context) {
    final requiredCount = task.requiredCount ?? 1;
    final progress = requiredCount == 0
        ? 0.0
        : (task.currentCount / requiredCount).clamp(0.0, 1.0);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        22,
        4,
        22,
        MediaQuery.paddingOf(context).bottom + 28,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: const BoxDecoration(
                  color: AppColors.cardBg,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    task.iconEmoji,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(task.title, style: AppTextStyles.title),
                    const SizedBox(height: 4),
                    Text(
                      '+${task.pointReward} Dadaş Puan',
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            task.description,
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: task.isCompleted ? 1 : progress,
              minHeight: 12,
              color: task.isCompleted ? AppColors.success : AppColors.primary,
              backgroundColor: AppColors.surfaceLow,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                '${task.currentCount}/$requiredCount tamamlandı',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Text(_typeLabel(task.type), style: AppTextStyles.caption),
            ],
          ),
        ],
      ),
    );
  }
}

class _TaskCategoryChips extends StatelessWidget {
  const _TaskCategoryChips({
    required this.selectedType,
    required this.onSelected,
  });

  final String selectedType;
  final ValueChanged<String> onSelected;

  static const _items = [
    ('Günlük', TaskTypes.daily),
    ('Haftalık', TaskTypes.weekly),
    ('Sosyal', TaskTypes.social),
    ('Eğitim', TaskTypes.education),
    ('Kış', TaskTypes.winter),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final item in _items) ...[
            ChoiceChip(
              selected: item.$2 == selectedType,
              label: Text(item.$1),
              onSelected: (_) => onSelected(item.$2),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 32),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.winterLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.winterIce),
      ),
      child: Text(
        message,
        style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(message, style: AppTextStyles.body),
    );
  }
}

String _typeLabel(String type) {
  return switch (type) {
    TaskTypes.daily => 'Günlük',
    TaskTypes.weekly => 'Haftalık',
    TaskTypes.social => 'Sosyal',
    TaskTypes.education => 'Eğitim',
    TaskTypes.winter => 'Kış',
    _ => 'Görev',
  };
}
