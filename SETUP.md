# RS Islam Surabaya — Flutter Architecture & Setup Guide

Host application and integration harness for RS Islam Surabaya (A. Yani), featuring DARSI AR Indoor Navigation and Profile Auth WebView.

## Run & Test

```bash
# Get dependencies
flutter pub get

# Run test suite (Unit & Widget tests)
flutter test

# Run app (Debug)
flutter run

# Run with custom local URLs
flutter run --dart-define=DARSI_URL=http://localhost:3000/ --dart-define=PROFILE_AUTH_URL=http://localhost:3000/profile
```

## Packages

| Package | Why |
|---------|-----|
| `flutter_bloc` | Global & local reactive state management (`AuthCubit`, `NavigationCubit`, `WebViewCubit`, `ArtikelCubit`) |
| `equatable` | Value equality for immutable state objects |
| `google_fonts` | Poppins typography from design |
| `smooth_page_indicator` | Infinite hero banner carousel dots with `ExpandingDotsEffect` |
| `webview_flutter` | Embedded WebView containers for DARSI AR navigation and Profile Auth |
| `app_links` | Deep linking return path from WebXR AR (`myrsiy://ar-done`) |

## Architecture & State Management

The application is structured using BLoC / Cubit patterns:

- **`AuthCubit` (`lib/features/home/presentation/bloc/auth_cubit.dart`):** Global user session and full name management (connected reactively to `HomeHeader` and `ProfileBridge`).
- **`NavigationCubit` (`lib/features/home/presentation/bloc/navigation_cubit.dart`):** Global active tab state on `CustomBottomNavBar` driving an `IndexedStack`.
- **`WebViewCubit` (`lib/features/home/presentation/bloc/webview_cubit.dart`):** Reusable local state manager for WebView loading and network error retry screens.
- **`ArtikelCubit` (`lib/features/home/presentation/bloc/artikel_cubit.dart`):** Category filter chips on the Artikel Kesehatan section.
- **`AppBlocObserver` (`lib/core/bloc/app_bloc_observer.dart`):** Global logger for all state transitions, events, and errors in debug mode.

## Structure

```
lib/
  core/
    bloc/              # AppBlocObserver
    theme/             # AppColors, AppRadius, AppTheme
    constants/         # AppSpacing (402px baseline scaling)
    widgets/           # SectionHeader
  features/
    home/
      data/            # MenuItemModel, BannerModel, homeMenuItems, homeBanners
      presentation/
        bloc/          # AuthCubit, NavigationCubit, WebViewCubit, ArtikelCubit
        navigation/    # MenuNavigator.handle()
        screens/       # HomeScreen, WebViewScreen
        widgets/       # HomeHeader, BannerCarousel, MenuLayananSection, ArtikelKesehatanSection, CustomBottomNavBar
    profile/
      presentation/
        screens/       # ProfileScreen (Native header + embedded WebView with ProfileBridge)
    darsi/
      presentation/
        screens/       # DarsiNavigationScreen (Native header + embedded WebView with Unity AR bridge)
```

## JavaScript Bridges Contract

1. **`ProfileBridge` (Auth & Profile):**
   - Web postMessage: `window.ProfileBridge.postMessage(JSON.stringify({ event: "LOGIN_SUCCESS", user: { fullName: "Ahmad Fauzi" } }))`
   - Automatically dispatches to `AuthCubit` to update user identity on the Home header.

2. **`DarsiBridge` (AR Navigation):**
   - Web postMessage: `window.DarsiBridge.postMessage(JSON.stringify({ action: "launchAR", poiName: "IGD", floor: "Lt.1" }))`
   - Dispatches through `MethodChannel('darsi/unity')` to launch `DarsiUnityActivity`.

## Android Permissions

`INTERNET` and `CAMERA` permissions are configured in `android/app/src/main/AndroidManifest.xml`.

