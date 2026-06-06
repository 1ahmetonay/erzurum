import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class EducationalRecyclingCard extends StatelessWidget {
  const EducationalRecyclingCard({super.key});

  static const _paragraphs = [
    'Sıfır atık yaklaşımı, atıkları kaynağında azaltmayı, yeniden kullanmayı ve geri dönüştürülebilir malzemeleri ekonomiye kazandırmayı hedefler.',
    'Plastik, cam, kağıt, metal ve elektronik atıkların ayrı toplanması hem çevre kirliliğini azaltır hem de Erzurum’da daha temiz bir yaşam alanı oluşturur.',
    'Toplum bilinci arttıkça geri dönüşüm noktaları daha verimli kullanılır ve atıklar doğaya karışmadan doğru şekilde işlenir.',
  ];

  @override
  Widget build(BuildContext context) {
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
          for (final paragraph in _paragraphs) ...[
            Text(
              paragraph,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 10),
          ],
          TextButton.icon(
            onPressed: () => _showComingSoonDialog(context),
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

  void _showComingSoonDialog(BuildContext context) {
    // TODO: İleride Gemini 2.5 Flash entegrasyonu ile kullanıcıların geri dönüşüm hakkında soru sorabileceği eğitim/asistan alanı eklenecek.
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceContainerLowest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text('Yakında', style: AppTextStyles.title),
          content: Text(
            'Bu alanda geri dönüşüm, sıfır atık ve çevre bilinci hakkında kısa eğitimler yer alacak.',
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tamam'),
            ),
          ],
        );
      },
    );
  }
}
