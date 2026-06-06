import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/recycling_point_model.dart';

class NearbyPointCard extends StatelessWidget {
  const NearbyPointCard({required this.point, this.onTap, super.key});

  final RecyclingPointModel point;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.6),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'En Yakın Nokta',
                          style: AppTextStyles.subtitle.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          point.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.directions_walk,
                    color: AppColors.primary,
                    size: 26,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 134,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const _MapPreview(),
                  Center(
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.location_on,
                          color: AppColors.primary,
                          size: 38,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 10,
                    bottom: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.shadow,
                            blurRadius: 14,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Text(
                        '350m mesafe',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
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

class _MapPreview extends StatelessWidget {
  const _MapPreview();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: AppColors.surfaceDim),
      child: CustomPaint(painter: _MapPreviewPainter()),
    );
  }
}

class _MapPreviewPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final landPaint = Paint()..color = AppColors.surfaceContainerHigh;
    final parkPaint = Paint()..color = AppColors.surfaceDim;
    final roadPaint = Paint()
      ..color = AppColors.background
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final sideRoadPaint = Paint()
      ..color = AppColors.surfaceContainerLow
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawRect(Offset.zero & size, landPaint);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width * 0.28, size.height),
      parkPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.68, 0, size.width * 0.32, size.height),
      Paint()..color = AppColors.surfaceDim,
    );

    final mainRoad = Path()
      ..moveTo(-10, size.height * 0.18)
      ..quadraticBezierTo(
        size.width * 0.18,
        size.height * 0.52,
        size.width * 0.34,
        size.height + 12,
      );
    canvas.drawPath(mainRoad, roadPaint);

    final road2 = Path()
      ..moveTo(size.width * 0.26, -8)
      ..lineTo(size.width * 0.34, size.height + 8);
    canvas.drawPath(road2, sideRoadPaint);

    for (final x in [0.42, 0.5, 0.58, 0.66]) {
      canvas.drawLine(
        Offset(size.width * x, -8),
        Offset(size.width * (x - 0.18), size.height + 8),
        sideRoadPaint,
      );
    }
    for (final y in [0.18, 0.34, 0.5, 0.66, 0.82]) {
      canvas.drawLine(
        Offset(size.width * 0.34, size.height * y),
        Offset(size.width * 0.7, size.height * (y - 0.16)),
        sideRoadPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
