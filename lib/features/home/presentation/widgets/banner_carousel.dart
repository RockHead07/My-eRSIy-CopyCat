import 'package:flutter/material.dart';
import 'package:rs_islam_app/core/constants/app_spacing.dart';
import 'package:rs_islam_app/core/theme/app_colors.dart';
import 'package:rs_islam_app/core/theme/app_radius.dart';
import 'package:rs_islam_app/features/home/data/models/banner_model.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class BannerCarousel extends StatefulWidget {
  const BannerCarousel({super.key, required this.banners});

  final List<BannerModel> banners;

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  final _controller = PageController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cardHeight = AppSpacing.s(context, AppSpacing.bannerHeight);

    return Column(
      children: [
        SizedBox(
          height: cardHeight,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.banners.length,
            itemBuilder: (context, index) => _BannerCard(banner: widget.banners[index]),
          ),
        ),
        SizedBox(height: AppSpacing.s(context, 10)),
        SmoothPageIndicator(
          controller: _controller,
          count: widget.banners.length,
          effect: ExpandingDotsEffect(
            dotHeight: AppSpacing.s(context, 6),
            dotWidth: AppSpacing.s(context, 6),
            expansionFactor: 3,
            spacing: AppSpacing.s(context, 4),
            activeDotColor: AppColors.brandGreenDark,
            dotColor: AppColors.dotInactive,
          ),
        ),
      ],
    );
  }
}

class _BannerCard extends StatelessWidget {
  const _BannerCard({required this.banner});

  final BannerModel banner;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: AppSpacing.s(context, 12),
            offset: Offset(0, AppSpacing.s(context, 4)),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            banner.imageAsset,
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.05),
                  Colors.black.withValues(alpha: 0.55),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(AppSpacing.s(context, 14)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  banner.title,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: AppSpacing.s(context, 13),
                  ),
                ),
                const Spacer(),
                _VisitRow(
                  icon: Icons.wb_sunny_outlined,
                  text: banner.morningHours,
                ),
                SizedBox(height: AppSpacing.s(context, 6)),
                _VisitRow(
                  icon: Icons.nightlight_round,
                  text: banner.afternoonHours,
                ),
                SizedBox(height: AppSpacing.s(context, 6)),
                Text(
                  banner.fridayNote,
                  style: TextStyle(
                    color: AppColors.visitNoteOrange,
                    fontSize: AppSpacing.s(context, 9),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VisitRow extends StatelessWidget {
  const _VisitRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: AppSpacing.s(context, 14)),
        SizedBox(width: AppSpacing.s(context, 6)),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: AppSpacing.s(context, 10),
            ),
          ),
        ),
      ],
    );
  }
}
