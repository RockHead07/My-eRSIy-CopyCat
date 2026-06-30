import 'package:flutter/material.dart';
import 'package:rs_islam_app/core/constants/app_spacing.dart';
import 'package:rs_islam_app/core/theme/app_colors.dart';
import 'package:rs_islam_app/core/theme/app_radius.dart';
import 'package:rs_islam_app/features/home/data/menu_items.dart';
import 'package:rs_islam_app/features/home/data/models/banner_model.dart';
import 'package:rs_islam_app/features/home/presentation/widgets/artikel_kesehatan_section.dart';
import 'package:rs_islam_app/features/home/presentation/widgets/banner_carousel.dart';
import 'package:rs_islam_app/features/home/presentation/widgets/custom_bottom_nav_bar.dart';
import 'package:rs_islam_app/features/home/presentation/widgets/home_header.dart';
import 'package:rs_islam_app/features/home/presentation/widgets/menu_layanan_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var _navItem = BottomNavItem.home;

  @override
  Widget build(BuildContext context) {
    final bannerOverlap = AppSpacing.s(context, 90);

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      bottomNavigationBar: CustomBottomNavBar(
        current: _navItem,
        onChanged: (item) => setState(() => _navItem = item),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const HomeHeader(),
                Positioned(
                  left: AppSpacing.s(context, AppSpacing.pageHorizontal),
                  right: AppSpacing.s(context, AppSpacing.pageHorizontal),
                  top: AppSpacing.s(context, 155),
                  child: const BannerCarousel(banners: homeBanners),
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: bannerOverlap)),
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.pageBackground,
                borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
              ),
              child: Column(
                children: [
                  MenuLayananSection(items: homeMenuItems),
                  SizedBox(height: AppSpacing.s(context, 24)),
                  const ArtikelKesehatanSection(),
                  SizedBox(height: AppSpacing.s(context, 24)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
