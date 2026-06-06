import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/mock_data.dart';
import '../../core/theme/app_colors.dart';
import '../../models/recycling_point_model.dart';
import '../../providers/recycling_point_provider.dart';
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
    final selectedPoint = points.any((point) => point.id == _selectedPoint?.id)
        ? _selectedPoint
        : null;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          Positioned.fill(
            child: MockMapView(
              points: points,
              selectedPoint: selectedPoint,
              isLoading: pointsState.isLoading && !pointsState.hasValue,
              hasError: pointsState.hasError,
              onPointSelected: (point) {
                setState(() => _selectedPoint = point);
              },
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 14,
            child: MapFilterBar(
              selectedType: _selectedType,
              onSelected: (type) {
                setState(() {
                  _selectedType = type;
                  _selectedPoint = null;
                });
              },
            ),
          ),
          if (points.isEmpty && !pointsState.isLoading)
            const Positioned.fill(
              child: _MapMessage(message: 'Bu filtrede aktif nokta yok.'),
            ),
          if (selectedPoint != null)
            DraggableScrollableSheet(
              initialChildSize: 0.49,
              minChildSize: 0.32,
              maxChildSize: 0.82,
              snap: true,
              snapSizes: const [0.49, 0.82],
              builder: (context, scrollController) {
                return PointDetailSheet(
                  point: selectedPoint,
                  scrollController: scrollController,
                  onClose: () => setState(() => _selectedPoint = null),
                );
              },
            ),
        ],
      ),
    );
  }

  List<RecyclingPointModel> _filteredPoints(List<RecyclingPointModel> points) {
    if (_selectedType == 'all') return points;
    return points.where((point) => point.type == _selectedType).toList();
  }
}

class _MapMessage extends StatelessWidget {
  const _MapMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.outlineVariant),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
