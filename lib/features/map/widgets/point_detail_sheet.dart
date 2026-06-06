import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/utils/point_report_resolver.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/point_report_model.dart';
import '../../../models/recycling_point_model.dart';
import '../../../providers/point_report_provider.dart';

class PointDetailSheet extends StatelessWidget {
  const PointDetailSheet({required this.point, super.key});

  final RecyclingPointModel point;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
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
                onPressed: () => _showQrDialog(context, point),
                icon: const Icon(Icons.qr_code_2),
                label: const Text('QR Kodu Göster'),
              ),
              OutlinedButton.icon(
                onPressed: () => _openDirections(context, point),
                icon: const Icon(Icons.directions),
                label: const Text('Yol Tarifi Al'),
              ),
              TextButton.icon(
                onPressed: () {
                  showDialog<void>(
                    context: context,
                    builder: (_) => PointReportDialog(point: point),
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

  Future<void> _openDirections(
    BuildContext context,
    RecyclingPointModel point,
  ) async {
    final uri = Uri.https('www.google.com', '/maps/dir/', {
      'api': '1',
      'destination': '${point.latitude},${point.longitude}',
    });
    final messenger = ScaffoldMessenger.of(context);

    final canLaunch = await canLaunchUrl(uri);
    if (!canLaunch) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Yol tarifi açılamadı.')),
      );
      return;
    }

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Yol tarifi açılamadı.')),
      );
    }
  }

  void _showQrDialog(BuildContext context, RecyclingPointModel point) {
    final qrValue = point.qrCode.trim().isNotEmpty
        ? point.qrCode.trim()
        : point.id;
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceContainerLowest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text('QR Kodu', style: AppTextStyles.title),
          content: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    point.name,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.subtitle,
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.outlineVariant),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: QrImageView(
                          data: qrValue,
                          version: QrVersions.auto,
                          size: 180,
                          backgroundColor: AppColors.surfaceContainerLowest,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SelectableText(
                    qrValue,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: qrValue));
                if (!dialogContext.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('QR kod kopyalandı.')),
                );
              },
              child: const Text('Kodu Kopyala'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Kapat'),
            ),
          ],
        );
      },
    );
  }
}

class PointReportDialog extends ConsumerStatefulWidget {
  const PointReportDialog({required this.point, super.key});

  final RecyclingPointModel point;

  @override
  ConsumerState<PointReportDialog> createState() => _PointReportDialogState();
}

class _PointReportDialogState extends ConsumerState<PointReportDialog> {
  final _descriptionController = TextEditingController();
  var _selectedType = PointReportTypes.broken;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final submitState = ref.watch(pointReportControllerProvider);
    final isLoading = submitState.isLoading;

    return AlertDialog(
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Text('Nokta Bildirimi', style: AppTextStyles.title),
      content: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.point.name, style: AppTextStyles.subtitle),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final type in PointReportTypes.values)
                    ChoiceChip(
                      label: Text(reportTypeLabel(type)),
                      selected: _selectedType == type,
                      onSelected: isLoading
                          ? null
                          : (_) => setState(() => _selectedType = type),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                enabled: !isLoading,
                maxLines: 3,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  labelText: 'Açıklama (opsiyonel)',
                  alignLabelWithHint: true,
                  filled: true,
                  fillColor: AppColors.surfaceLow,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Vazgeç'),
        ),
        FilledButton(
          onPressed: isLoading ? null : _submit,
          child: isLoading
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Gönder'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(pointReportControllerProvider.notifier)
          .submitPointReport(
            point: widget.point,
            reportType: _selectedType,
            description: _descriptionController.text,
          );
      if (!mounted) return;
      Navigator.of(context).pop();
      messenger.showSnackBar(
        const SnackBar(content: Text('Bildirimin alındı. Teşekkürler!')),
      );
    } on Object catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }
}
