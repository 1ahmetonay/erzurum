import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../data/education_content_repository.dart';

class EducationSectionCard extends StatelessWidget {
  const EducationSectionCard({required this.section, super.key});

  final EducationSection section;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.title,
            style: AppTextStyles.title.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          for (final block in section.blocks) _EducationBlockView(block: block),
        ],
      ),
    );
  }
}

class _EducationBlockView extends StatelessWidget {
  const _EducationBlockView({required this.block});

  final EducationBlock block;

  @override
  Widget build(BuildContext context) {
    return switch (block.type) {
      EducationBlockType.subheading => Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        child: Text(
          block.text,
          style: AppTextStyles.subtitle.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      EducationBlockType.paragraph => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          block.text,
          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
        ),
      ),
      EducationBlockType.list => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [for (final item in block.items) _BulletRow(text: item)],
        ),
      ),
    };
  }
}

class _BulletRow extends StatelessWidget {
  const _BulletRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 8),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
