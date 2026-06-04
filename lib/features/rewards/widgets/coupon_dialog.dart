import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/redemption_result_model.dart';

class CouponDialog extends StatelessWidget {
  const CouponDialog({required this.result, super.key});

  final RedemptionResultModel result;

  static Future<void> show(BuildContext context, RedemptionResultModel result) {
    return showDialog<void>(
      context: context,
      builder: (context) => CouponDialog(result: result),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      title: Text('Kupon Hazır', style: AppTextStyles.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.confirmation_number,
            size: 54,
            color: AppColors.gold,
          ),
          const SizedBox(height: 12),
          Text(
            result.rewardTitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.subtitle,
          ),
          const SizedBox(height: 4),
          Text(
            result.sponsor,
            textAlign: TextAlign.center,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              result.couponCode,
              textAlign: TextAlign.center,
              style: AppTextStyles.title.copyWith(color: AppColors.primary),
            ),
          ),
          const SizedBox(height: 12),
          _InfoRow(label: 'Harcanan', value: '${result.pointsSpent} puan'),
          const SizedBox(height: 6),
          _InfoRow(
            label: 'Kalan bakiye',
            value: '${result.remainingPoints} puan',
          ),
        ],
      ),
      actions: [
        TextButton.icon(
          onPressed: () => _copyCode(context),
          icon: const Icon(Icons.copy),
          label: const Text('Kodu Kopyala'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Kapat'),
        ),
      ],
    );
  }

  Future<void> _copyCode(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: result.couponCode));
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Kupon kodu kopyalandı.')));
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}
