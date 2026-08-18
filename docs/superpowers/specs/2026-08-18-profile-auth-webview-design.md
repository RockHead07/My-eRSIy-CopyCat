# Design Spec: Profile & Auth WebView Screen

## Overview
Introduce a dedicated, hybrid `ProfileScreen` featuring an RS Islam styled native Flutter header and an embedded `WebViewWidget` in a curved container. The screen is integrated into the bottom navigation bar via `HomeScreen` using `IndexedStack` to preserve web state, form inputs, and avoid reloads when switching tabs.

## Requirements

1. **Profile Screen Architecture (`lib/features/profile/presentation/screens/profile_screen.dart`)**:
   - **Header (Native Flutter)**:
     - Gradient background (`AppColors.headerGradientStart` to `AppColors.headerGradientEnd`).
     - Stadium pattern background ornament matching the hospital design tokens.
     - Title "Profil Akun" and subtitle "Masuk atau kelola akun Anda".
   - **Body (Curved WebView Container)**:
     - Top border radius (`AppRadius.xl`), page background color.
     - `WebViewWidget` with unrestricted JavaScript mode.
     - State management via `WebViewCubit` for loading spinner and error retry handling (`_ErrorView`).
     - URL configured via `String.fromEnvironment('PROFILE_AUTH_URL', defaultValue: 'https://darsi-indoor-navigation.vercel.app/profile')`.
     - JavaScript Channel `ProfileBridge` (`window.ProfileBridge.postMessage(json)`) ready for auth event messages (e.g. `LOGIN_SUCCESS`, `REGISTER_SUCCESS`, `LOGOUT`).
     - Back navigation intercept (`PopScope` + `WebViewController.canGoBack()`).

2. **Tab Integration in `HomeScreen`**:
   - Update `HomeScreen` (`lib/features/home/presentation/screens/home_screen.dart`) to use an `IndexedStack` corresponding to `BottomNavItem` values:
     - Tab 0 (`home`): Home feed (`CustomScrollView` with Header, Banners, Menu Layanan, Artikel).
     - Tab 1 (`janjiTemu`): Placeholder view / header.
     - Tab 2 (`riwayat`): Placeholder view / header.
     - Tab 3 (`profil`): `const ProfileScreen()`.

3. **Placeholder Screens**:
   - Reusable placeholder or simple styled view for `janjiTemu` and `riwayat` tabs displaying a clean "Segera Hadir" message with RS Islam branding.

## Testing & Quality
- Unit & widget tests verifying:
  - `ProfileScreen` renders header and webview structure.
  - `HomeScreen` tab switching switches active child in `IndexedStack` to `ProfileScreen`.
- No regressions on existing 8 tests.
