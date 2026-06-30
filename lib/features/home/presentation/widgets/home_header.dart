import 'package:flutter/material.dart';
import 'package:rs_islam_app/core/constants/app_spacing.dart';
import 'package:rs_islam_app/core/theme/app_colors.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final headerHeight = AppSpacing.s(context, AppSpacing.headerHeight);

    return SizedBox(
      height: headerHeight,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.headerGradientStart,
                  AppColors.headerGradientEnd,
                ],
              ),
            ),
          ),
          Positioned(
            right: -AppSpacing.pageHorizontal,
            top: AppSpacing.s(context, 20),
            child: _HeaderPattern(height: headerHeight),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.s(context, AppSpacing.pageHorizontal),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: AppSpacing.s(context, 8)),
                  Row(
                    children: [
                      Icon(
                        Icons.local_hospital,
                        color: Colors.white,
                        size: AppSpacing.s(context, 28),
                      ),
                      SizedBox(width: AppSpacing.s(context, 8)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'RS ISLAM',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: AppSpacing.s(context, 13),
                              ),
                            ),
                            Text(
                              'SURABAYA - A. YANI',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: AppSpacing.s(context, 10),
                              ),
                            ),
                          ],
                        ),
                      ),
                      _IgdButton(onTap: () {}),
                      SizedBox(width: AppSpacing.s(context, 8)),
                      _NotificationButton(onTap: () {}),
                    ],
                  ),
                  SizedBox(height: AppSpacing.s(context, 18)),
                  Text(
                    'Assalamualaikum, Selamat siang...',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.92),
                      fontSize: AppSpacing.s(context, 12),
                    ),
                  ),
                  SizedBox(height: AppSpacing.s(context, 4)),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Tamu',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: AppSpacing.s(context, 28),
                          ),
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.accentYellow,
                        size: AppSpacing.s(context, 28),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IgdButton extends StatelessWidget {
  const _IgdButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final height = AppSpacing.s(context, 34);
    return Material(
      color: AppColors.accentRed,
      borderRadius: BorderRadius.circular(height / 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(height / 2),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.s(context, 10),
            vertical: AppSpacing.s(context, 6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.phone, color: Colors.white, size: AppSpacing.s(context, 14)),
              SizedBox(width: AppSpacing.s(context, 4)),
              Text(
                'IGD 24 Jam',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: AppSpacing.s(context, 10),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final size = AppSpacing.s(context, 36);
    return Material(
      color: AppColors.notifCircleBg,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(
            Icons.notifications_none_rounded,
            color: Colors.white,
            size: AppSpacing.s(context, 20),
          ),
        ),
      ),
    );
  }
}

class _HeaderPattern extends StatelessWidget {
  const _HeaderPattern({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppSpacing.s(context, 120),
      height: height,
      child: CustomPaint(
        painter: _StadiumPatternPainter(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
    );
  }
}

class _StadiumPatternPainter extends CustomPainter {
  const _StadiumPatternPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    const count = 5;
    final barWidth = size.width / (count * 2);
    for (var i = 0; i < count; i++) {
      final left = i * barWidth * 2.2;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, size.height * 0.08, barWidth, size.height * 0.84),
        Radius.circular(barWidth),
      );
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
