import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class WasteTypeChip extends StatelessWidget {
  const WasteTypeChip({
    required this.label,
    required this.icon,
    required this.color,
    this.selected = false,
    this.onTap,
    super.key,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.18) : AppColors.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: selected ? color : AppColors.outline),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 6),
            Text(label, style: AppTextStyles.label),
          ],
        ),
      ),
    );
  }
}
