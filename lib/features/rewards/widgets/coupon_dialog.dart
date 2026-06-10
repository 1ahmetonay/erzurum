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
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      title: Text(
        'Ödülünüz Hazır!',
        textAlign: TextAlign.center,
        style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w900),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: AppColors.primaryFixed.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.primaryFixedDim),
            ),
            child: const Icon(
              Icons.qr_code_2,
              size: 56,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            result.rewardTitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.subtitle.copyWith(fontWeight: FontWeight.w900),
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Text(
              result.couponCode.isEmpty ? 'AZ-2024-X8R' : result.couponCode,
              textAlign: TextAlign.center,
              style: AppTextStyles.title.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w900,
              ),
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
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Tamam'),
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
