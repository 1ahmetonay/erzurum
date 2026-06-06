import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/mock_data.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/task_model.dart';
import '../../providers/task_provider.dart';
import 'widgets/educational_recycling_card.dart';
import 'widgets/task_category_chips.dart';
import 'widgets/task_card.dart';
import 'widgets/winter_task_banner.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({this.initialTaskId, super.key});

  final String? initialTaskId;

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  var _selectedType = TaskCategoryChips.allType;
  String? _handledInitialTaskId;

  @override
  Widget build(BuildContext context) {
    final tasksState = ref.watch(tasksWithProgressProvider);
    final providerTasks = tasksState.valueOrNull ?? const <TaskModel>[];
    final allTasks = _sortedTasks(
      providerTasks.isEmpty ? MockData.tasks : providerTasks,
    );
    final initialTask = _taskById(allTasks, widget.initialTaskId);
    if (initialTask != null && _handledInitialTaskId != widget.initialTaskId) {
      _handledInitialTaskId = widget.initialTaskId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() => _selectedType = initialTask.type);
        _showTaskDetail(initialTask);
      });
    }
    final tasks = _filteredTasks(allTasks);

    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        children: [
          const WinterTaskBanner(),
          const SizedBox(height: 18),
          Transform.translate(
            offset: const Offset(-16, 0),
            child: TaskCategoryChips(
              selectedType: _selectedType,
              onSelected: (type) => setState(() => _selectedType = type),
            ),
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
                const SizedBox(height: 16),
              ],
          ],
          const SizedBox(height: 4),
          const EducationalRecyclingCard(),
        ],
      ),
    );
  }

  List<TaskModel> _sortedTasks(List<TaskModel> tasks) {
    return [...tasks]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  List<TaskModel> _filteredTasks(List<TaskModel> tasks) {
    if (_selectedType == TaskCategoryChips.allType) return tasks;
    if (_selectedType == TaskTypes.winter) {
      return tasks.where((task) => task.isWinterOnly).toList();
    }
    return tasks.where((task) => task.type == _selectedType).toList();
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
