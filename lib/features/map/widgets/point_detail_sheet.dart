import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/recycling_point_model.dart';

class PointDetailSheet extends StatelessWidget {
  const PointDetailSheet({required this.point, super.key});

  final RecyclingPointModel point;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.recycling, color: AppColors.primary),
              const SizedBox(width: 10),
              Expanded(child: Text(point.name, style: AppTextStyles.subtitle)),
            ],
          ),
          const SizedBox(height: 8),
          Text(point.address, style: AppTextStyles.body),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.qr_code_2),
                label: const Text('QR Kodu Göster'),
              ),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.directions),
                label: const Text('Yol Tarifi Al'),
              ),
              TextButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Bozuk nokta bildirimi sonraki aşamada bağlanacak.',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.report_problem_outlined),
                label: const Text('Bozuk Bildir'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
