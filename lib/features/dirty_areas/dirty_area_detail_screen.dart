import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/dirty_area_model.dart';
import '../../providers/cleanup_event_provider.dart';
import '../../providers/dirty_area_provider.dart';
import '../../shared/widgets/empty_state.dart';
import 'widgets/cleanup_event_card.dart';

class DirtyAreaDetailScreen extends ConsumerWidget {
  const DirtyAreaDetailScreen({required this.dirtyAreaId, super.key});

  final String dirtyAreaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dirtyAreaState = ref.watch(dirtyAreaDetailProvider(dirtyAreaId));

    return Scaffold(
      appBar: AppBar(title: const Text('Kirli Bölge Detayı')),
      body: SafeArea(
        child: dirtyAreaState.when(
          data: (dirtyArea) {
            if (dirtyArea == null) {
              return const Padding(
                padding: EdgeInsets.all(18),
                child: EmptyState(
                  title: 'Kayıt bulunamadı',
                  message: 'Bu kirli bölge kaydı silinmiş veya erişilemiyor.',
                  icon: Icons.location_off_outlined,
                ),
              );
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
              children: [
                if (dirtyArea.photoUrl != null &&
                    dirtyArea.photoUrl!.isNotEmpty) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Image.network(
                        dirtyArea.photoUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const ColoredBox(
                          color: AppColors.surfaceContainer,
                          child: Center(child: Icon(Icons.image_not_supported)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                ],
                Text(
                  dirtyArea.title,
                  style: AppTextStyles.title.copyWith(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  dirtyArea.description,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 18),
                _DetailTile(
                  icon: Icons.place_outlined,
                  title: 'Adres',
                  value: dirtyArea.addressText,
                ),
                _DetailTile(
                  icon: Icons.my_location_outlined,
                  title: 'Koordinatlar',
                  value:
                      'Enlem: ${dirtyArea.latitude.toStringAsFixed(6)}\n'
                      'Boylam: ${dirtyArea.longitude.toStringAsFixed(6)}',
                ),
                _DetailTile(
                  icon: Icons.warning_amber_outlined,
                  title: 'Kirlilik Seviyesi',
                  value: '${dirtyArea.severityLevel}/5',
                ),
                _DetailTile(
                  icon: Icons.recycling_outlined,
                  title: 'Atık Türleri',
                  value: dirtyArea.wasteTypes.map(_wasteTypeLabel).join(', '),
                ),
                _DetailTile(
                  icon: Icons.flag_outlined,
                  title: 'Durum',
                  value: _statusLabel(dirtyArea.status),
                ),
                _DetailTile(
                  icon: Icons.person_outline,
                  title: 'Bildiren',
                  value: dirtyArea.reportedByUsername,
                ),
                const SizedBox(height: 8),
                _PhotoAnalysisSection(dirtyArea: dirtyArea),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => context.go(
                    '/dirty-areas/${dirtyArea.id}/create-cleanup-event',
                  ),
                  icon: const Icon(Icons.event_available_outlined),
                  label: const Text('Temizlik Etkinliği Oluştur'),
                ),
                const SizedBox(height: 26),
                _CleanupEventsSection(dirtyAreaId: dirtyArea.id),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => const Padding(
            padding: EdgeInsets.all(18),
            child: EmptyState(
              title: 'Detay yüklenemedi',
              message: 'Kirli bölge detayı şu anda alınamadı.',
              icon: Icons.error_outline,
            ),
          ),
        ),
      ),
    );
  }
}

class _PhotoAnalysisSection extends StatelessWidget {
  const _PhotoAnalysisSection({required this.dirtyArea});

  final DirtyAreaModel dirtyArea;

  @override
  Widget build(BuildContext context) {
    final summary = dirtyArea.aiAnalysisSummary?.trim();
    final isGeminiPending =
        dirtyArea.aiAnalysisProvider == null ||
        dirtyArea.aiAnalysisProvider == 'mock';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fotoğraf Analizi',
            style: AppTextStyles.title.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Durum: ${_analysisStatusLabel(dirtyArea.photoAnalysisStatus)}',
            style: AppTextStyles.body,
          ),
          if (dirtyArea.aiCleanlinessScore != null) ...[
            const SizedBox(height: 6),
            Text(
              'Kirlilik skoru: ${dirtyArea.aiCleanlinessScore}/100',
              style: AppTextStyles.body,
            ),
          ],
          if (dirtyArea.aiWasteMatchScore != null) ...[
            const SizedBox(height: 6),
            Text(
              'Atık uyum skoru: ${dirtyArea.aiWasteMatchScore}/100',
              style: AppTextStyles.body,
            ),
          ],
          if (dirtyArea.aiDetectedWasteTypes.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final type in dirtyArea.aiDetectedWasteTypes)
                  Chip(label: Text(_wasteTypeLabel(type))),
              ],
            ),
          ],
          const SizedBox(height: 10),
          Text(
            isGeminiPending || summary == null || summary.isEmpty
                ? 'Fotoğraf analizi Gemini entegrasyonu sonrası otomatik yapılacak.'
                : summary,
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _CleanupEventsSection extends ConsumerWidget {
  const _CleanupEventsSection({required this.dirtyAreaId});

  final String dirtyAreaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsState = ref.watch(
      cleanupEventsForDirtyAreaProvider(dirtyAreaId),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Planlanan Temizlik Etkinlikleri',
          style: AppTextStyles.title.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 12),
        eventsState.when(
          data: (events) {
            if (events.isEmpty) {
              return const EmptyState(
                title: 'Etkinlik yok',
                message:
                    'Bu bölge için henüz temizlik etkinliği oluşturulmadı.',
                icon: Icons.event_note_outlined,
              );
            }

            return Column(
              children: [
                for (final event in events) ...[
                  CleanupEventCard(
                    cleanupEvent: event,
                    onOpenDetail: () =>
                        context.go('/cleanup-events/${event.id}'),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => const EmptyState(
            title: 'Etkinlikler yüklenemedi',
            message: 'Bu bölgeye ait etkinlikler şu anda alınamadı.',
            icon: Icons.error_outline,
          ),
        ),
      ],
    );
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final displayValue = value.trim().isEmpty ? '-' : value;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(displayValue, style: AppTextStyles.body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _statusLabel(String status) {
  return switch (status) {
    DirtyAreaStatuses.reported => 'Bildirildi',
    DirtyAreaStatuses.planned => 'Planlandı',
    DirtyAreaStatuses.inProgress => 'Sürüyor',
    DirtyAreaStatuses.cleaned => 'Temizlendi',
    DirtyAreaStatuses.rejected => 'Reddedildi',
    _ => 'Bilinmiyor',
  };
}

String _analysisStatusLabel(String status) {
  return switch (status) {
    PhotoAnalysisStatuses.notStarted => 'Başlatılmadı',
    PhotoAnalysisStatuses.pending => 'Bekliyor',
    PhotoAnalysisStatuses.approved => 'Onaylandı',
    PhotoAnalysisStatuses.rejected => 'Reddedildi',
    PhotoAnalysisStatuses.needsReview => 'İnceleme gerekli',
    PhotoAnalysisStatuses.failed => 'Başarısız',
    _ => status,
  };
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
