import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
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
  XFile? _selectedPhoto;

  @override
  Widget build(BuildContext context) {
    final scanState = ref.watch(scanControllerProvider);
    final result = scanState.valueOrNull;

    return Scaffold(
      body: SafeArea(
        child: DefaultTabController(
          length: 3,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              const SectionHeader(
                title: 'Atık Tara',
                subtitle: 'QR, fotoğraf veya barkod ile atık kaydı oluştur.',
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.outline),
                ),
                child: const TabBar(
                  indicatorSize: TabBarIndicatorSize.tab,
                  tabs: [
                    Tab(icon: Icon(Icons.qr_code_scanner), text: 'QR Tara'),
                    Tab(icon: Icon(Icons.photo_camera_outlined), text: 'Foto'),
                    Tab(icon: Icon(Icons.barcode_reader), text: 'Barkod'),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              QrScannerView(
                isProcessing: scanState.isLoading,
                onQrDetected: _submitQrCode,
              ),
              if (kDebugMode) ...[
                const SizedBox(height: 12),
                _DemoQrButtons(
                  isLoading: scanState.isLoading,
                  onSubmit: _submitQrCode,
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
              _UploadCard(
                selectedPhoto: _selectedPhoto,
                isLoading: scanState.isLoading,
                onPickCamera: () => _pickPhoto(ImageSource.camera),
                onPickGallery: () => _pickPhoto(ImageSource.gallery),
                onSubmit: _submitPhotoWaste,
              ),
              const SizedBox(height: 12),
              const _BarcodeDemoCard(),
              if (scanState.isLoading) ...[
                const SizedBox(height: 16),
                const Center(child: CircularProgressIndicator()),
              ],
              if (result != null) ...[
                const SizedBox(height: 16),
                SuccessOverlay(
                  title: result.isPhotoPending
                      ? 'İnceleme kaydı alındı'
                      : 'Kayıt tamamlandı',
                  message: result.message,
                  bonusPoints: result.bonusPoints,
                  completedTaskTitles: result.completedTaskTitles,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _selectWasteType(String wasteType) {
    setState(() => _selectedWasteType = wasteType);
  }

  Future<void> _submitQrCode(String qrCode) async {
    try {
      await ref
          .read(scanControllerProvider.notifier)
          .submitQrCode(qrCode, selectedWasteType: _selectedWasteType);
    } on Object catch (error) {
      _showError(error);
    }
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
      setState(() => _selectedPhoto = null);
    } on Object catch (error) {
      _showError(error);
    }
  }

  void _showError(Object error) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(error.toString())));
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.outline),
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
