<div align="center">

# 🏥 rs_islam_app — MyRSIy *CopyCat*

**A stand-in host shell for developing & testing the DARSI (AR Indoor Navigation) integration without access to the real MyRSIy app.**

A new Flutter project.
or...
You might need to say, that this is a copycat of My eRSIy <href="https://play.google.com/store/apps/details?id=id.kksoft.myrsiy&hl=id"> app! 

<p>
  <img src="https://img.shields.io/badge/status-integration%20harness-blue?style=for-the-badge" alt="status" />
  <img src="https://img.shields.io/badge/platform-Android-3DDC84?style=for-the-badge&logo=android&logoColor=white" alt="platform" />
  <img src="https://img.shields.io/badge/purpose-DARSI%20UaaL%20test-orange?style=for-the-badge" alt="purpose" />
  <img src="https://img.shields.io/badge/license-WTFPL-lightgrey?style=for-the-badge" alt="license" />
</p>

<p>
  <img src="https://img.shields.io/badge/Flutter-02569B?style=flat-square&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-0175C2?style=flat-square&logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/Kotlin-7F52FF?style=flat-square&logo=kotlin&logoColor=white" alt="Kotlin" />
  <img src="https://img.shields.io/badge/Unity-000000?style=flat-square&logo=unity&logoColor=white" alt="Unity" />
  <img src="https://img.shields.io/badge/Gradle-02303A?style=flat-square&logo=gradle&logoColor=white" alt="Gradle" />
  <img src="https://img.shields.io/badge/WebView-Next.js-000000?style=flat-square&logo=nextdotjs&logoColor=white" alt="WebView / Next.js" />
</p>

<br/>

<a href="https://skillicons.dev">
  <img src="https://skillicons.dev/icons?i=flutter,dart,kotlin,unity,gradle,androidstudio,nextjs&perline=7" alt="tech stack" />
</a>

<br/><br/>

<img width="360" alt="MyRSIy CopyCat home screen" src="https://github.com/user-attachments/assets/8c95be2a-c2e4-4ae0-a040-7a157d370356" />

</div>

---

## 🎯 Why this repo exists

This is **not** the real MyRSIy app, and **not** a product meant to ship.

The **DARSI** feature (AR Indoor Navigation for RS Islam A. Yani) is designed to be embedded into the **MyRSIy** app (Flutter) via **Unity as a Library (UaaL)**. The catch: **the DARSI team has no access to the real MyRSIy Flutter source / UI.** Without a host to carry Unity + WebView, the integration (launching AR, passing payloads, the return path) can't be developed — let alone tested.

This repo solves that: a **"copycat"** — a minimal Flutter host that mimics just enough of the MyRSIy flow (menu → *Navigasi Indoor* → WebView → launch Unity AR) purely as an **integration harness**. Once the bridge contract is proven here, the real MyRSIy side just replicates the same pattern.

> **TL;DR** — This is the "rehearsal stage" for proving DARSI can be embedded and its bridge wires up correctly, standing in for the real MyRSIy app we can't touch.

---

## 🧩 What is reproduced (and what isn't)

| Present in this repo | Deliberately absent |
|---|---|
| A MyRSIy-styled Home screen (reactive `AuthCubit`, dummy data) | Real MyRSIy backend / production API |
| **Infinite Hero Carousel** (3 hospital banners, auto-slide 5s) | Full payment gateway / billing live API |
| **Navigasi Indoor** menu item → `DarsiNavigationScreen` | Other MyRSIy features (appointments live booking) |
| Embedded **WebView** (DARSI UI, hosted on Vercel) | The real MyRSIy UI source (we don't have it) |
| Embedded **Profile / Auth WebView** (`ProfileScreen` in Tab Navbar) | |
| Embedded **Unity as a Library** (`:unityLibrary`) + AR launcher | |
| Two-way **bridge** Flutter ⇄ Kotlin ⇄ Unity ⇄ WebView & `ProfileBridge` | |

---

## 🔀 The integration flow under test

### 1. DARSI AR Navigation Flow
```
MyRSIy (copycat, Flutter)
        │  tap "Navigasi Indoor"
        ▼
DarsiNavigationScreen ──► WebView (Next.js @ Vercel)
        │                        │  user picks destination → launchAR(payload)
        │  MethodChannel         ▼
        ▼                 MainActivity (Kotlin)
DarsiUnityActivity ◄──────────────┘  Intent-extra "darsiPayload"
  (UnityPlayerGameActivity)
        │  UaaLEntryPoint reads payload → starts AR
        ▼
   Unity AR (MultiSet SDK)
        │  event back: UnityBridge.send() → MethodChannel
        ▼
WebView.onARSessionClosed(payload)   ← moveTaskToBack, Unity stays resident
```

### 2. Profile / Auth Bridge Flow (Supabase Ready)
```
HomeScreen (Tab 3: Profil)
        │
        ▼
ProfileScreen ──────────► Embedded WebView (Next.js / Supabase Auth)
        │                        │  User login/register via Supabase
        │  ProfileBridge         ▼
        │  (postMessage)  window.ProfileBridge.postMessage({ event: 'LOGIN_SUCCESS', user: { fullName: '...' } })
        ▼
AuthCubit.login(fullName)
        │  emits new AuthState
        ▼
HomeHeader (Reactively displays the User's full name instead of "Tamu")
```

---

## 🛠️ Tech stack

| Layer | Technology | Role |
|---|---|---|
| Host app | **Flutter · Dart** | MyRSIy stand-in shell, WebView container, MethodChannel, `flutter_bloc` |
| Native bridge | **Kotlin · Android** | `MainActivity`, `DarsiUnityActivity`, `UnityBridge` (Flutter ⇄ Unity) |
| AR engine | **Unity (UaaL)** | Exported as an Android library, embedded as `:unityLibrary` |
| Build | **Gradle (AGP 9) · IL2CPP** | Merges Unity + Flutter, ABI `arm64-v8a` |
| DARSI UI & Auth | **Next.js (WebView)** | Hosted externally (Vercel) + Supabase Auth integration |

---

## 🚀 Running

```bash
flutter pub get
flutter test         # Run unit & widget tests suite
flutter run          # debug, onto a physical Android device (ARCore required)
```

> ⚠️ **A physical ARCore-capable Android device is required** — Unity AR does not run on an emulator.
> Targets `minSdk 29`, ABI `arm64-v8a`, portrait-locked.

### Environment Overrides (`--dart-define`)
- `--dart-define=DARSI_URL=http://localhost:3000/` (override DARSI indoor nav WebView URL)
- `--dart-define=PROFILE_AUTH_URL=http://localhost:3000/profile` (override Profile/Auth WebView URL)

### After re-exporting Unity

`android/unityLibrary/` is **not tracked by git** (~4 GB of Unity Export output). Whenever Unity is re-exported, run the re-integration script to re-apply the AGP-9 patches:

```powershell
./tool/reintegrate-unity.ps1
```

---

## 📦 Packages

| Package | For |
|---|---|
| `webview_flutter` | Container for the DARSI & Profile WebView UI |
| `flutter_bloc` | BLoC / Cubit state management (`AuthCubit`, `NavigationCubit`, `WebViewCubit`) |
| `equatable` | Value equality for immutable BLoC states |
| `google_fonts` | Poppins typography (MyRSIy style) |
| `smooth_page_indicator` | Hero banner carousel dots (`ExpandingDotsEffect`) |
| `app_links` | Deep linking return path from WebXR AR |

---

## 🗂️ Structure

```
lib/
  core/
    bloc/                         # AppBlocObserver
    constants/                    # AppSpacing (402px baseline)
    theme/                        # AppColors, AppRadius, AppTheme
    widgets/                      # SectionHeader
  features/
    home/                         # MyRSIy-styled Home (IndexedStack tabs, banner carousel, menu grid, articles)
      presentation/bloc/          # AuthCubit, NavigationCubit, WebViewCubit, ArtikelCubit
    profile/                      # Profile & Auth WebView screen with ProfileBridge
    darsi/                        # DARSI entry: green header + WebView + AR return path
android/
  app/src/main/kotlin/.../        # MainActivity, DarsiUnityActivity, UnityBridge
  unityLibrary/  shared/          # (git-ignored) Unity export output
tool/
  reintegrate-unity.ps1           # AGP-9 patches after a Unity export
  unity-patches/                  # known-good patched aar
```

---

<div align="center">
<sub>Internal experiment repo · mimics <a href="https://play.google.com/store/apps/details?id=id.kksoft.myrsiy&hl=id">MyRSIy</a> only as a host harness for testing the DARSI integration.</sub>
</div>

