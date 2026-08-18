# Design Spec: Infinite Hero Carousel (Home Screen)

## Overview
Implement an infinite auto-scrolling hero carousel on the Home screen of `rs_islam_app` utilizing three new hospital banners (`heroCarousel1.jpeg`, `heroCarousel2.jpeg`, and `heroCarousel3.jpeg`), with a 5-second automatic sliding timer, manual drag support, and synchronized dot indicators.

## Requirements
1. **Asset & Data Model Updates**:
   - Update `homeBanners` in `lib/features/home/data/models/banner_model.dart` with the 3 new images from `assets/images/`:
     - `heroCarousel1.jpeg`: Visiting hours information.
     - `heroCarousel2.jpeg`: BPJS & Non-BPJS consultation and WhatsApp contact (`0814-0090-6200`).
     - `heroCarousel3.jpeg`: New RSI contact information and WhatsApp contact (`0821-3322-2247`).
   - Retain text overlay with readable typography and subtle dark gradient.

2. **Infinite Looping Carousel (`BannerCarousel`)**:
   - Widget: `BannerCarousel` (`lib/features/home/presentation/widgets/banner_carousel.dart`).
   - `PageView.builder` without a bounded `itemCount` (or large virtual count) using modulo indexing: `banner = widget.banners[index % widget.banners.length]`.
   - Initial Page set to a middle offset (e.g. `widget.banners.length * 1000`) so the user can swipe left or right indefinitely from the start.
   - Auto-scroll timer: `Timer.periodic` triggering every 5 seconds, advancing via `_pageController.nextPage(duration: Duration(milliseconds: 600), curve: Curves.easeInOutCubic)`.
   - Indicator: `AnimatedSmoothIndicator` tracking `_currentPageIndex % widget.banners.length` with `ExpandingDotsEffect`.
   - Resource Cleanup: Safely cancel the `Timer` and dispose `PageController` in `dispose()`.

## Non-Functional Requirements
- Smooth 60fps transitions without frame drops or jitter.
- No memory leaks on screen leave or app backgrounding.
