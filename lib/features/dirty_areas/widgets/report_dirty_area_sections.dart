import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class ReportSectionTitle extends StatelessWidget {
  const ReportSectionTitle(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      _turkishUpperCase(title),
      style: AppTextStyles.subtitle.copyWith(
        color: AppColors.primary,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.7,
      ),
    );
  }
}

String _turkishUpperCase(String value) {
  return value.replaceAll('i', 'İ').replaceAll('ı', 'I').toUpperCase();
}

class ReportLocationSection extends StatelessWidget {
  const ReportLocationSection({
    required this.latitude,
    required this.longitude,
    required this.hasSelectedLocation,
    required this.isLoading,
    required this.onUseCurrentLocation,
    required this.onSelectLocation,
    super.key,
  });

  final double latitude;
  final double longitude;
  final bool hasSelectedLocation;
  final bool isLoading;
  final VoidCallback onUseCurrentLocation;
  final VoidCallback onSelectLocation;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const ReportSectionTitle('Konum Bilgisi'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _LocationAction(
                icon: Icons.my_location_outlined,
                label: 'Mevcut konumumu kullan',
                selected: hasSelectedLocation,
                isLoading: isLoading,
                onTap: onUseCurrentLocation,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _LocationAction(
                icon: Icons.map_outlined,
                label: 'Haritadan konum seç',
                onTap: onSelectLocation,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: AppColors.primaryFixed.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.location_on_outlined,
                  color: AppColors.primary,
                  size: 30,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasSelectedLocation ? 'Seçilen konum' : 'Erzurum merkez',
                      style: AppTextStyles.subtitle.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.check_circle_outline, color: AppColors.primary),
            ],
          ),
        ),
      ],
    );
  }
}

class _LocationAction extends StatelessWidget {
  const _LocationAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
    this.isLoading = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppColors.primaryFixed.withValues(alpha: 0.75)
          : AppColors.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.outlineVariant),
      ),
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(14),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 88),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Icon(icon, color: AppColors.primary, size: 28),
                const SizedBox(height: 8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ReportPhotoSection extends StatelessWidget {
  const ReportPhotoSection({
    required this.photo,
    required this.onPickPhoto,
    required this.onRemovePhoto,
    super.key,
  });

  final XFile? photo;
  final VoidCallback onPickPhoto;
  final VoidCallback onRemovePhoto;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const ReportSectionTitle('Fotoğraf Ekle'),
        const SizedBox(height: 12),
        CustomPaint(
          painter: _DashedBorderPainter(),
          child: Material(
            color: AppColors.surfaceContainer.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(24),
            child: InkWell(
              onTap: onPickPhoto,
              borderRadius: BorderRadius.circular(24),
              child: SizedBox(
                height: 210,
                child: Stack(
                  children: [
                    const Positioned(top: 16, right: 16, child: _AiBadge()),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: const BoxDecoration(
                              color: AppColors.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.photo_camera_outlined,
                              color: AppColors.onPrimary,
                              size: 38,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Yeni Fotoğraf Çek veya Yükle',
                            style: AppTextStyles.subtitle.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (photo != null) ...[
          const SizedBox(height: 14),
          Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 92,
                      height: 92,
                      child: FutureBuilder(
                        future: photo!.readAsBytes(),
                        builder: (context, snapshot) {
                          final bytes = snapshot.data;
                          if (bytes == null) {
                            return const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            );
                          }
                          return Image.memory(bytes, fit: BoxFit.cover);
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    top: -7,
                    right: -7,
                    child: IconButton.filled(
                      onPressed: onRemovePhoto,
                      visualDensity: VisualDensity.compact,
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: AppColors.onError,
                      ),
                      icon: const Icon(Icons.close, size: 17),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              InkWell(
                onTap: onPickPhoto,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.outlineVariant),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: AppColors.textSecondary,
                    size: 30,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _AiBadge extends StatelessWidget {
  const _AiBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.tertiary,
        borderRadius: BorderRadius.circular(999),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        '✦ AI Analiz Bekleniyor',
        style: AppTextStyles.caption.copyWith(
          color: AppColors.onTertiary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class ReportWasteOption {
  const ReportWasteOption({
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final IconData icon;
}

class ReportWasteGrid extends StatelessWidget {
  const ReportWasteGrid({
    required this.options,
    required this.selectedValues,
    required this.onToggle,
    super.key,
  });

  final List<ReportWasteOption> options;
  final Set<String> selectedValues;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const ReportSectionTitle('Atık Türü'),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = (constraints.maxWidth - 20) / 3;
            return Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final option in options)
                  SizedBox(
                    width: width,
                    child: _WasteCard(
                      option: option,
                      selected: selectedValues.contains(option.value),
                      onTap: () => onToggle(option.value),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _WasteCard extends StatelessWidget {
  const _WasteCard({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final ReportWasteOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppColors.primaryFixed.withValues(alpha: 0.65)
          : AppColors.surfaceContainer,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 82,
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: selected
                ? Border.all(color: AppColors.primary, width: 1.5)
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(option.icon, color: AppColors.primary, size: 25),
              const SizedBox(height: 7),
              Text(
                option.label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primaryDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ReportSeveritySelector extends StatelessWidget {
  const ReportSeveritySelector({
    required this.selectedIndex,
    required this.onSelected,
    super.key,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static const labels = ['Az', 'Orta', 'Yoğun', 'Çok yoğun'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const ReportSectionTitle('Kirlilik Seviyesi'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            children: [
              for (var index = 0; index < labels.length; index++)
                Expanded(
                  child: InkWell(
                    onTap: () => onSelected(index),
                    borderRadius: BorderRadius.circular(999),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      decoration: BoxDecoration(
                        color: index == selectedIndex
                            ? AppColors.primary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        labels[index],
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        style: AppTextStyles.body.copyWith(
                          color: index == selectedIndex
                              ? AppColors.onPrimary
                              : AppColors.textPrimary,
                          fontWeight: index == selectedIndex
                              ? FontWeight.w800
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: (selectedIndex + 1) / labels.length,
            minHeight: 8,
            backgroundColor: AppColors.surfaceContainerHigh,
            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
          ),
        ),
      ],
    );
  }
}

class ReportInfoBox extends StatelessWidget {
  const ReportInfoBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainer,
        border: Border(left: BorderSide(color: AppColors.primary, width: 4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: AppColors.primary, size: 21),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Yüklediğiniz fotoğraflar ve konum bilginiz doğrulama amacıyla kullanılacaktır. AI analizi güvenli sunucu entegrasyonu tamamlandığında etkinleştirilecektir.',
              style: AppTextStyles.caption.copyWith(height: 1.55),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.outlineVariant
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(24)),
      );
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + 8), paint);
        distance += 14;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
