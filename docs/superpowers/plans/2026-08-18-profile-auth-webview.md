# Profile Auth WebView Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement a dedicated hybrid `ProfileScreen` with an RS Islam styled native header and embedded `WebViewWidget` with `ProfileBridge`, and integrate it into `HomeScreen` using `IndexedStack` for seamless tab switching.

**Architecture:** Create `ProfileScreen` inside `lib/features/profile/presentation/screens/` powered by `WebViewCubit` and `ProfileBridge` JavaScript channel, then wire `HomeScreen` to display the four tabs (`home`, `janjiTemu`, `riwayat`, `profil`) using `IndexedStack`.

**Tech Stack:** Flutter, Dart, `webview_flutter`, `flutter_bloc`, `smooth_page_indicator`.

## Global Constraints
- Target minSdk: 29 (Android)
- Flutter SDK: ^3.12.2
- Maintain AppColors, AppRadius, and AppSpacing baseline system (402px)

---

### Task 1: Create Profile WebView Screen

**Files:**
- Create: `lib/features/profile/presentation/screens/profile_screen.dart`
- Test: `test/profile_screen_test.dart`

**Interfaces:**
- Produces: `class ProfileScreen extends StatelessWidget`
- Consumes: `WebViewCubit`, `AppColors`, `AppSpacing`, `AppRadius`

- [ ] **Step 1: Write widget test for `ProfileScreen`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rs_islam_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  testWidgets('ProfileScreen renders header and webview container', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProfileScreen(),
        ),
      ),
    );

    expect(find.text('Profil Akun'), findsOneWidget);
    expect(find.text('Masuk atau kelola akun Anda'), findsOneWidget);
    expect(find.byType(WebViewWidget), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/profile_screen_test.dart`

- [ ] **Step 3: Implement `ProfileScreen`**

```dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rs_islam_app/core/constants/app_spacing.dart';
import 'package:rs_islam_app/core/theme/app_colors.dart';
import 'package:rs_islam_app/core/theme/app_radius.dart';
import 'package:rs_islam_app/features/home/presentation/bloc/webview_cubit.dart';
import 'package:webview_flutter/webview_flutter.dart';

const String _profileAuthUrl = String.fromEnvironment(
  'PROFILE_AUTH_URL',
  defaultValue: 'https://darsi-indoor-navigation.vercel.app/profile',
);

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WebViewCubit(),
      child: const _ProfileBody(),
    );
  }
}

class _ProfileBody extends StatefulWidget {
  const _ProfileBody();

  @override
  State<_ProfileBody> createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<_ProfileBody> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.pageBackground)
      ..addJavaScriptChannel(
        'ProfileBridge',
        onMessageReceived: _onWebMessage,
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) context.read<WebViewCubit>().onPageStarted();
          },
          onPageFinished: (_) {
            if (mounted) context.read<WebViewCubit>().onPageFinished();
          },
          onWebResourceError: (_) {
            if (mounted) context.read<WebViewCubit>().onPageError();
          },
        ),
      )
      ..loadRequest(Uri.parse(_profileAuthUrl));
  }

  void _onWebMessage(JavaScriptMessage message) {
    debugPrint('ProfileBridge message: ${message.message}');
    try {
      final data = jsonDecode(message.message) as Map<String, dynamic>;
      final event = data['event'] ?? data['action'];
      debugPrint('Profile auth event received: $event');
    } catch (e) {
      debugPrint('ProfileBridge decode error: $e');
    }
  }

  Future<void> _handleBack() async {
    if (await _controller.canGoBack()) {
      await _controller.goBack();
    }
  }

  void _reload() {
    context.read<WebViewCubit>().resetError();
    _controller.loadRequest(Uri.parse(_profileAuthUrl));
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) async {
          if (didPop) return;
          await _handleBack();
        },
        child: Scaffold(
          backgroundColor: AppColors.headerGradientEnd,
          body: Column(
            children: [
              const _ProfileHeader(),
              Expanded(
                child: Container(
                  width: double.infinity,
                  clipBehavior: Clip.antiAlias,
                  decoration: const BoxDecoration(
                    color: AppColors.pageBackground,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(AppRadius.xl),
                    ),
                  ),
                  child: BlocBuilder<WebViewCubit, WebViewState>(
                    builder: (context, state) {
                      return Stack(
                        children: [
                          if (!state.hasError)
                            WebViewWidget(controller: _controller),
                          if (state.isLoading && !state.hasError)
                            const Center(child: CircularProgressIndicator()),
                          if (state.hasError) _ErrorView(onRetry: _reload),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

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
          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.only(
                left: AppSpacing.s(context, AppSpacing.pageHorizontal),
                right: AppSpacing.s(context, AppSpacing.pageHorizontal),
                top: AppSpacing.s(context, 14),
                bottom: AppSpacing.s(context, 20),
              ),
              child: Row(
                children: [
                  Container(
                    width: AppSpacing.s(context, 44),
                    height: AppSpacing.s(context, 44),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person_outline_rounded,
                      color: Colors.white,
                      size: AppSpacing.s(context, 26),
                    ),
                  ),
                  SizedBox(width: AppSpacing.s(context, 12)),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Profil Akun',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: AppSpacing.s(context, 18),
                          ),
                        ),
                        SizedBox(height: AppSpacing.s(context, 2)),
                        Text(
                          'Masuk atau kelola akun Anda',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
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

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off, size: 48, color: AppColors.textSecondary),
            const SizedBox(height: 12),
            const Text(
              'Gagal memuat halaman profil. Periksa koneksi internet Anda.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Coba Lagi')),
          ],
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
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/profile_screen_test.dart`

- [ ] **Step 5: Commit changes**

```bash
git add lib/features/profile/presentation/screens/profile_screen.dart test/profile_screen_test.dart
git commit -m "feat: add ProfileScreen with native header and embedded webview"
```

---

### Task 2: Integrate `ProfileScreen` into `HomeScreen` Tabs via `IndexedStack`

**Files:**
- Modify: `lib/features/home/presentation/screens/home_screen.dart`
- Test: `test/widget_test.dart`

**Interfaces:**
- Consumes: `ProfileScreen`, `NavigationCubit`, `BottomNavItem`
- Produces: `HomeScreen` multi-tab `IndexedStack` container

- [ ] **Step 1: Write test for multi-tab switching in `test/widget_test.dart`**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:rs_islam_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:rs_islam_app/main.dart';

void main() {
  testWidgets('HomeScreen switches between Home and Profile tabs', (tester) async {
    await tester.pumpWidget(const RsIslamApp());

    expect(find.text('Tamu'), findsOneWidget);

    // Tap Profil tab
    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();

    // Should find ProfileScreen
    expect(find.byType(ProfileScreen), findsOneWidget);
    expect(find.text('Profil Akun'), findsOneWidget);

    // Tap Home tab back
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();

    expect(find.text('Tamu'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/widget_test.dart`

- [ ] **Step 3: Update `HomeScreen` with `IndexedStack` and placeholder views**

```dart
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
                  top: Radius.circular(AppRadius.xl)),
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
  const _PlaceholderTabView({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 64, color: AppColors.brandGreenDark),
              const SizedBox(height: 16),
              Text(
                'Layanan $title Segera Hadir',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Fitur ini sedang dalam tahap pengembangan.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run all tests to verify they pass**

Run: `flutter test`

- [ ] **Step 5: Commit changes**

```bash
git add lib/features/home/presentation/screens/home_screen.dart test/widget_test.dart
git commit -m "feat: wire ProfileScreen and tab views with IndexedStack in HomeScreen"
```
