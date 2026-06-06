import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/task_model.dart';

class TaskCategoryChips extends StatelessWidget {
  const TaskCategoryChips({
    required this.selectedType,
    required this.onSelected,
    super.key,
  });

  final String selectedType;
  final ValueChanged<String> onSelected;

  static const allType = 'all';

  static const _items = [
    _TaskCategory('Tümü', allType, Icons.apps_outlined),
    _TaskCategory('Günlük', TaskTypes.daily, Icons.today_outlined),
    _TaskCategory('Haftalık', TaskTypes.weekly, Icons.calendar_month_outlined),
    _TaskCategory('Sosyal', TaskTypes.social, Icons.group_outlined),
    _TaskCategory('Eğitim', TaskTypes.education, Icons.school_outlined),
    _TaskCategory('Kış', TaskTypes.winter, Icons.ac_unit),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final item = _items[index];
          final selected = item.type == selectedType;
          return _CategoryChip(
            item: item,
            selected: selected,
            onTap: () => onSelected(item.type),
          );
        },
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemCount: _items.length,
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _TaskCategory item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isWinter = item.type == TaskTypes.winter;
    final selectedColor = isWinter ? AppColors.winterBlue : AppColors.primary;
    final foreground = selected
        ? AppColors.textOnPrimary
        : AppColors.textPrimary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          constraints: const BoxConstraints(minWidth: 86),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? selectedColor : AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? selectedColor : AppColors.outlineVariant,
            ),
            boxShadow: selected
                ? const [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(item.icon, size: 16, color: foreground),
              const SizedBox(width: 6),
              Text(
                item.label,
                style: AppTextStyles.caption.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TaskCategory {
  const _TaskCategory(this.label, this.type, this.icon);

  final String label;
  final String type;
  final IconData icon;
}
