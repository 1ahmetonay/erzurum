import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/recycling_point_model.dart';

class MapFilterBar extends StatelessWidget {
  const MapFilterBar({
    required this.selectedType,
    required this.onSelected,
    super.key,
  });

  final String selectedType;
  final ValueChanged<String> onSelected;

  static const _filters = [
    _MapFilter('Tümü', 'all', Icons.map_outlined),
    _MapFilter('Plastik', RecyclingPointTypes.plastic, Icons.recycling),
    _MapFilter('Cam', RecyclingPointTypes.glass, Icons.wine_bar_outlined),
    _MapFilter('Kağıt', RecyclingPointTypes.paper, Icons.description_outlined),
    _MapFilter(
      'Elektronik',
      RecyclingPointTypes.electronic,
      Icons.devices_other_outlined,
    ),
    _MapFilter('Pil', RecyclingPointTypes.battery, Icons.battery_charging_full),
    _MapFilter('Yağ', RecyclingPointTypes.oil, Icons.water_drop_outlined),
    _MapFilter('Kafe', RecyclingPointTypes.cafe, Icons.local_cafe_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final selected = filter.type == selectedType;
          return _FilterChipButton(
            filter: filter,
            selected: selected,
            onTap: () => onSelected(filter.type),
          );
        },
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemCount: _filters.length,
      ),
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  const _FilterChipButton({
    required this.filter,
    required this.selected,
    required this.onTap,
  });

  final _MapFilter filter;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary
                : AppColors.surfaceContainerLowest.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.outlineVariant,
            ),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 14,
                offset: Offset(0, 7),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(filter.icon, size: 19, color: foreground),
              const SizedBox(width: 8),
              Text(
                filter.label,
                style: AppTextStyles.label.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapFilter {
  const _MapFilter(this.label, this.type, this.icon);

  final String label;
  final String type;
  final IconData icon;
}
