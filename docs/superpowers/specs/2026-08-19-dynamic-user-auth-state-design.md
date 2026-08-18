# Design Spec: Dynamic User Auth State & Home Header Integration

## Overview
Introduce a global `AuthCubit` and `AuthState` that manages authentication and user profile information in memory, ready for integration with Supabase authentication via the `ProfileBridge` JavaScript channel in `ProfileScreen`. The `HomeHeader` reactively displays the user's full name when authenticated, or "Tamu" (Guest) by default, with proper text overflow handling.

## Requirements

1. **Global Auth State (`lib/features/home/presentation/bloc/auth_cubit.dart`)**:
   - `AuthState`:
     - `isAuthenticated`: `bool` (default `false`).
     - `fullName`: `String` (default `'Tamu'`).
     - `email`: `String?`
     - `token`: `String?`
   - `AuthCubit`:
     - `login({required String fullName, String? email, String? token})` ➔ emits authenticated state with user information.
     - `logout()` ➔ resets state to guest (`fullName = 'Tamu'`, `isAuthenticated = false`).
   - Registered globally in `MultiBlocProvider` in `lib/main.dart`.

2. **ProfileBridge Event Consumption (`lib/features/profile/presentation/screens/profile_screen.dart`)**:
   - Handle incoming JSON messages on `ProfileBridge`:
     - Event `LOGIN_SUCCESS` or `REGISTER_SUCCESS`: extracts `user.fullName` (or `user.name`) and dispatches `context.read<AuthCubit>().login(...)`.
     - Event `LOGOUT`: dispatches `context.read<AuthCubit>().logout()`.

3. **Reactive Home Header (`lib/features/home/presentation/widgets/home_header.dart`)**:
   - Wrap the username `Text` in a `BlocBuilder<AuthCubit, AuthState>`.
   - Display `state.fullName` with `maxLines: 1` and `overflow: TextOverflow.ellipsis`.
   - Pure display without interactive popups/clicks.

## Testing & Quality
- Unit & widget tests verifying:
  - `AuthCubit` emits expected states on `login` and `logout`.
  - `HomeHeader` displays "Tamu" initially and re-renders with full name on state change.
  - `ProfileScreen` triggers `AuthCubit` when `ProfileBridge` receives `LOGIN_SUCCESS`.
- Full test suite passes without warnings or regressions.
