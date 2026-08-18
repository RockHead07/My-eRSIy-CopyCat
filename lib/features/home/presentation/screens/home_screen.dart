import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rs_islam_app/core/constants/app_spacing.dart';
import 'package:rs_islam_app/core/theme/app_colors.dart';
import 'package:rs_islam_app/core/theme/app_radius.dart';
import 'package:rs_islam_app/features/home/data/menu_items.dart';
import 'package:rs_islam_app/features/home/data/models/banner_model.dart';
import 'package:rs_islam_app/features/home/presentation/bloc/navigation_cubit.dart';
import 'package:rs_islam_app/features/home/presentation/widgets/artikel_kesehatan_section.dart';
import 'package:rs_islam_app/features/home/presentation/widgets/banner_carousel.dart';
import 'package:rs_islam_app/features/home/presentation/widgets/custom_bottom_nav_bar.dart';
import 'package:rs_islam_app/features/home/presentation/widgets/home_header.dart';
import 'package:rs_islam_app/features/home/presentation/widgets/menu_layanan_section.dart';
import 'package:rs_islam_app/features/profile/presentation/screens/profile_screen.dart';

/// Layar utama aplikasi.
///
/// Menggunakan [NavigationCubit] (disediakan oleh [BlocProvider] di
/// [main.dart]) untuk melacak tab aktif pada [CustomBottomNavBar].
/// Menggunakan [IndexedStack] untuk mempertahankan state setiap tab
/// saat berpindah antar tab.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationCubit, BottomNavItem>(
      builder: (context, navItem) {
        return Scaffold(
          backgroundColor: AppColors.pageBackground,
          bottomNavigationBar: CustomBottomNavBar(
            current: navItem,
            onChanged: (item) =>
                context.read<NavigationCubit>().selectTab(item),
          ),
          body: IndexedStack(
            index: navItem.index,
            children: const [
              _HomeFeedView(),
              _PlaceholderTabView(
                title: 'Janji Temu',
                icon: Icons.calendar_today_outlined,
              ),
              _PlaceholderTabView(
                title: 'Riwayat Medis',
                icon: Icons.history,
              ),
              ProfileScreen(),
            ],
          ),
        );
      },
    );
  }
}

class _HomeFeedView extends StatelessWidget {
  const _HomeFeedView();

  @override
  Widget build(BuildContext context) {
    final bannerOverlap = AppSpacing.s(context, 90);

    return CustomScrollView(
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
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppRadius.xl),
              ),
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
    );
  }
}

class _PlaceholderTabView extends StatelessWidget {
  const _PlaceholderTabView({
    required this.title,
    required this.icon,
  });

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: AppSpacing.s(context, 48),
            color: AppColors.textSecondary,
          ),
          SizedBox(height: AppSpacing.s(context, 12)),
          Text(
            title,
            style: TextStyle(
              fontSize: AppSpacing.s(context, 16),
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSpacing.s(context, 4)),
          Text(
            'Fitur ini sedang dalam pengembangan',
            style: TextStyle(
              fontSize: AppSpacing.s(context, 12),
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
