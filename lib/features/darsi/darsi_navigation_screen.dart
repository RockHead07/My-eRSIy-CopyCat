import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rs_islam_app/core/constants/app_spacing.dart';
import 'package:rs_islam_app/core/theme/app_colors.dart';
import 'package:rs_islam_app/core/theme/app_radius.dart';

class DarsiNavigationScreen extends StatelessWidget {
  const DarsiNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        // Green behind the rounded card corners so the curve looks correct
        backgroundColor: AppColors.headerGradientEnd,
        body: Column(
          children: [
            _DarsiHeader(onBack: () => Navigator.of(context).pop()),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.pageBackground,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppRadius.xl),
                  ),
                ),
                child: Center(
                  child: Text(
                    'Konten WebView akan dimuat di sini',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: AppSpacing.s(context, 13),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header — replicates the "Layanan Unggulan" AppBar style:
// green gradient + back arrow + title/subtitle + stadium pattern ornament.
// ---------------------------------------------------------------------------

class _DarsiHeader extends StatelessWidget {
  const _DarsiHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.headerGradientStart,
            AppColors.headerGradientEnd,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Ornamental pattern on the right (same as HomeHeader)
          Positioned(
            right: -AppSpacing.pageHorizontal,
            top: 0,
            bottom: 0,
            child: SizedBox(
              width: AppSpacing.s(context, 120),
              child: CustomPaint(
                painter: _StadiumPatternPainter(
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
          ),
          // Header content
          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.only(
                left: AppSpacing.s(context, 4),
                right: AppSpacing.s(context, AppSpacing.pageHorizontal),
                top: AppSpacing.s(context, 4),
                bottom: AppSpacing.s(context, 28),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: AppSpacing.s(context, 24),
                    ),
                    onPressed: onBack,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(
                      minWidth: AppSpacing.s(context, 40),
                      minHeight: AppSpacing.s(context, 40),
                    ),
                  ),
                  SizedBox(width: AppSpacing.s(context, 4)),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Navigasi Indoor',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: AppSpacing.s(context, 18),
                          ),
                        ),
                        SizedBox(height: AppSpacing.s(context, 2)),
                        Text(
                          'Temukan ruangan dengan AR',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.75),
                            fontSize: AppSpacing.s(context, 12),
                          ),
                        ),
                      ],
                    ),
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

// ---------------------------------------------------------------------------
// Stadium pattern painter — identical to the one used in HomeHeader
// (replicated here because the original is a private class).
// ---------------------------------------------------------------------------

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
