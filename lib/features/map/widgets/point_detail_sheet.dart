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
  const PointDetailSheet({
    required this.point,
    this.scrollController,
    this.onClose,
    super.key,
  });

  final RecyclingPointModel point;
  final ScrollController? scrollController;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: ListView(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
        children: [
          Center(
            child: Container(
              width: 56,
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.outlineVariant,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  point.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.title.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _DistanceBadge(distanceMeters: _distanceMeters(point)),
              if (onClose != null) ...[
                const SizedBox(width: 4),
                IconButton(
                  tooltip: 'Kapat',
                  onPressed: onClose,
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.location_on_outlined,
                color: AppColors.textSecondary,
                size: 22,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  point.address,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final type in _acceptedTypes(point))
                _WasteTypeChip(label: _typeLabel(type)),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: _InfoTile(
                  icon: Icons.star_border_rounded,
                  label: 'Puan Oranı',
                  value: _pointRatio(point),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _InfoTile(
                  icon: Icons.access_time,
                  label: 'Durum',
                  value: point.isActive && !point.isBroken ? 'Açık' : 'Kapalı',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _InfoTile(
                  icon: Icons.speed_outlined,
                  label: 'Doluluk',
                  value: '%${_fullness(point)}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => _openDirections(context, point),
            icon: const Icon(Icons.directions_outlined),
            label: const Text('Yol Tarifi Al'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(58),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showQrDialog(context, point),
                  icon: const Icon(Icons.qr_code_2),
                  label: const Text('QR Kodu Göster'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(58),
                    side: const BorderSide(
                      color: AppColors.primary,
                      width: 1.4,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _ReportButton(
                onPressed: () {
                  showDialog<void>(
                    context: context,
                    builder: (_) => PointReportDialog(point: point),
                  );
                },
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

class _DistanceBadge extends StatelessWidget {
  const _DistanceBadge({required this.distanceMeters});

  final int distanceMeters;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryFixed,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.navigation_outlined,
            color: AppColors.primary,
            size: 18,
          ),
          const SizedBox(width: 6),
          Text(
            '${distanceMeters}m',
            style: AppTextStyles.label.copyWith(
              color: AppColors.primaryDark,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _WasteTypeChip extends StatelessWidget {
  const _WasteTypeChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 116),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.primary, size: 31),
          const SizedBox(height: 10),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: AppTextStyles.subtitle.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportButton extends StatelessWidget {
  const _ReportButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 58,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          foregroundColor: AppColors.error,
          side: const BorderSide(color: AppColors.error),
          shape: const CircleBorder(),
        ),
        child: const Icon(Icons.report_problem_outlined),
      ),
    );
  }
}

List<String> _acceptedTypes(RecyclingPointModel point) {
  if (point.type == RecyclingPointTypes.cafe) {
    return const [
      RecyclingPointTypes.plastic,
      RecyclingPointTypes.glass,
      RecyclingPointTypes.paper,
      RecyclingPointTypes.electronic,
    ];
  }
  return [point.type];
}

String _typeLabel(String type) {
  return switch (type) {
    RecyclingPointTypes.plastic => 'Plastik',
    RecyclingPointTypes.glass => 'Cam',
    RecyclingPointTypes.paper => 'Kağıt',
    RecyclingPointTypes.electronic => 'Elektronik',
    RecyclingPointTypes.battery => 'Pil',
    RecyclingPointTypes.oil => 'Yağ',
    RecyclingPointTypes.cafe => 'Kafe',
    _ => 'Atık',
  };
}

String _pointRatio(RecyclingPointModel point) {
  return switch (point.type) {
    RecyclingPointTypes.cafe ||
    RecyclingPointTypes.electronic ||
    RecyclingPointTypes.oil => 'Yüksek',
    RecyclingPointTypes.battery => 'Orta',
    _ => 'Standart',
  };
}

int _fullness(RecyclingPointModel point) {
  final value = point.id.codeUnits.fold<int>(0, (sum, unit) => sum + unit);
  return 25 + (value % 54);
}

int _distanceMeters(RecyclingPointModel point) {
  const centerLatitude = 39.9056;
  const centerLongitude = 41.2658;
  final latitudeMeters = (point.latitude - centerLatitude).abs() * 111000;
  final longitudeMeters = (point.longitude - centerLongitude).abs() * 85000;
  final distance = latitudeMeters + longitudeMeters;
  return distance.clamp(180, 2800).round();
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
