# RS Islam Surabaya — Home UI Slice

Flutter UI slicing for the guest Home screen (RS Islam Surabaya - A. Yani).

## Run

```bash
flutter pub get
flutter run
```

## Packages

| Package | Why |
|---------|-----|
| `google_fonts` | Poppins typography from design |
| `smooth_page_indicator` | Banner carousel dots |
| `webview_flutter` | Generic WebView for menu items marked `webview` |

**State management:** none for this slice — guest Home is static dummy data. Add **Riverpod** when auth/session and API wiring land (simple, testable, scales well for Flutter).

## Structure

```
lib/
  core/theme/          # AppColors, AppRadius, AppTheme
  core/constants/      # AppSpacing (402px baseline)
  core/widgets/        # SectionHeader
  features/home/
    data/              # MenuItemModel, banners, dummy menu config
    presentation/
      navigation/      # MenuNavigator.handle()
      screens/         # HomeScreen, WebViewScreen
      widgets/         # Header, carousel, menu grid, articles, bottom nav
```

## WebView menu config

Change `actionType` in `lib/features/home/data/menu_items.dart` — no grid widget edits needed.

Example: **Homecare** opens `https://rsislam-surabaya.com` via `WebViewScreen`.

## Assets

- `assets/images/banner_hospital.png` — design reference banner
- Drop flat menu icons at `assets/icons/menu/*.png` (grid uses `Image.asset` with Material icon fallback until art is ready)

## Android

`INTERNET` permission is required for WebView (already in `AndroidManifest.xml`).
