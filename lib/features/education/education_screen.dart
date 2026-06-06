import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'data/education_content_repository.dart';
import 'widgets/education_card_deck.dart';

class EducationScreen extends ConsumerWidget {
  const EducationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentState = ref.watch(educationContentProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      body: contentState.when(
        data: (content) => _EducationContentView(content: content),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) =>
            _EducationContentView(content: EducationContent.fallback()),
      ),
    );
  }
}

class _EducationContentView extends StatelessWidget {
  const _EducationContentView({required this.content});

  final EducationContent content;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final deckHeight = (screenHeight - 310).clamp(430.0, 560.0);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      children: [
        Row(
          children: [
            IconButton.filledTonal(
              tooltip: 'Geri',
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                  return;
                }
                context.go('/tasks');
              },
              icon: const Icon(Icons.arrow_back),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Öğren ve Kazan',
                style: AppTextStyles.title.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Kartlara dokunarak geri dönüşüm bilgilerini keşfet.',
                style: AppTextStyles.subtitle.copyWith(
                  color: AppColors.onPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sağa, sola veya yukarı kaydırarak sıradaki bilgi kartına geçebilirsin.',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.onPrimary.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: deckHeight,
          child: EducationCardDeck(content: content),
        ),
        const SizedBox(height: 16),
        const _AssistantComingSoonCard(),
      ],
    );
  }
}

class _AssistantComingSoonCard extends StatelessWidget {
  const _AssistantComingSoonCard();

  @override
  Widget build(BuildContext context) {
    // TODO: Gemini 2.5 Flash entegrasyonu ile kullanıcıların geri dönüşüm hakkında soru sorabileceği asistan alanı eklenecek.
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.tertiary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.tertiary.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.auto_awesome, color: AppColors.tertiary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Geri Dönüşüm Asistanı',
                  style: AppTextStyles.subtitle.copyWith(
                    color: AppColors.tertiary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Yakında geri dönüşüm, sıfır atık ve atık ayrıştırma hakkında merak ettiklerini yapay zeka asistanına sorabileceksin.',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
