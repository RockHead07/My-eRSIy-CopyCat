# Profile & Supabase Auth Integration Guide

This document defines the integration contract between the **Flutter Host App** and the **External Webview (Next.js + Supabase Auth)**.

---

## 1. Overview & Architecture

The application adopts a hybrid shell architecture where the user authentication (Login, Register, Password Reset, Google OAuth, Session Management) is driven inside a Next.js web application hosted on Vercel and backed by **Supabase**.

```
┌────────────────────────────────────────────────────────┐
│                   Next.js Webview                      │
│   (Supabase Auth: signIn, signUp, OAuth, profiles)     │
└──────────────────────────┬─────────────────────────────┘
                           │
                           │ window.ProfileBridge.postMessage(JSON)
                           ▼
┌────────────────────────────────────────────────────────┐
│                   Flutter Host App                     │
│  - ProfileBridge receives event                        │
│  - Dispatches to AuthCubit                             │
│  - HomeHeader reactively displays user's full name     │
└────────────────────────────────────────────────────────┘
```

---

## 2. JavaScript Bridge Contract (`ProfileBridge`)

When embedding the authentication web page inside `ProfileScreen`, the web application can communicate with Flutter by posting messages to `window.ProfileBridge`:

### A. Login Success (`LOGIN_SUCCESS`)
Emit when the user successfully signs in:
```javascript
if (window.ProfileBridge) {
  window.ProfileBridge.postMessage(JSON.stringify({
    event: "LOGIN_SUCCESS",
    user: {
      fullName: "Ahmad Fauzi Rahman",
      email: "ahmad.fauzi@example.com"
    },
    token: "optional_jwt_session_token"
  }));
}
```

### B. Register Success (`REGISTER_SUCCESS`)
Emit when a new user registers:
```javascript
if (window.ProfileBridge) {
  window.ProfileBridge.postMessage(JSON.stringify({
    event: "REGISTER_SUCCESS",
    user: {
      fullName: "Siti Nurhaliza",
      email: "siti@example.com"
    },
    token: "optional_jwt_session_token"
  }));
}
```

### C. Logout (`LOGOUT`)
Emit when the user signs out from the profile web page:
```javascript
if (window.ProfileBridge) {
  window.ProfileBridge.postMessage(JSON.stringify({
    event: "LOGOUT"
  }));
}
```

---

## 3. Flutter State Reaction (`AuthCubit`)

Upon receiving bridge messages:
- `LOGIN_SUCCESS` / `REGISTER_SUCCESS`: `AuthCubit.login(fullName, email, token)` emits an authenticated state.
- `LOGOUT`: `AuthCubit.logout()` resets the state to guest mode (`fullName = 'Tamu'`).
- `HomeHeader` automatically updates its user title without requiring a manual refresh.

---

## 4. Environment Configuration

To test against a local Next.js development server:

```bash
# 1. Reverse ports over ADB (for physical Android device over USB)
adb reverse tcp:3000 tcp:3000

# 2. Run Flutter with local auth URL
flutter run --dart-define=PROFILE_AUTH_URL=http://localhost:3000/profile
```
