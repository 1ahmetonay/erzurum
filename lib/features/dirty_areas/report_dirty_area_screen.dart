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

class ReportDirtyAreaScreen extends ConsumerStatefulWidget {
  const ReportDirtyAreaScreen({super.key});

  @override
  ConsumerState<ReportDirtyAreaScreen> createState() =>
      _ReportDirtyAreaScreenState();
}

class _ReportDirtyAreaScreenState extends ConsumerState<ReportDirtyAreaScreen> {
  static const _erzurumLatitude = 39.9055;
  static const _erzurumLongitude = 41.2658;

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _imagePicker = ImagePicker();
  final Set<String> _selectedWasteTypes = {DirtyAreaWasteTypes.mixed};
  XFile? _selectedPhoto;
  double _latitude = _erzurumLatitude;
  double _longitude = _erzurumLongitude;
  bool _hasSelectedLocation = false;
  int _severityLevel = 3;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kirli Bölge Bildir')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
            children: [
              TextFormField(
                controller: _titleController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Başlık',
                  hintText: 'Örn. Yakutiye park çevresi',
                ),
                validator: (value) =>
                    _requiredText(value, 'Başlık boş olamaz.'),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _descriptionController,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Açıklama',
                  hintText: 'Atık yoğunluğunu ve gözlemini kısaca yaz.',
                ),
                validator: (value) =>
                    _requiredText(value, 'Açıklama boş olamaz.'),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _addressController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Adres / metin konum',
                  hintText: 'Mahalle, cadde veya yakın nokta',
                ),
                validator: (value) =>
                    _requiredText(value, 'Adres bilgisi boş olamaz.'),
              ),
              const SizedBox(height: 14),
              _LocationSection(
                latitude: _latitude,
                longitude: _longitude,
                hasSelectedLocation: _hasSelectedLocation,
                isLoading: ref
                    .watch(currentLocationControllerProvider)
                    .isLoading,
                onUseCurrentLocation: _useCurrentLocation,
                onSelectLocation: _showManualLocationDialog,
              ),
              const SizedBox(height: 20),
              Text(
                'Kirlilik seviyesi',
                style: AppTextStyles.subtitle.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              Slider(
                value: _severityLevel.toDouble(),
                min: 1,
                max: 5,
                divisions: 4,
                label: '$_severityLevel/5',
                onChanged: (value) {
                  setState(() => _severityLevel = value.round());
                },
              ),
              const SizedBox(height: 12),
              Text(
                'Atık türleri',
                style: AppTextStyles.subtitle.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final wasteType in DirtyAreaWasteTypes.values)
                    FilterChip(
                      label: Text(_wasteTypeLabel(wasteType)),
                      selected: _selectedWasteTypes.contains(wasteType),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedWasteTypes.add(wasteType);
                          } else if (_selectedWasteTypes.length > 1) {
                            _selectedWasteTypes.remove(wasteType);
                          }
                        });
                      },
                    ),
                ],
              ),
              const SizedBox(height: 18),
              _PhotoSection(
                photo: _selectedPhoto,
                onPickPhoto: _showPhotoSourceSheet,
                onRemovePhoto: () => setState(() => _selectedPhoto = null),
              ),
              const SizedBox(height: 22),
              FilledButton.icon(
                onPressed: _isSubmitting ? null : _submit,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send_outlined),
                label: const Text('Bildirimi Gönder'),
              ),
            ],
          ),
        ),
      ),
    );
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
      final dirtyArea = DirtyAreaModel(
        id: '',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        reportedByUserId: firebaseUser.uid,
        reportedByUsername: username,
        latitude: _latitude,
        longitude: _longitude,
        addressText: _addressController.text.trim(),
        photoUrl: photoUrl,
        wasteTypes: _selectedWasteTypes.toList()..sort(),
        severityLevel: _severityLevel,
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
      if (mounted) _showMessage(error.message);
    } on DirtyAreaPhotoException catch (error) {
      if (mounted) _showMessage(error.message);
    } on Object {
      if (mounted) {
        _showMessage('Bildirim gönderilemedi. Biraz sonra tekrar dene.');
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
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
        title: const Text('Konum Seç'),
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

  String? _requiredText(String? value, String message) {
    if (value == null || value.trim().isEmpty) return message;
    return null;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _LocationSection extends StatelessWidget {
  const _LocationSection({
    required this.latitude,
    required this.longitude,
    required this.hasSelectedLocation,
    required this.isLoading,
    required this.onUseCurrentLocation,
    required this.onSelectLocation,
  });

  final double latitude;
  final double longitude;
  final bool hasSelectedLocation;
  final bool isLoading;
  final VoidCallback onUseCurrentLocation;
  final VoidCallback onSelectLocation;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Konum', style: AppTextStyles.subtitle),
          const SizedBox(height: 8),
          Text(
            hasSelectedLocation
                ? 'Enlem: ${latitude.toStringAsFixed(6)}\nBoylam: ${longitude.toStringAsFixed(6)}'
                : 'Konum seçilmezse Erzurum merkez kullanılacak.',
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.tonalIcon(
                onPressed: isLoading ? null : onUseCurrentLocation,
                icon: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.my_location_outlined),
                label: const Text('Mevcut Konumumu Kullan'),
              ),
              OutlinedButton.icon(
                onPressed: onSelectLocation,
                icon: const Icon(Icons.map_outlined),
                label: const Text('Konum Seç'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PhotoSection extends StatelessWidget {
  const _PhotoSection({
    required this.photo,
    required this.onPickPhoto,
    required this.onRemovePhoto,
  });

  final XFile? photo;
  final VoidCallback onPickPhoto;
  final VoidCallback onRemovePhoto;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (photo != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: FutureBuilder(
                  future: photo!.readAsBytes(),
                  builder: (context, snapshot) {
                    final bytes = snapshot.data;
                    if (bytes == null) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return Image.memory(bytes, fit: BoxFit.cover);
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: onRemovePhoto,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Fotoğrafı Kaldır'),
            ),
          ] else
            OutlinedButton.icon(
              onPressed: onPickPhoto,
              icon: const Icon(Icons.add_a_photo_outlined),
              label: const Text('Fotoğraf Ekle'),
            ),
        ],
      ),
    );
  }
}

String _wasteTypeLabel(String wasteType) {
  return switch (wasteType) {
    DirtyAreaWasteTypes.plastic => 'Plastik',
    DirtyAreaWasteTypes.glass => 'Cam',
    DirtyAreaWasteTypes.paper => 'Kağıt',
    DirtyAreaWasteTypes.metal => 'Metal',
    DirtyAreaWasteTypes.organic => 'Organik',
    DirtyAreaWasteTypes.mixed => 'Karışık',
    _ => wasteType,
  };
}
