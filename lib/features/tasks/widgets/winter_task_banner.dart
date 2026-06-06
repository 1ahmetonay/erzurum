import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class WinterTaskBanner extends StatelessWidget {
  const WinterTaskBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: SizedBox(
          height: 202,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/kar.png',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.winterBlue.withValues(alpha: 0.88),
                      AppColors.winterBlue.withValues(alpha: 0.62),
                      AppColors.primary.withValues(alpha: 0.38),
                    ],
                  ),
                ),
              ),
              const CustomPaint(painter: _SnowDotPainter()),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 270),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '❄️ Kış Görevi Modu Aktif!',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.title.copyWith(
                            color: AppColors.onTertiary,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Erzurum kışında çevremizi koruyalım, ekstra puanlar kazanalım.',
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.onTertiary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 18,
                bottom: 16,
                child: Icon(
                  Icons.ac_unit,
                  color: AppColors.surfaceContainerLowest.withValues(
                    alpha: 0.62,
                  ),
                  size: 34,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SnowDotPainter extends CustomPainter {
  const _SnowDotPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.surfaceContainerLowest.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;

    for (var row = 0; row < 7; row++) {
      for (var col = 0; col < 10; col++) {
        final dx = 18.0 + col * 30 + (row.isEven ? 0 : 14);
        final dy = 18.0 + row * 28;
        if (dx < size.width && dy < size.height) {
          canvas.drawCircle(Offset(dx, dy), 1, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
