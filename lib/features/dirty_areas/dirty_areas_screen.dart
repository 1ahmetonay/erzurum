import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/dirty_area_model.dart';
import '../../providers/dirty_area_provider.dart';
import '../../shared/widgets/empty_state.dart';

class DirtyAreasScreen extends ConsumerWidget {
  const DirtyAreasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dirtyAreasState = ref.watch(dirtyAreasProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Kirli Bölgeler')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/report-dirty-area'),
        icon: const Icon(Icons.add_location_alt_outlined),
        label: const Text('Kirli Bölge Bildir'),
      ),
      body: SafeArea(
        child: dirtyAreasState.when(
          data: (dirtyAreas) {
            if (dirtyAreas.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(18),
                child: EmptyState(
                  title: 'Henüz bildirim yok',
                  message:
                      'Atık yoğunluğu olan alanları bildirerek topluluk temizliği için ilk kaydı oluşturabilirsin.',
                  icon: Icons.cleaning_services_outlined,
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 100),
              itemCount: dirtyAreas.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final dirtyArea = dirtyAreas[index];
                return _DirtyAreaCard(
                  dirtyArea: dirtyArea,
                  onTap: () => context.go('/dirty-areas/${dirtyArea.id}'),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => const Padding(
            padding: EdgeInsets.all(18),
            child: EmptyState(
              title: 'Bildirimler yüklenemedi',
              message:
                  'Kirli bölge kayıtları şu anda alınamadı. Biraz sonra tekrar dene.',
              icon: Icons.error_outline,
            ),
          ),
        ),
      ),
    );
  }
}

class _DirtyAreaCard extends StatelessWidget {
  const _DirtyAreaCard({required this.dirtyArea, required this.onTap});

  final DirtyAreaModel dirtyArea;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (dirtyArea.photoUrl != null && dirtyArea.photoUrl!.isNotEmpty)
              AspectRatio(
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
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          dirtyArea.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.subtitle.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      _StatusChip(status: dirtyArea.status),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    dirtyArea.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _MetaChip(
                        icon: Icons.warning_amber_outlined,
                        label: 'Seviye ${dirtyArea.severityLevel}/5',
                      ),
                      _MetaChip(
                        icon: Icons.groups_outlined,
                        label: '${dirtyArea.participantCount} katılımcı',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryFixed.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _statusLabel(status),
        style: AppTextStyles.caption.copyWith(
          color: AppColors.primaryDark,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(label, style: AppTextStyles.caption),
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
