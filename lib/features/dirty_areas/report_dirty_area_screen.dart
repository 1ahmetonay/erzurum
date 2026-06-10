import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/dirty_area_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dirty_area_provider.dart';
import '../../providers/location_provider.dart';
import '../../providers/user_provider.dart';
import '../../repositories/dirty_area_repository.dart';
import '../../services/dirty_area_photo_service.dart';
import '../../services/location_service.dart';
import '../../shared/widgets/app_status_dialog.dart';
import 'widgets/report_dirty_area_sections.dart';

class ReportDirtyAreaScreen extends ConsumerStatefulWidget {
  const ReportDirtyAreaScreen({super.key});

  @override
  ConsumerState<ReportDirtyAreaScreen> createState() =>
      _ReportDirtyAreaScreenState();
}

class _ReportDirtyAreaScreenState extends ConsumerState<ReportDirtyAreaScreen> {
  static const _erzurumLatitude = 39.9055;
  static const _erzurumLongitude = 41.2658;
  static const _severityValues = [1, 2, 4, 5];
  static const _wasteOptions = [
    ReportWasteOption(
      value: DirtyAreaWasteTypes.plastic,
      label: 'Plastik atık',
      icon: Icons.recycling_outlined,
    ),
    ReportWasteOption(
      value: DirtyAreaWasteTypes.glass,
      label: 'Cam/şişe',
      icon: Icons.wine_bar_outlined,
    ),
    ReportWasteOption(
      value: DirtyAreaWasteTypes.paper,
      label: 'Kağıt/karton',
      icon: Icons.description_outlined,
    ),
    ReportWasteOption(
      value: DirtyAreaWasteTypes.household,
      label: 'Evsel atık',
      icon: Icons.delete_outline,
    ),
    ReportWasteOption(
      value: DirtyAreaWasteTypes.construction,
      label: 'İnşaat atığı',
      icon: Icons.construction_outlined,
    ),
    ReportWasteOption(
      value: DirtyAreaWasteTypes.other,
      label: 'Diğer',
      icon: Icons.more_horiz,
    ),
  ];

  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _imagePicker = ImagePicker();
  final Set<String> _selectedWasteTypes = {DirtyAreaWasteTypes.plastic};

  XFile? _selectedPhoto;
  double _latitude = _erzurumLatitude;
  double _longitude = _erzurumLongitude;
  String _addressText = 'Erzurum merkez';
  bool _hasSelectedLocation = false;
  int _severityIndex = 2;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(currentLocationControllerProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          onPressed: _close,
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Geri',
        ),
        title: Text(
          'Kirli Bölge Bildir',
          style: AppTextStyles.title.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_outlined),
            color: AppColors.primary,
            tooltip: 'Bildirimler',
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 30),
            children: [
              Text(
                'Çevrendeki kirli alanları bildir, Erzurum’u birlikte temiz tutalım.',
                style: AppTextStyles.body.copyWith(fontSize: 16, height: 1.55),
              ),
              const SizedBox(height: 28),
              ReportLocationSection(
                latitude: _latitude,
                longitude: _longitude,
                hasSelectedLocation: _hasSelectedLocation,
                isLoading: locationState.isLoading,
                onUseCurrentLocation: _useCurrentLocation,
                onSelectLocation: _showManualLocationDialog,
              ),
              const SizedBox(height: 30),
              ReportPhotoSection(
                photo: _selectedPhoto,
                onPickPhoto: _showPhotoSourceSheet,
                onRemovePhoto: () => setState(() => _selectedPhoto = null),
              ),
              const SizedBox(height: 32),
              ReportWasteGrid(
                options: _wasteOptions,
                selectedValues: _selectedWasteTypes,
                onToggle: _toggleWasteType,
              ),
              const SizedBox(height: 30),
              ReportSeveritySelector(
                selectedIndex: _severityIndex,
                onSelected: (index) {
                  setState(() => _severityIndex = index);
                },
              ),
              const SizedBox(height: 30),
              const ReportSectionTitle('Açıklama'),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descriptionController,
                minLines: 5,
                maxLines: 7,
                maxLength: 1000,
                decoration: const InputDecoration(
                  hintText: 'Kirlilik hakkında kısa açıklama yaz...',
                  alignLabelWithHint: true,
                  counterText: '',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Açıklama boş olamaz.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 26),
              const ReportInfoBox(),
              const SizedBox(height: 22),
              FilledButton.icon(
                onPressed: _isSubmitting ? null : _submit,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(62),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  textStyle: AppTextStyles.title.copyWith(
                    color: AppColors.onPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.onPrimary,
                        ),
                      )
                    : const Icon(Icons.send_outlined, size: 28),
                label: const Text('Bildirimi Gönder'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _close() {
    if (_isSubmitting) return;
    context.go('/home');
  }

  void _toggleWasteType(String value) {
    setState(() {
      if (_selectedWasteTypes.contains(value)) {
        if (_selectedWasteTypes.length > 1) _selectedWasteTypes.remove(value);
      } else {
        _selectedWasteTypes.add(value);
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final selectedPhoto = _selectedPhoto;
    if (selectedPhoto == null) {
      _showMessage('Kirli bölge bildirimi için lütfen bir fotoğraf ekleyin.');
      return;
    }

    final firebaseUser = ref.read(authStateProvider).valueOrNull;
    if (firebaseUser == null) {
      _showMessage('Kirli bölge bildirmek için giriş yapmalısın.');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final profile = ref.read(currentUserProvider).valueOrNull;
      final username = (profile?.displayName.trim().isNotEmpty ?? false)
          ? profile!.displayName.trim()
          : (firebaseUser.displayName?.trim().isNotEmpty ?? false)
          ? firebaseUser.displayName!.trim()
          : firebaseUser.email ?? 'AtıkAvı kullanıcısı';
      final now = DateTime.now();
      final photoUrl = await ref
          .read(dirtyAreaPhotoServiceProvider)
          .uploadDirtyAreaPhoto(userId: firebaseUser.uid, photo: selectedPhoto);
      final primaryWasteType = _selectedWasteTypes.first;
      final dirtyArea = DirtyAreaModel(
        id: '',
        title: '${_wasteTypeLabel(primaryWasteType)} bildirimi',
        description: _descriptionController.text.trim(),
        reportedByUserId: firebaseUser.uid,
        reportedByUsername: username,
        latitude: _latitude,
        longitude: _longitude,
        addressText: _addressText,
        photoUrl: photoUrl,
        wasteTypes: _selectedWasteTypes.toList()..sort(),
        severityLevel: _severityValues[_severityIndex],
        status: DirtyAreaStatuses.reported,
        participantCount: 0,
        createdAt: now,
        updatedAt: now,
      );

      await ref.read(dirtyAreaRepositoryProvider).createDirtyArea(dirtyArea);
      if (!mounted) return;
      context.go('/dirty-areas');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kirli bölge bildirimi oluşturuldu.')),
      );
    } on DirtyAreaRepositoryException catch (error) {
      if (mounted) await _showSubmissionError(error.message);
    } on DirtyAreaPhotoException catch (error) {
      if (mounted) await _showSubmissionError(error.message);
    } on Object {
      if (mounted) {
        await _showSubmissionError(
          'Bildirim gönderilemedi. Biraz sonra tekrar dene.',
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _showSubmissionError(String message) {
    return AppStatusDialog.showError(
      context,
      title: 'Bildirim yüklenemedi',
      message: message,
    );
  }

  Future<void> _useCurrentLocation() async {
    try {
      final location = await ref
          .read(currentLocationControllerProvider.notifier)
          .load();
      if (location == null || !mounted) return;
      setState(() {
        _latitude = location.latitude;
        _longitude = location.longitude;
        _addressText = 'Mevcut konum, Erzurum';
        _hasSelectedLocation = true;
      });
      _showMessage('Mevcut konum eklendi.');
    } on LocationServiceException catch (error) {
      if (mounted) _showMessage(error.message);
    } on Object {
      if (mounted) {
        _showMessage('Konum alınamadı. Manuel konum seçmeyi deneyebilirsin.');
      }
    }
  }

  Future<void> _showManualLocationDialog() async {
    // TODO: Replace manual coordinate dialog with interactive map picker.
    final latitudeController = TextEditingController(
      text: _latitude.toStringAsFixed(6),
    );
    final longitudeController = TextEditingController(
      text: _longitude.toStringAsFixed(6),
    );
    final formKey = GlobalKey<FormState>();
    final result = await showDialog<AppLocation>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Haritadan Konum Seç'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: latitudeController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                decoration: const InputDecoration(labelText: 'Enlem'),
                validator: (value) => _coordinateError(value, -90, 90),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: longitudeController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                decoration: const InputDecoration(labelText: 'Boylam'),
                validator: (value) => _coordinateError(value, -180, 180),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(
                dialogContext,
                AppLocation(
                  latitude: double.parse(latitudeController.text.trim()),
                  longitude: double.parse(longitudeController.text.trim()),
                ),
              );
            },
            child: const Text('Konumu Kaydet'),
          ),
        ],
      ),
    );
    latitudeController.dispose();
    longitudeController.dispose();
    if (result == null || !mounted) return;
    setState(() {
      _latitude = result.latitude;
      _longitude = result.longitude;
      _addressText = 'Haritadan seçilen konum, Erzurum';
      _hasSelectedLocation = true;
    });
  }

  String? _coordinateError(String? value, double min, double max) {
    final coordinate = double.tryParse(value?.trim() ?? '');
    if (coordinate == null) return 'Geçerli bir sayı gir.';
    if (coordinate < min || coordinate > max) {
      return '$min ile $max arasında olmalı.';
    }
    return null;
  }

  Future<void> _showPhotoSourceSheet() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Galeriden seç'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Kamera ile çek'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    try {
      final photo = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1600,
        imageQuality: 82,
      );
      if (photo != null && mounted) setState(() => _selectedPhoto = photo);
    } on Object {
      if (mounted) {
        _showMessage('Fotoğraf seçilemedi. Uygulama izinlerini kontrol et.');
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

String _wasteTypeLabel(String wasteType) {
  return switch (wasteType) {
    DirtyAreaWasteTypes.plastic => 'Plastik atık',
    DirtyAreaWasteTypes.glass => 'Cam/şişe',
    DirtyAreaWasteTypes.paper => 'Kağıt/karton',
    DirtyAreaWasteTypes.household => 'Evsel atık',
    DirtyAreaWasteTypes.construction => 'İnşaat atığı',
    DirtyAreaWasteTypes.other => 'Diğer atık',
    DirtyAreaWasteTypes.metal => 'Metal',
    DirtyAreaWasteTypes.organic => 'Organik',
    DirtyAreaWasteTypes.mixed => 'Karışık',
    _ => wasteType,
  };
}
