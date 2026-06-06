import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class PuanBadge extends StatelessWidget {
  const PuanBadge({
    required this.points,
    this.compact = false,
    this.foregroundColor = AppColors.primary,
    this.backgroundColor = AppColors.primaryFixed,
    super.key,
  });

  final int points;
  final bool compact;
  final Color foregroundColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 14,
        vertical: compact ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.eco, size: compact ? 14 : 16, color: foregroundColor),
          const SizedBox(width: 5),
          Text(
            '+$points DP',
            style: AppTextStyles.label.copyWith(color: foregroundColor),
          ),
        ],
      ),
    );
  }
}
