import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rs_islam_app/features/home/data/models/banner_model.dart';
import 'package:rs_islam_app/features/home/presentation/widgets/banner_carousel.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

void main() {
  final testBanners = [
    const BannerModel(
      imageAsset: 'assets/images/heroCarousel1.jpeg',
      title: 'Banner 1 Title',
      morningHours: 'PAGI 10.00',
      afternoonHours: 'SORE 16.00',
      fridayNote: 'Note 1',
    ),
    const BannerModel(
      imageAsset: 'assets/images/heroCarousel2.jpeg',
      title: 'Banner 2 Title',
      morningHours: 'PAGI 11.00',
      afternoonHours: 'SORE 17.00',
      fridayNote: 'Note 2',
    ),
    const BannerModel(
      imageAsset: 'assets/images/heroCarousel3.jpeg',
      title: 'Banner 3 Title',
      morningHours: 'PAGI 12.00',
      afternoonHours: 'SORE 18.00',
      fridayNote: 'Note 3',
    ),
  ];

  testWidgets('BannerCarousel renders clean image without text overlay', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BannerCarousel(banners: testBanners),
        ),
      ),
    );

    // Should find the image
    expect(find.byType(Image), findsOneWidget);

    // Should NOT find the text overlays from the model
    expect(find.text('Banner 1 Title'), findsNothing);
    expect(find.text('PAGI 10.00'), findsNothing);
    expect(find.text('Note 1'), findsNothing);

    // Should have AnimatedSmoothIndicator
    expect(find.byType(AnimatedSmoothIndicator), findsOneWidget);
    final indicator = tester.widget<AnimatedSmoothIndicator>(find.byType(AnimatedSmoothIndicator));
    expect(indicator.activeIndex, 0);
    expect(indicator.count, 3);
  });

  testWidgets('BannerCarousel auto-scrolls to next page after 5 seconds', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BannerCarousel(banners: testBanners),
        ),
      ),
    );

    final indicatorInitial = tester.widget<AnimatedSmoothIndicator>(find.byType(AnimatedSmoothIndicator));
    expect(indicatorInitial.activeIndex, 0);

    // Advance time by 5 seconds
    await tester.pump(const Duration(seconds: 5));
    // Settle animation (600ms)
    await tester.pumpAndSettle();

    final indicatorAfterScroll = tester.widget<AnimatedSmoothIndicator>(find.byType(AnimatedSmoothIndicator));
    expect(indicatorAfterScroll.activeIndex, 1);
  });

  testWidgets('BannerCarousel starts at initialPage with 1000 multiplier for infinite scroll', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BannerCarousel(banners: testBanners),
        ),
      ),
    );

    final pageView = tester.widget<PageView>(find.byType(PageView));
    final controller = pageView.controller;
    expect(controller?.initialPage, 3000);
  });

  testWidgets('BannerCarousel handles empty list gracefully', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BannerCarousel(banners: []),
        ),
      ),
    );

    expect(find.byType(PageView), findsNothing);
    expect(find.byType(AnimatedSmoothIndicator), findsNothing);
  });

  testWidgets('BannerCarousel cleans up timers and controllers on dispose', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BannerCarousel(banners: testBanners),
        ),
      ),
    );

    // Replace with empty container to trigger dispose
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox.shrink(),
        ),
      ),
    );

    // Advance time to verify no timer fires after dispose
    await tester.pump(const Duration(seconds: 6));
    expect(find.byType(BannerCarousel), findsNothing);
  });
}
