import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/mock_data.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/recycling_point_model.dart';
import '../../providers/recycling_point_provider.dart';
import '../../shared/widgets/section_header.dart';
import 'widgets/map_filter_bar.dart';
import 'widgets/mock_map_view.dart';
import 'widgets/point_detail_sheet.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  var _selectedType = 'all';
  RecyclingPointModel? _selectedPoint;

  @override
  Widget build(BuildContext context) {
    final pointsState = ref.watch(activeRecyclingPointsProvider);
    final sourcePoints = pointsState.valueOrNull ?? MockData.recyclingPoints;
    final points = _filteredPoints(sourcePoints);
    final selectedPoint = points.contains(_selectedPoint)
        ? _selectedPoint
        : _firstOrNull(points);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            const SectionHeader(
              title: 'Harita',
              subtitle: 'Yakındaki geri dönüşüm noktalarını keşfet.',
            ),
            const SizedBox(height: 16),
            MapFilterBar(
              selectedType: _selectedType,
              onSelected: (type) {
                setState(() {
                  _selectedType = type;
                  _selectedPoint = null;
                });
              },
            ),
            const SizedBox(height: 16),
            if (pointsState.isLoading && !pointsState.hasValue)
              const _LoadingState()
            else ...[
              if (pointsState.hasError) ...[
                const _ErrorState(
                  message:
                      'Geri dönüşüm noktaları yüklenemedi. Demo noktalarla devam edebilirsin.',
                ),
                const SizedBox(height: 12),
              ],
              if (points.isEmpty)
                const _EmptyState(message: 'Bu filtrede aktif nokta yok.')
              else
                MockMapView(
                  points: points,
                  selectedPoint: selectedPoint,
                  onPointSelected: (point) {
                    setState(() => _selectedPoint = point);
                  },
                ),
            ],
            const SizedBox(height: 16),
            if (selectedPoint != null) PointDetailSheet(point: selectedPoint),
            const SizedBox(height: 12),
            Text(
              'Google Maps bağlantısı sonraki aşamada aktif edilecek.',
              textAlign: TextAlign.center,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<RecyclingPointModel> _filteredPoints(List<RecyclingPointModel> points) {
    if (_selectedType == 'all') return points;
    return points.where((point) => point.type == _selectedType).toList();
  }

  RecyclingPointModel? _firstOrNull(List<RecyclingPointModel> points) {
    return points.isEmpty ? null : points.first;
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 48),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.winterLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.winterIce),
      ),
      child: Text(
        message,
        style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(message, style: AppTextStyles.body),
    );
  }
}
