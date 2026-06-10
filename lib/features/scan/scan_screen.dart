import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/demo_scan_data.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/scan_result_model.dart';
import '../../models/waste_log_model.dart';
import '../../providers/waste_provider.dart';
import '../../shared/widgets/section_header.dart';
import 'widgets/qr_scanner_view.dart';
import 'widgets/success_overlay.dart';
import 'widgets/waste_type_chip.dart';

class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  var _selectedWasteType = WasteTypes.plastic;
  _ScanMode? _activeMode;
  String? _shownResultKey;
  var _isBarcodeDemoLoading = false;

  @override
  Widget build(BuildContext context) {
    final scanState = ref.watch(scanControllerProvider);

    ref.listen<AsyncValue<ScanResultModel?>>(scanControllerProvider, (
      previous,
      next,
    ) {
      final result = next.valueOrNull;
      if (result == null) return;
      final resultKey =
          '${result.wasteLogId ?? 'pending'}:${result.message}:${result.totalPointsEarned}';
      if (_shownResultKey == resultKey) return;
      _shownResultKey = resultKey;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _showSuccessDialog(result);
      });
    });

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            const SectionHeader(
              title: 'Atık Tara',
              subtitle: 'QR, fotoğraf veya barkod ile atık kaydı oluştur.',
            ),
            const SizedBox(height: 16),
            _ScanModeSelector(
              activeMode: _activeMode,
              isLoading: scanState.isLoading,
              onSelected: _selectMode,
            ),
            const SizedBox(height: 18),
            if (_activeMode == null)
              const _ScannerIdleCard()
            else if (_activeMode == _ScanMode.qr)
              QrScannerView(
                key: const ValueKey('qr-scanner'),
                isProcessing: scanState.isLoading,
                mode: ScanCameraMode.qr,
                onQrDetected: _submitQrCode,
              )
            else if (_activeMode == _ScanMode.barcode)
              QrScannerView(
                key: const ValueKey('barcode-scanner'),
                isProcessing: scanState.isLoading,
                mode: ScanCameraMode.barcode,
                onQrDetected: _handleBarcodeDetected,
              )
            else
              QrScannerView(
                key: const ValueKey('photo-preview'),
                isProcessing: scanState.isLoading,
                mode: ScanCameraMode.photo,
                onQrDetected: (_) {},
              ),
            if (_activeMode == _ScanMode.qr && kDebugMode) ...[
              const SizedBox(height: 12),
              _DemoActionCard(
                icon: Icons.qr_code_2,
                title: 'Demo QR',
                message: DemoScanData.qrCode,
                buttonLabel: 'Demo QR Simüle Et',
                isLoading: scanState.isLoading,
                onPressed: _submitDemoQrCode,
              ),
            ],
            if (_activeMode == _ScanMode.barcode && kDebugMode) ...[
              const SizedBox(height: 12),
              _DemoActionCard(
                icon: Icons.barcode_reader,
                title: 'Demo Barkod',
                message: DemoScanData.barcode,
                buttonLabel: 'Demo Barkod Simüle Et',
                isLoading: _isBarcodeDemoLoading,
                onPressed: _submitDemoBarcode,
              ),
            ],
            const SizedBox(height: 18),
            Text('Atık Türü', style: AppTextStyles.subtitle),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                WasteTypeChip(
                  label: 'Plastik',
                  icon: Icons.local_drink_outlined,
                  color: AppColors.plastic,
                  selected: _selectedWasteType == WasteTypes.plastic,
                  onTap: () => _selectWasteType(WasteTypes.plastic),
                ),
                WasteTypeChip(
                  label: 'Cam',
                  icon: Icons.wine_bar_outlined,
                  color: AppColors.glass,
                  selected: _selectedWasteType == WasteTypes.glass,
                  onTap: () => _selectWasteType(WasteTypes.glass),
                ),
                WasteTypeChip(
                  label: 'Kağıt',
                  icon: Icons.description_outlined,
                  color: AppColors.paper,
                  selected: _selectedWasteType == WasteTypes.paper,
                  onTap: () => _selectWasteType(WasteTypes.paper),
                ),
                WasteTypeChip(
                  label: 'Pil',
                  icon: Icons.battery_5_bar_outlined,
                  color: AppColors.battery,
                  selected: _selectedWasteType == WasteTypes.battery,
                  onTap: () => _selectWasteType(WasteTypes.battery),
                ),
                WasteTypeChip(
                  label: 'Yağ',
                  icon: Icons.water_drop_outlined,
                  color: AppColors.oil,
                  selected: _selectedWasteType == WasteTypes.oil,
                  onTap: () => _selectWasteType(WasteTypes.oil),
                ),
              ],
            ),
            const SizedBox(height: 18),
            if (_activeMode == _ScanMode.photo)
              _PhotoActionCard(
                isLoading: scanState.isLoading,
                onSubmitDemo: kDebugMode ? _submitDemoPhotoWaste : null,
              )
            else
              _ModeHintCard(activeMode: _activeMode),
            if (scanState.isLoading) ...[
              const SizedBox(height: 16),
              const Center(child: CircularProgressIndicator()),
            ],
          ],
        ),
      ),
    );
  }

  void _selectMode(_ScanMode mode) {
    setState(() => _activeMode = mode);
  }

  void _selectWasteType(String wasteType) {
    setState(() => _selectedWasteType = wasteType);
  }

  Future<void> _submitQrCode(String qrCode) async {
    try {
      await ref
          .read(scanControllerProvider.notifier)
          .submitQrCode(qrCode, selectedWasteType: _selectedWasteType);
      if (mounted) setState(() => _activeMode = null);
    } on Object catch (error) {
      _showError(error);
    }
  }

  Future<void> _submitDemoQrCode() async {
    await _submitQrCode(DemoScanData.qrCode);
  }

  Future<void> _handleBarcodeDetected(String barcode) async {
    await _showBarcodeResult(barcode);
  }

  Future<void> _submitDemoBarcode() async {
    if (_isBarcodeDemoLoading) return;
    setState(() => _isBarcodeDemoLoading = true);
    try {
      await Future<void>.delayed(const Duration(milliseconds: 450));
      await _showBarcodeResult(DemoScanData.barcode);
    } on Object catch (error) {
      _showError(error);
    } finally {
      if (mounted) setState(() => _isBarcodeDemoLoading = false);
    }
  }

  Future<void> _submitDemoPhotoWaste() async {
    try {
      await ref
          .read(scanControllerProvider.notifier)
          .submitDemoPhotoWaste(wasteType: _selectedWasteType);
      if (mounted) {
        setState(() => _activeMode = null);
      }
    } on Object catch (error) {
      _showError(error);
    }
  }

  Future<void> _showSuccessDialog(ScanResultModel result) {
    final points = result.totalPointsEarned;
    final message = result.isPhotoPending
        ? result.message
        : 'QR doğrulandı. Puanınız eklendi. +$points Dadaş Puan kazandınız.';

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 32),
            child: SuccessOverlay(
              title: result.isPhotoPending ? 'İnceleme Alındı' : 'Başarılı!',
              message: message,
              bonusPoints: result.bonusPoints,
              completedTaskTitles: result.completedTaskTitles,
              onDismiss: () => Navigator.of(context).pop(),
            ),
          ),
        );
      },
    );
  }

  void _showError(Object error) {
    if (!mounted) return;
    final message = error.toString();
    if (message.contains('kısa süre önce puan kazandın')) {
      _showCenteredWarning(title: 'Biraz Bekle', message: message);
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _showCenteredWarning({
    required String title,
    required String message,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 32),
            child: _ScanWarningOverlay(
              title: title,
              message: message,
              onDismiss: () => Navigator.of(context).pop(),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showBarcodeResult(String barcode) {
    if (!mounted) return Future.value();
    setState(() => _activeMode = null);

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 32),
            child: SuccessOverlay(
              title: 'Barkod Okundu',
              message:
                  'Barkod: $barcode\nÜrün geri dönüşüm kategorisi: Plastik / Ambalaj.',
              bonusPoints: 0,
              completedTaskTitles: const [],
              onDismiss: () => Navigator.of(context).pop(),
            ),
          ),
        );
      },
    );
  }
}

class _ScanWarningOverlay extends StatelessWidget {
  const _ScanWarningOverlay({
    required this.title,
    required this.message,
    required this.onDismiss,
  });

  final String title;
  final String message;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 420),
      padding: const EdgeInsets.fromLTRB(28, 30, 28, 24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 28,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.hourglass_top,
              color: AppColors.warning,
              size: 42,
            ),
          ),
          const SizedBox(height: 22),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.display.copyWith(
              color: AppColors.primary,
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.subtitle.copyWith(
              color: AppColors.textSecondary,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 26),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onDismiss,
              child: const Text('Tamam'),
            ),
          ),
        ],
      ),
    );
  }
}

enum _ScanMode { qr, photo, barcode }

class _ScanModeSelector extends StatelessWidget {
  const _ScanModeSelector({
    required this.activeMode,
    required this.isLoading,
    required this.onSelected,
  });

  final _ScanMode? activeMode;
  final bool isLoading;
  final ValueChanged<_ScanMode> onSelected;

  static const _items = [
    (_ScanMode.qr, Icons.qr_code_scanner, 'QR Tara'),
    (_ScanMode.photo, Icons.photo_camera_outlined, 'Foto'),
    (_ScanMode.barcode, Icons.barcode_reader, 'Barkod'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        children: [
          for (final item in _items)
            Expanded(
              child: _ScanModeButton(
                icon: item.$2,
                label: item.$3,
                selected: activeMode == item.$1,
                enabled: !isLoading,
                onTap: () => onSelected(item.$1),
              ),
            ),
        ],
      ),
    );
  }
}

class _ScanModeButton extends StatelessWidget {
  const _ScanModeButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.textSecondary;
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.secondaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScannerIdleCard extends StatelessWidget {
  const _ScannerIdleCard();

  @override
  Widget build(BuildContext context) {
    return _InstructionCard(
      icon: Icons.touch_app_outlined,
      title: 'İşlem seç',
      message:
          'Kamera yalnızca QR, barkod veya fotoğraf işlemi seçildiğinde açılır.',
    );
  }
}

class _ModeHintCard extends StatelessWidget {
  const _ModeHintCard({required this.activeMode});

  final _ScanMode? activeMode;

  @override
  Widget build(BuildContext context) {
    final message = switch (activeMode) {
      _ScanMode.qr => 'QR kodu çerçeve içine hizala',
      _ScanMode.barcode => 'Barkodu çerçeve içine hizala',
      _ScanMode.photo => 'Atığın fotoğrafını çekmek için kamerayı hizala',
      null => 'Önce işlem seçerek kamerayı başlat.',
    };

    return _InstructionCard(
      icon: Icons.info_outline,
      title: 'Hazır',
      message: message,
    );
  }
}

class _InstructionCard extends StatelessWidget {
  const _InstructionCard({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.subtitle),
                const SizedBox(height: 4),
                Text(
                  message,
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

class _PhotoActionCard extends StatelessWidget {
  const _PhotoActionCard({required this.isLoading, this.onSubmitDemo});

  final bool isLoading;
  final VoidCallback? onSubmitDemo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.photo_camera_outlined, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Atığı kadraja yerleştir ve demo fotoğraf bildirimi oluştur.',
                  style: AppTextStyles.body,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (onSubmitDemo != null)
                FilledButton.icon(
                  onPressed: isLoading ? null : onSubmitDemo,
                  icon: const Icon(Icons.science_outlined),
                  label: const Text('Fotoğrafı Simüle Et'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DemoActionCard extends StatelessWidget {
  const _DemoActionCard({
    required this.icon,
    required this.title,
    required this.message,
    required this.buttonLabel,
    required this.isLoading,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String message;
  final String buttonLabel;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.subtitle),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            child: isLoading
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(buttonLabel),
          ),
        ],
      ),
    );
  }
}
