import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
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
    ('Tümü', 'all'),
    ('Plastik', RecyclingPointTypes.plastic),
    ('Cam', RecyclingPointTypes.glass),
    ('Kağıt', RecyclingPointTypes.paper),
    ('Pil', RecyclingPointTypes.battery),
    ('Yağ', RecyclingPointTypes.oil),
    ('Kafe', RecyclingPointTypes.cafe),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final filter in _filters) ...[
            ChoiceChip(
              selected: filter.$2 == selectedType,
              label: Text(filter.$1),
              onSelected: (_) => onSelected(filter.$2),
              selectedColor: AppColors.primaryFixed,
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}
