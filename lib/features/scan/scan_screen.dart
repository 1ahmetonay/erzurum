import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

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
  XFile? _selectedPhoto;
  String? _shownResultKey;

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
              const _PhotoInstructionCard(),
            if (_activeMode == _ScanMode.qr && kDebugMode) ...[
              const SizedBox(height: 12),
              _DemoQrButtons(
                isLoading: scanState.isLoading,
                onSubmit: _submitQrCode,
              ),
            ],
            if (_activeMode == _ScanMode.barcode) ...[
              const SizedBox(height: 12),
              const _BarcodeDemoCard(),
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
              _UploadCard(
                selectedPhoto: _selectedPhoto,
                isLoading: scanState.isLoading,
                onPickCamera: () => _pickPhoto(ImageSource.camera),
                onPickGallery: () => _pickPhoto(ImageSource.gallery),
                onSubmit: _submitPhotoWaste,
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
    if (mode == _ScanMode.photo) {
      _pickPhoto(ImageSource.camera);
    }
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

  void _handleBarcodeDetected(String barcode) {
    setState(() => _activeMode = null);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Barkod okundu: $barcode')));
  }

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final photo = await ImagePicker().pickImage(
        source: source,
        imageQuality: 82,
        maxWidth: 1600,
      );
      if (photo == null) return;
      setState(() => _selectedPhoto = photo);
    } on Object catch (error) {
      _showError('Fotoğraf seçilemedi: $error');
    }
  }

  Future<void> _submitPhotoWaste() async {
    try {
      await ref
          .read(scanControllerProvider.notifier)
          .submitPhotoWaste(
            wasteType: _selectedWasteType,
            photo: _selectedPhoto,
          );
      setState(() {
        _selectedPhoto = null;
        _activeMode = null;
      });
    } on Object catch (error) {
      _showError(error);
    }
  }

  Future<void> _showSuccessDialog(ScanResultModel result) {
    final points = result.totalPointsEarned;
    final message = result.isPhotoPending
        ? result.message
        : '+$points Dadaş Puan kazandınız.';

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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(error.toString())));
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

class _PhotoInstructionCard extends StatelessWidget {
  const _PhotoInstructionCard();

  @override
  Widget build(BuildContext context) {
    return const _InstructionCard(
      icon: Icons.photo_camera_outlined,
      title: 'Fotoğraf modu',
      message: 'Atığın fotoğrafını çekmek için kamerayı hizala',
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

class _UploadCard extends StatelessWidget {
  const _UploadCard({
    required this.selectedPhoto,
    required this.isLoading,
    required this.onPickCamera,
    required this.onPickGallery,
    required this.onSubmit,
  });

  final XFile? selectedPhoto;
  final bool isLoading;
  final VoidCallback onPickCamera;
  final VoidCallback onPickGallery;
  final VoidCallback onSubmit;

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
              const Icon(Icons.cloud_upload_outlined, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  selectedPhoto == null
                      ? 'Fotoğraf yükle ve inceleme kaydı oluştur'
                      : 'Seçilen fotoğraf: ${selectedPhoto!.name}',
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
              OutlinedButton.icon(
                onPressed: isLoading ? null : onPickCamera,
                icon: const Icon(Icons.photo_camera_outlined),
                label: const Text('Kamera'),
              ),
              OutlinedButton.icon(
                onPressed: isLoading ? null : onPickGallery,
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Galeri'),
              ),
              FilledButton.icon(
                onPressed: isLoading || selectedPhoto == null ? null : onSubmit,
                icon: const Icon(Icons.check),
                label: const Text('Kaydet'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DemoQrButtons extends StatelessWidget {
  const _DemoQrButtons({required this.isLoading, required this.onSubmit});

  final bool isLoading;
  final ValueChanged<String> onSubmit;

  static const _items = [
    ('Yakutiye QR Simüle Et', 'ATIKAVI_POINT_YAKUTIYE'),
    ('Sıfır Atık Kafe QR Simüle Et', 'ATIKAVI_POINT_ZERO_WASTE_CAFE'),
    ('Atatürk Üniversitesi QR Simüle Et', 'ATIKAVI_POINT_ATAUNI'),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final item in _items)
          OutlinedButton.icon(
            onPressed: isLoading ? null : () => onSubmit(item.$2),
            icon: const Icon(Icons.qr_code_2),
            label: Text(item.$1),
          ),
      ],
    );
  }
}

class _BarcodeDemoCard extends StatelessWidget {
  const _BarcodeDemoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        children: [
          const Icon(Icons.barcode_reader, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Demo barkod: PET şişe • 10 Dadaş Puan',
              style: AppTextStyles.body,
            ),
          ),
        ],
      ),
    );
  }
}
