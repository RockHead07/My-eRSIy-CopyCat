# Infinite Hero Carousel Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace existing hero carousel banners with three newly added hospital banner assets, enabling smooth infinite auto-scrolling every 5 seconds with synchronized indicators.

**Architecture:** Update `homeBanners` in `banner_model.dart` to point to the new image assets, then upgrade `BannerCarousel` to use virtual infinite modulo indexing with `PageView.builder`, auto-slide with a 5-second `Timer.periodic`, and synchronized `AnimatedSmoothIndicator`.

**Tech Stack:** Flutter, Dart, `smooth_page_indicator`, Flutter Widget Testing.

## Global Constraints
- Target minSdk: 29 (Android)
- Flutter SDK: ^3.12.2
- Maintain AppColors, AppRadius, and AppSpacing baseline system (402px)

---

### Task 1: Update Banner Model Data

**Files:**
- Modify: `lib/features/home/data/models/banner_model.dart`
- Test: `test/banner_model_test.dart`

**Interfaces:**
- Produces: `const List<BannerModel> homeBanners`

- [ ] **Step 1: Write test for banner_model**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:rs_islam_app/features/home/data/models/banner_model.dart';

void main() {
  test('homeBanners contains 3 new heroCarousel assets', () {
    expect(homeBanners.length, 3);
    expect(homeBanners[0].imageAsset, 'assets/images/heroCarousel1.jpeg');
    expect(homeBanners[1].imageAsset, 'assets/images/heroCarousel2.jpeg');
    expect(homeBanners[2].imageAsset, 'assets/images/heroCarousel3.jpeg');
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/banner_model_test.dart`

- [ ] **Step 3: Update `banner_model.dart`**

```dart
class BannerModel {
  const BannerModel({
    required this.imageAsset,
    required this.title,
    required this.morningHours,
    required this.afternoonHours,
    required this.fridayNote,
  });

  final String imageAsset;
  final String title;
  final String morningHours;
  final String afternoonHours;
  final String fridayNote;
}

const homeBanners = <BannerModel>[
  BannerModel(
    imageAsset: 'assets/images/heroCarousel1.jpeg',
    title: 'Kunjungi kami sesuai jam yang ditetapkan',
    morningHours: 'PAGI 10.00 - 12.00 WIB',
    afternoonHours: 'SORE 16.00 - 18.00 WIB',
    fridayNote: "Kecuali Jum'at pagi 09.00 - 11.00 WIB",
  ),
  BannerModel(
    imageAsset: 'assets/images/heroCarousel2.jpeg',
    title: 'Melayani BPJS dan Non-BPJS',
    morningHours: 'INFORMASI LEBIH LANJUT',
    afternoonHours: 'CHAT WA: 0814-0090-6200',
    fridayNote: 'Layanan Sepenuh Hati',
  ),
  BannerModel(
    imageAsset: 'assets/images/heroCarousel3.jpeg',
    title: 'Nomor RSI Baru, Akses Informasi Lebih Mudah',
    morningHours: 'LAYANAN INFORMASI',
    afternoonHours: 'CHAT WA: 0821-3322-2247',
    fridayNote: 'Hubungi via WhatsApp',
  ),
];
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/banner_model_test.dart`

- [ ] **Step 5: Commit changes**

```bash
git add lib/features/home/data/models/banner_model.dart test/banner_model_test.dart
git commit -m "feat: update homeBanners with new heroCarousel assets"
```

---

### Task 2: Implement Infinite Auto-Scroll Carousel Widget

**Files:**
- Modify: `lib/features/home/presentation/widgets/banner_carousel.dart`
- Test: `test/banner_carousel_test.dart`

**Interfaces:**
- Consumes: `BannerModel` from `lib/features/home/data/models/banner_model.dart`
- Produces: `class BannerCarousel extends StatefulWidget`

- [ ] **Step 1: Write test for BannerCarousel infinite scrolling & timer**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rs_islam_app/features/home/data/models/banner_model.dart';
import 'package:rs_islam_app/features/home/presentation/widgets/banner_carousel.dart';

void main() {
  testWidgets('BannerCarousel renders and advances every 5 seconds', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BannerCarousel(banners: homeBanners),
        ),
      ),
    );

    expect(find.byType(BannerCarousel), findsOneWidget);
    expect(find.text('Kunjungi kami sesuai jam yang ditetapkan'), findsWidgets);

    // Advance 5 seconds to test auto-scroll
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    expect(find.text('Melayani BPJS dan Non-BPJS'), findsWidgets);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/banner_carousel_test.dart`

- [ ] **Step 3: Update `banner_carousel.dart` with infinite loop & auto-slide**

```dart
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
    final initialPage = widget.banners.isEmpty
        ? 0
        : widget.banners.length * _initialPageMultiplier;
    _currentPage = initialPage;
    _controller = PageController(initialPage: initialPage);

    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    if (widget.banners.length <= 1) return;

    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_controller.hasClients) return;
      _controller.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
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
    if (widget.banners.isEmpty) return const SizedBox.shrink();

    final cardHeight = AppSpacing.s(context, AppSpacing.bannerHeight);
    final activeIndex = _currentPage % widget.banners.length;

    return Column(
      children: [
        SizedBox(
          height: cardHeight,
          child: PageView.builder(
            controller: _controller,
            onPageChanged: (page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemBuilder: (context, index) {
              final banner = widget.banners[index % widget.banners.length];
              return _BannerCard(banner: banner);
            },
          ),
        ),
        SizedBox(height: AppSpacing.s(context, 10)),
        AnimatedSmoothIndicator(
          activeIndex: activeIndex,
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
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/banner_carousel_test.dart`

- [ ] **Step 5: Commit changes**

```bash
git add lib/features/home/presentation/widgets/banner_carousel.dart test/banner_carousel_test.dart
git commit -m "feat: implement infinite auto-scrolling hero carousel every 5s"
```
