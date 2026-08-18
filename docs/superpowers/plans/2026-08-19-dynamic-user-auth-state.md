# Dynamic User Auth State & Home Header Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create a global `AuthCubit` to manage user identity, wire `HomeHeader` to reactively display the user's full name, and handle Supabase auth events in `ProfileScreen` via `ProfileBridge`.

**Architecture:** Implement `AuthCubit` (Bloc) in `lib/features/home/presentation/bloc/auth_cubit.dart`, register it globally at `main.dart`, update `HomeHeader` with `BlocBuilder<AuthCubit, AuthState>`, and update `ProfileScreen` to dispatch `login`/`logout` on receiving JavaScript messages.

**Tech Stack:** Flutter, Dart, `flutter_bloc`, `equatable`.

## Global Constraints
- Target minSdk: 29 (Android)
- Flutter SDK: ^3.12.2
- Maintain AppColors, AppRadius, and AppSpacing baseline system (402px)

---

### Task 1: Create Global AuthCubit and Register in RsIslamApp

**Files:**
- Create: `lib/features/home/presentation/bloc/auth_cubit.dart`
- Modify: `lib/main.dart`
- Test: `test/auth_cubit_test.dart`

**Interfaces:**
- Produces: `class AuthCubit extends Cubit<AuthState>`, `class AuthState extends Equatable`
- Consumes: `flutter_bloc`, `equatable`

- [ ] **Step 1: Write unit test for `AuthCubit`**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:rs_islam_app/features/home/presentation/bloc/auth_cubit.dart';

void main() {
  group('AuthCubit', () {
    test('initial state has fullName "Tamu" and isAuthenticated false', () {
      final cubit = AuthCubit();
      expect(cubit.state.isAuthenticated, false);
      expect(cubit.state.fullName, 'Tamu');
      expect(cubit.state.email, isNull);
    });

    test('login emits authenticated state with user details', () {
      final cubit = AuthCubit();
      cubit.login(fullName: 'Ahmad Fauzi Rahman', email: 'ahmad@example.com', token: 'dummy_jwt');
      expect(cubit.state.isAuthenticated, true);
      expect(cubit.state.fullName, 'Ahmad Fauzi Rahman');
      expect(cubit.state.email, 'ahmad@example.com');
      expect(cubit.state.token, 'dummy_jwt');
    });

    test('logout resets state back to Tamu', () {
      final cubit = AuthCubit();
      cubit.login(fullName: 'Ahmad Fauzi Rahman');
      expect(cubit.state.isAuthenticated, true);

      cubit.logout();
      expect(cubit.state.isAuthenticated, false);
      expect(cubit.state.fullName, 'Tamu');
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/auth_cubit_test.dart`

- [ ] **Step 3: Implement `auth_cubit.dart` and register in `main.dart`**

Create `lib/features/home/presentation/bloc/auth_cubit.dart`:
```dart
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

final class AuthState extends Equatable {
  const AuthState({
    this.isAuthenticated = false,
    this.fullName = 'Tamu',
    this.email,
    this.token,
  });

  final bool isAuthenticated;
  final String fullName;
  final String? email;
  final String? token;

  AuthState copyWith({
    bool? isAuthenticated,
    String? fullName,
    String? email,
    String? token,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      token: token ?? this.token,
    );
  }

  @override
  List<Object?> get props => [isAuthenticated, fullName, email, token];
}

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(const AuthState());

  void login({
    required String fullName,
    String? email,
    String? token,
  }) {
    emit(AuthState(
      isAuthenticated: true,
      fullName: fullName.trim().isEmpty ? 'Tamu' : fullName.trim(),
      email: email,
      token: token,
    ));
  }

  void logout() {
    emit(const AuthState());
  }
}
```

Modify `lib/main.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rs_islam_app/core/bloc/app_bloc_observer.dart';
import 'package:rs_islam_app/core/theme/app_theme.dart';
import 'package:rs_islam_app/features/home/presentation/bloc/auth_cubit.dart';
import 'package:rs_islam_app/features/home/presentation/bloc/navigation_cubit.dart';
import 'package:rs_islam_app/features/home/presentation/screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = const AppBlocObserver();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const RsIslamApp());
}

class RsIslamApp extends StatelessWidget {
  const RsIslamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<NavigationCubit>(
          create: (_) => NavigationCubit(),
        ),
        BlocProvider<AuthCubit>(
          create: (_) => AuthCubit(),
        ),
      ],
      child: MaterialApp(
        title: 'RS Islam Surabaya',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const HomeScreen(),
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/auth_cubit_test.dart`

- [ ] **Step 5: Commit changes**

```bash
git add lib/features/home/presentation/bloc/auth_cubit.dart lib/main.dart test/auth_cubit_test.dart
git commit -m "feat: implement AuthCubit and register globally in RsIslamApp"
```

---

### Task 2: Connect HomeHeader and ProfileScreen to AuthCubit

**Files:**
- Modify: `lib/features/home/presentation/widgets/home_header.dart`
- Modify: `lib/features/profile/presentation/screens/profile_screen.dart`
- Modify: `test/widget_test.dart`

**Interfaces:**
- Consumes: `AuthCubit`, `AuthState`
- Produces: Reactive `HomeHeader` displaying user full name, `ProfileScreen` delegating auth messages to `AuthCubit`

- [ ] **Step 1: Write widget test for reactive HomeHeader with AuthCubit**

Update `test/widget_test.dart` to verify that when `AuthCubit.login(...)` is called, `HomeHeader` displays the user's full name.

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/widget_test.dart`

- [ ] **Step 3: Update `home_header.dart` and `profile_screen.dart`**

Update `lib/features/home/presentation/widgets/home_header.dart`:
```dart
BlocBuilder<AuthCubit, AuthState>(
  builder: (context, state) {
    return Row(
      children: [
        Expanded(
          child: Text(
            state.fullName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: AppSpacing.s(context, 28),
            ),
          ),
        ),
        Icon(
          Icons.keyboard_arrow_down_rounded,
          color: AppColors.accentYellow,
          size: AppSpacing.s(context, 28),
        ),
      ],
    );
  },
),
```

Update `lib/features/profile/presentation/screens/profile_screen.dart`:
```dart
void _onWebMessage(JavaScriptMessage message) {
  debugPrint('ProfileBridge message: ${message.message}');
  try {
    final data = jsonDecode(message.message) as Map<String, dynamic>;
    final event = (data['event'] ?? data['action'] ?? '').toString().toUpperCase();
    if (event == 'LOGIN_SUCCESS' || event == 'REGISTER_SUCCESS') {
      final user = data['user'] as Map<String, dynamic>? ?? {};
      final fullName = user['fullName'] ?? user['name'] ?? data['fullName'] ?? 'Pengguna';
      final email = user['email'] as String?;
      final token = data['token'] as String?;
      if (mounted) {
        context.read<AuthCubit>().login(
          fullName: fullName.toString(),
          email: email,
          token: token,
        );
      }
    } else if (event == 'LOGOUT') {
      if (mounted) {
        context.read<AuthCubit>().logout();
      }
    }
  } catch (e) {
    debugPrint('ProfileBridge decode error: $e');
  }
}
```

- [ ] **Step 4: Run all tests to verify they pass**

Run: `flutter test`

- [ ] **Step 5: Commit changes**

```bash
git add lib/features/home/presentation/widgets/home_header.dart lib/features/profile/presentation/screens/profile_screen.dart test/widget_test.dart
git commit -m "feat: connect HomeHeader and ProfileBridge to AuthCubit"
```
