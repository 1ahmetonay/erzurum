import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class LeaderboardAvatar extends StatelessWidget {
  const LeaderboardAvatar({
    required this.name,
    required this.size,
    this.photoUrl,
    this.borderColor = AppColors.surfaceContainerLowest,
    this.backgroundColor = AppColors.primaryFixed,
    super.key,
  });

  final String name;
  final String? photoUrl;
  final double size;
  final Color borderColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    final trimmedPhoto = photoUrl?.trim();

    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: borderColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.22),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: CircleAvatar(
        backgroundColor: backgroundColor,
        foregroundImage: trimmedPhoto == null || trimmedPhoto.isEmpty
            ? null
            : NetworkImage(trimmedPhoto),
        child: trimmedPhoto == null || trimmedPhoto.isEmpty
            ? Text(
                _initials(name),
                style: AppTextStyles.subtitle.copyWith(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.w900,
                ),
              )
            : null,
      ),
    );
  }
}

String _initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty || parts.first.isEmpty) return '?';
  if (parts.length == 1) return parts.first.characters.first.toUpperCase();
  return '${parts.first.characters.first}${parts.last.characters.first}'
      .toUpperCase();
}
