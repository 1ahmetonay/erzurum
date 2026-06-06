import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/recycling_point_model.dart';

class MockMapView extends StatefulWidget {
  const MockMapView({
    required this.points,
    required this.selectedPoint,
    required this.onPointSelected,
    this.isLoading = false,
    this.hasError = false,
    super.key,
  });

  final List<RecyclingPointModel> points;
  final RecyclingPointModel? selectedPoint;
  final ValueChanged<RecyclingPointModel> onPointSelected;
  final bool isLoading;
  final bool hasError;

  static const _erzurumCenter = LatLng(39.9056, 41.2658);

  @override
  State<MockMapView> createState() => _MockMapViewState();
}

class _MockMapViewState extends State<MockMapView> {
  final _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.surfaceContainer,
      child: Stack(
        fit: StackFit.expand,
        children: [
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: MockMapView._erzurumCenter,
              initialZoom: 13.2,
              minZoom: 10,
              maxZoom: 18,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.atikavi.erzurum',
                tileProvider: NetworkTileProvider(),
              ),
              MarkerLayer(
                markers: [
                  for (final point in widget.points)
                    Marker(
                      point: LatLng(point.latitude, point.longitude),
                      width: point.id == widget.selectedPoint?.id ? 128 : 64,
                      height: point.id == widget.selectedPoint?.id ? 94 : 64,
                      alignment: Alignment.topCenter,
                      child: _MapMarker(
                        point: point,
                        selected: point.id == widget.selectedPoint?.id,
                        onTap: () => widget.onPointSelected(point),
                      ),
                    ),
                ],
              ),
            ],
          ),
          IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
              ),
            ),
          ),
          Positioned(
            left: 20,
            top: 82,
            child: _MapFocusPill(hasError: widget.hasError),
          ),
          Positioned(
            right: 18,
            top: 82,
            child: _MapControls(
              onZoomIn: () => _moveToZoom(_mapController.camera.zoom + 1),
              onZoomOut: () => _moveToZoom(_mapController.camera.zoom - 1),
              onCenter: () {
                _mapController.move(MockMapView._erzurumCenter, 13.2);
              },
            ),
          ),
          if (widget.isLoading)
            const Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 18,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _moveToZoom(double zoom) {
    _mapController.move(
      _mapController.camera.center,
      zoom.clamp(10, 18).toDouble(),
    );
  }
}

class _MapMarker extends StatelessWidget {
  const _MapMarker({
    required this.point,
    required this.selected,
    required this.onTap,
  });

  final RecyclingPointModel point;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = point.isBroken ? AppColors.error : _typeColor(point.type);
    final icon = _typeIcon(point.type);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: AnimatedScale(
          scale: selected ? 1.08 : 1,
          duration: const Duration(milliseconds: 180),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest.withValues(
                    alpha: 0.94,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected
                        ? AppColors.primaryFixed
                        : AppColors.surfaceContainerLowest,
                    width: selected ? 4 : 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.34),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: AppColors.textOnPrimary,
                      size: selected ? 24 : 22,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              if (selected)
                Container(
                  constraints: const BoxConstraints(maxWidth: 120),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest.withValues(
                      alpha: 0.94,
                    ),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.outlineVariant),
                  ),
                  child: Text(
                    point.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapFocusPill extends StatelessWidget {
  const _MapFocusPill({required this.hasError});

  final bool hasError;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasError ? Icons.cloud_off_outlined : Icons.location_on_outlined,
            color: AppColors.primary,
            size: 18,
          ),
          const SizedBox(width: 6),
          Text(
            hasError ? 'Demo noktalar gösteriliyor' : 'OSM · Erzurum merkez',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _MapControls extends StatelessWidget {
  const _MapControls({
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onCenter,
  });

  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onCenter;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _MapControlButton(
            tooltip: 'Yakınlaştır',
            icon: Icons.add,
            onPressed: onZoomIn,
          ),
          const _MapControlDivider(),
          _MapControlButton(
            tooltip: 'Uzaklaştır',
            icon: Icons.remove,
            onPressed: onZoomOut,
          ),
          const _MapControlDivider(),
          _MapControlButton(
            tooltip: 'Erzurum merkeze dön',
            icon: Icons.my_location_outlined,
            onPressed: onCenter,
          ),
        ],
      ),
    );
  }
}

class _MapControlButton extends StatelessWidget {
  const _MapControlButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon, color: AppColors.primary),
    );
  }
}

class _MapControlDivider extends StatelessWidget {
  const _MapControlDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 32, height: 1, color: AppColors.outlineVariant);
  }
}

Color _typeColor(String type) {
  return switch (type) {
    RecyclingPointTypes.plastic => AppColors.plastic,
    RecyclingPointTypes.glass => AppColors.glass,
    RecyclingPointTypes.paper => AppColors.paper,
    RecyclingPointTypes.battery => AppColors.battery,
    RecyclingPointTypes.oil => AppColors.oil,
    RecyclingPointTypes.electronic => AppColors.electronic,
    RecyclingPointTypes.cafe => AppColors.tertiary,
    _ => AppColors.primary,
  };
}

IconData _typeIcon(String type) {
  return switch (type) {
    RecyclingPointTypes.plastic => Icons.recycling,
    RecyclingPointTypes.glass => Icons.wine_bar_outlined,
    RecyclingPointTypes.paper => Icons.description_outlined,
    RecyclingPointTypes.battery => Icons.battery_charging_full_outlined,
    RecyclingPointTypes.oil => Icons.water_drop_outlined,
    RecyclingPointTypes.electronic => Icons.devices_other_outlined,
    RecyclingPointTypes.cafe => Icons.local_cafe_outlined,
    _ => Icons.location_on_outlined,
  };
}
