import 'dart:async';
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
  static const int _initialPageMultiplier = 1000;
  late final PageController _controller;
  late int _currentPage;
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.banners.isEmpty
        ? 0
        : widget.banners.length * _initialPageMultiplier;
    _controller = PageController(initialPage: _currentPage);
    _startAutoScroll();
  }

  void _startAutoScroll() {
    if (widget.banners.length <= 1) return;
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted && _controller.hasClients) {
        _controller.nextPage(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) {
      return const SizedBox.shrink();
    }

    final cardHeight = AppSpacing.s(context, AppSpacing.bannerHeight);

    return Column(
      children: [
        SizedBox(
          height: cardHeight,
          child: PageView.builder(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              final bannerIndex = index % widget.banners.length;
              return _BannerCard(banner: widget.banners[bannerIndex]);
            },
          ),
        ),
        SizedBox(height: AppSpacing.s(context, 10)),
        AnimatedSmoothIndicator(
          activeIndex: _currentPage % widget.banners.length,
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
      child: Image.asset(
        banner.imageAsset,
        fit: BoxFit.cover,
        alignment: Alignment.topCenter,
      ),
    );
  }
}
