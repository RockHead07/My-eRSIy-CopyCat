import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rs_islam_app/core/constants/app_spacing.dart';
import 'package:rs_islam_app/core/theme/app_colors.dart';
import 'package:rs_islam_app/core/theme/app_radius.dart';
import 'package:rs_islam_app/core/widgets/section_header.dart';
import 'package:rs_islam_app/features/home/presentation/bloc/artikel_cubit.dart';

/// Section Artikel Kesehatan di halaman Home.
///
/// Menggunakan [ArtikelCubit] (disediakan secara lokal via [BlocProvider])
/// untuk mengelola tab kategori aktif. [setState] sudah dihapus sepenuhnya.
class ArtikelKesehatanSection extends StatelessWidget {
  const ArtikelKesehatanSection({super.key});

  static const _categories = ['Semua', 'Kesehatan', 'Kesehatan Umum'];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ArtikelCubit(),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.s(context, AppSpacing.pageHorizontal),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: 'Artikel Kesehatan',
              subtitle: 'Tips & informasi terkini',
              icon: Icons.article_outlined,
              trailing: _LihatSemuaButton(onTap: () {}),
            ),
            SizedBox(height: AppSpacing.s(context, 14)),
            // --- Chip kategori ---
            BlocBuilder<ArtikelCubit, ArtikelState>(
              builder: (context, state) {
                return SizedBox(
                  height: AppSpacing.s(context, 34),
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    separatorBuilder: (context, index) =>
                        SizedBox(width: AppSpacing.s(context, 8)),
                    itemBuilder: (context, index) {
                      final active = index == state.selectedCategory;
                      return ChoiceChip(
                        label: Text(_categories[index]),
                        selected: active,
                        onSelected: (_) =>
                            context.read<ArtikelCubit>().selectCategory(index),
                        labelStyle: TextStyle(
                          fontSize: AppSpacing.s(context, 11),
                          color: active ? Colors.white : AppColors.brandGreenDark,
                          fontWeight: FontWeight.w600,
                        ),
                        selectedColor: AppColors.brandGreenDark,
                        backgroundColor: AppColors.surfaceWhite,
                        side: BorderSide(
                          color: active
                              ? AppColors.brandGreenDark
                              : AppColors.pillMintText,
                        ),
                        showCheckmark: false,
                        padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.s(context, 8)),
                      );
                    },
                  ),
                );
              },
            ),
            SizedBox(height: AppSpacing.s(context, 14)),
            _FeaturedArticleCard(onTap: () {}),
            SizedBox(height: AppSpacing.s(context, 12)),
            SizedBox(
              height: AppSpacing.s(context, 170),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _placeholderArticles.length,
                separatorBuilder: (context, index) =>
                    SizedBox(width: AppSpacing.s(context, 10)),
                itemBuilder: (context, index) {
                  final article = _placeholderArticles[index];
                  return _ArticleCard(
                    title: article.title,
                    category: article.category,
                    imageAsset: article.imageAsset,
                    onTap: () {},
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LihatSemuaButton extends StatelessWidget {
  const _LihatSemuaButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final height = AppSpacing.s(context, 30);
    return Material(
      color: AppColors.pillMintBg,
      borderRadius: BorderRadius.circular(height / 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(height / 2),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.s(context, 12),
            vertical: AppSpacing.s(context, 6),
          ),
          child: Text(
            'Lihat Semua',
            style: TextStyle(
              color: AppColors.pillMintText,
              fontWeight: FontWeight.w600,
              fontSize: AppSpacing.s(context, 10),
            ),
          ),
        ),
      ),
    );
  }
}

class _FeaturedArticleCard extends StatelessWidget {
  const _FeaturedArticleCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        height: AppSpacing.s(context, 180),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          image: const DecorationImage(
            image: AssetImage('assets/images/banner_hospital.png'),
            fit: BoxFit.cover,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.05),
                    Colors.black.withValues(alpha: 0.65),
                  ],
                ),
              ),
              child: const SizedBox.expand(),
            ),
            Padding(
              padding: EdgeInsets.all(AppSpacing.s(context, 14)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _Badge(
                        label: 'TERBARU',
                        background: AppColors.articleBadgeLime,
                        foreground: AppColors.brandGreenDark,
                      ),
                      SizedBox(width: AppSpacing.s(context, 6)),
                      _Badge(
                        label: 'KESEHATAN UMUM',
                        background: AppColors.brandGreenDark,
                        foreground: Colors.white,
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    'Yuk Intip Rahasia Membangun Otot dengan Sumber Protein Sehat!',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: AppSpacing.s(context, 14),
                      height: 1.25,
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

class _ArticleCard extends StatelessWidget {
  const _ArticleCard({
    required this.title,
    required this.category,
    required this.imageAsset,
    required this.onTap,
  });

  final String title;
  final String category;
  final String imageAsset;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final width = AppSpacing.s(context, 150);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: Image.asset(
                imageAsset,
                width: width,
                height: AppSpacing.s(context, 90),
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: AppSpacing.s(context, 8)),
            Text(
              category,
              style: TextStyle(
                color: AppColors.pillMintText,
                fontSize: AppSpacing.s(context, 9),
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: AppSpacing.s(context, 11),
                height: 1.25,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.s(context, 8),
        vertical: AppSpacing.s(context, 4),
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontSize: AppSpacing.s(context, 8),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ArticlePlaceholder {
  const _ArticlePlaceholder({
    required this.title,
    required this.category,
    required this.imageAsset,
  });

  final String title;
  final String category;
  final String imageAsset;
}

const _placeholderArticles = <_ArticlePlaceholder>[
  _ArticlePlaceholder(
    title: 'Tanda Bahaya Kehamilan yang Perlu Diwaspadai',
    category: 'KESEHATAN',
    imageAsset: 'assets/images/banner_hospital.png',
  ),
  _ArticlePlaceholder(
    title: 'Peran Orang Tua Menghadapi Anak Picky Eater',
    category: 'KESEHATAN UMUM',
    imageAsset: 'assets/images/banner_hospital.png',
  ),
];
