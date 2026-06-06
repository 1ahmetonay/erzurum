import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../education/data/education_content_repository.dart';

class EducationalRecyclingCard extends ConsumerWidget {
  const EducationalRecyclingCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentState = ref.watch(educationContentProvider);
    final content = contentState.valueOrNull ?? EducationContent.fallback();
    final previewSections = content.previewSections;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'Öğren ve Kazan',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Geri Dönüşümün Gücünü Keşfedin',
            style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 14),
          for (final section in previewSections) ...[
            _PreviewTopic(title: section.title, summary: section.summary),
            const SizedBox(height: 12),
          ],
          TextButton.icon(
            onPressed: () => context.push('/education'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: EdgeInsets.zero,
              textStyle: AppTextStyles.label,
            ),
            label: const Text('Eğitimi Başlat'),
            iconAlignment: IconAlignment.end,
            icon: const Icon(Icons.arrow_forward),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: AspectRatio(
              aspectRatio: 1.05,
              child: Image.asset('assets/bitki.png', fit: BoxFit.cover),
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewTopic extends StatelessWidget {
  const _PreviewTopic({required this.title, required this.summary});

  final String title;
  final String summary;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(top: 8),
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.subtitle.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (summary.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  summary,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
