import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/recycling_point_model.dart';

class MockMapView extends StatelessWidget {
  const MockMapView({
    required this.points,
    required this.selectedPoint,
    required this.onPointSelected,
    super.key,
  });

  final List<RecyclingPointModel> points;
  final RecyclingPointModel? selectedPoint;
  final ValueChanged<RecyclingPointModel> onPointSelected;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 0.84,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.winterLight,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Stack(
          children: [
            for (final road in const [70.0, 160.0, 250.0])
              Positioned(
                top: road,
                left: 0,
                right: 0,
                child: Container(
                  height: 18,
                  color: AppColors.surfaceContainerLowest.withValues(
                    alpha: 0.66,
                  ),
                ),
              ),
            for (final item in _positionedPoints(points.take(8).toList()))
              Positioned(
                left: item.left,
                top: item.top,
                child: _Marker(
                  color: _typeColor(item.point.type),
                  label: _typeLabel(item.point.type),
                  selected: item.point.id == selectedPoint?.id,
                  isBroken: item.point.isBroken,
                  onTap: () => onPointSelected(item.point),
                ),
              ),
            Positioned(
              left: 18,
              right: 18,
              top: 18,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest.withValues(
                    alpha: 0.92,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Erzurum merkez geri dönüşüm noktaları',
                        style: AppTextStyles.label,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_PositionedPoint> _positionedPoints(List<RecyclingPointModel> points) {
    const positions = [
      (34.0, 74.0),
      (238.0, 148.0),
      (112.0, 272.0),
      (260.0, 220.0),
      (64.0, 186.0),
      (184.0, 96.0),
      (154.0, 336.0),
      (276.0, 308.0),
    ];

    return [
      for (var i = 0; i < points.length; i++)
        _PositionedPoint(
          point: points[i],
          left: positions[i % positions.length].$1,
          top: positions[i % positions.length].$2,
        ),
    ];
  }

  Color _typeColor(String type) {
    return switch (type) {
      RecyclingPointTypes.plastic => AppColors.primary,
      RecyclingPointTypes.glass => AppColors.winterBlue,
      RecyclingPointTypes.paper => AppColors.paper,
      RecyclingPointTypes.battery => AppColors.battery,
      RecyclingPointTypes.oil => AppColors.accent,
      RecyclingPointTypes.cafe => AppColors.gold,
      _ => AppColors.primary,
    };
  }

  String _typeLabel(String type) {
    return switch (type) {
      RecyclingPointTypes.plastic => 'Plastik',
      RecyclingPointTypes.glass => 'Cam',
      RecyclingPointTypes.paper => 'Kağıt',
      RecyclingPointTypes.battery => 'Pil',
      RecyclingPointTypes.oil => 'Yağ',
      RecyclingPointTypes.cafe => 'Kafe',
      _ => 'Nokta',
    };
  }
}

class _Marker extends StatelessWidget {
  const _Marker({
    required this.color,
    required this.label,
    required this.onTap,
    this.selected = false,
    this.isBroken = false,
  });

  final Color color;
  final String label;
  final VoidCallback onTap;
  final bool selected;
  final bool isBroken;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(selected ? 10 : 8),
            decoration: BoxDecoration(
              color: isBroken ? AppColors.error : color,
              shape: BoxShape.circle,
              border: selected
                  ? Border.all(color: AppColors.textOnPrimary, width: 3)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.recycling,
              color: AppColors.textOnPrimary,
              size: 20,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest.withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              isBroken ? '$label • Bozuk' : label,
              style: AppTextStyles.caption,
            ),
          ),
        ],
      ),
    );
  }
}

class _PositionedPoint {
  const _PositionedPoint({
    required this.point,
    required this.left,
    required this.top,
  });

  final RecyclingPointModel point;
  final double left;
  final double top;
}
