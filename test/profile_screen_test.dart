import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rs_islam_app/features/home/presentation/bloc/auth_cubit.dart';
import 'package:rs_islam_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:webview_flutter/webview_flutter.dart';
// ignore: depend_on_referenced_packages
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

class MockPlatformWebViewController extends PlatformWebViewController {
  MockPlatformWebViewController(super.params) : super.implementation();

  static final List<JavaScriptChannelParams> registeredChannels = [];

  @override
  Future<void> setJavaScriptMode(JavaScriptMode javaScriptMode) async {}

  @override
  Future<void> setBackgroundColor(Color color) async {}

  @override
  Future<void> addJavaScriptChannel(JavaScriptChannelParams javaScriptChannelParams) async {
    registeredChannels.add(javaScriptChannelParams);
  }

  @override
  Future<void> setPlatformNavigationDelegate(PlatformNavigationDelegate handler) async {}

  @override
  Future<void> loadRequest(LoadRequestParams params) async {}

  @override
  Future<bool> canGoBack() async => false;

  @override
  Future<void> goBack() async {}
}

class MockPlatformNavigationDelegate extends PlatformNavigationDelegate {
  MockPlatformNavigationDelegate(super.params) : super.implementation();

  @override
  Future<void> setOnPageStarted(PageEventCallback onPageStarted) async {}

  @override
  Future<void> setOnPageFinished(PageEventCallback onPageFinished) async {}

  @override
  Future<void> setOnWebResourceError(WebResourceErrorCallback onWebResourceError) async {}
}

class MockPlatformWebViewWidget extends PlatformWebViewWidget {
  MockPlatformWebViewWidget(super.params) : super.implementation();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class MockWebViewPlatform extends WebViewPlatform {
  @override
  PlatformWebViewController createPlatformWebViewController(
    PlatformWebViewControllerCreationParams params,
  ) {
    return MockPlatformWebViewController(params);
  }

  @override
  PlatformNavigationDelegate createPlatformNavigationDelegate(
    PlatformNavigationDelegateCreationParams params,
  ) {
    return MockPlatformNavigationDelegate(params);
  }

  @override
  PlatformWebViewWidget createPlatformWebViewWidget(
    PlatformWebViewWidgetCreationParams params,
  ) {
    return MockPlatformWebViewWidget(params);
  }
}

void main() {
  setUpAll(() {
    WebViewPlatform.instance = MockWebViewPlatform();
  });

  setUp(() {
    MockPlatformWebViewController.registeredChannels.clear();
  });

  testWidgets('ProfileScreen renders header and webview container', (tester) async {
    final authCubit = AuthCubit();

    await tester.pumpWidget(
      BlocProvider<AuthCubit>.value(
        value: authCubit,
        child: const MaterialApp(
          home: Scaffold(
            body: ProfileScreen(),
          ),
        ),
      ),
    );

    expect(find.text('Profil Akun'), findsOneWidget);
    expect(find.text('Masuk atau kelola akun Anda'), findsOneWidget);
    expect(find.byType(WebViewWidget), findsOneWidget);
  });

  testWidgets('ProfileBridge dispatches login on LOGIN_SUCCESS message', (tester) async {
    final authCubit = AuthCubit();

    await tester.pumpWidget(
      BlocProvider<AuthCubit>.value(
        value: authCubit,
        child: const MaterialApp(
          home: Scaffold(
            body: ProfileScreen(),
          ),
        ),
      ),
    );
    await tester.pump();

    final profileBridge = MockPlatformWebViewController.registeredChannels.firstWhere(
      (c) => c.name == 'ProfileBridge',
    );

    profileBridge.onMessageReceived(
      const JavaScriptMessage(
        message: '{"event":"LOGIN_SUCCESS","user":{"fullName":"Ahmad Fauzi Rahman","email":"ahmad@example.com"},"token":"jwt_123"}',
      ),
    );
    await tester.pump();

    expect(authCubit.state.isAuthenticated, isTrue);
    expect(authCubit.state.fullName, 'Ahmad Fauzi Rahman');
    expect(authCubit.state.email, 'ahmad@example.com');
    expect(authCubit.state.token, 'jwt_123');
  });

  testWidgets('ProfileBridge dispatches login on REGISTER_SUCCESS message with fallback name', (tester) async {
    final authCubit = AuthCubit();

    await tester.pumpWidget(
      BlocProvider<AuthCubit>.value(
        value: authCubit,
        child: const MaterialApp(
          home: Scaffold(
            body: ProfileScreen(),
          ),
        ),
      ),
    );
    await tester.pump();

    final profileBridge = MockPlatformWebViewController.registeredChannels.firstWhere(
      (c) => c.name == 'ProfileBridge',
    );

    profileBridge.onMessageReceived(
      const JavaScriptMessage(
        message: '{"action":"register_success","user":{"name":"Siti Rahma"}}',
      ),
    );
    await tester.pump();

    expect(authCubit.state.isAuthenticated, isTrue);
    expect(authCubit.state.fullName, 'Siti Rahma');
  });

  testWidgets('ProfileBridge dispatches logout on LOGOUT message', (tester) async {
    final authCubit = AuthCubit();
    authCubit.login(fullName: 'Ahmad Fauzi Rahman', email: 'ahmad@example.com');

    await tester.pumpWidget(
      BlocProvider<AuthCubit>.value(
        value: authCubit,
        child: const MaterialApp(
          home: Scaffold(
            body: ProfileScreen(),
          ),
        ),
      ),
    );
    await tester.pump();

    final profileBridge = MockPlatformWebViewController.registeredChannels.firstWhere(
      (c) => c.name == 'ProfileBridge',
    );

    profileBridge.onMessageReceived(
      const JavaScriptMessage(
        message: '{"event":"LOGOUT"}',
      ),
    );
    await tester.pump();

    expect(authCubit.state.isAuthenticated, isFalse);
    expect(authCubit.state.fullName, 'Tamu');
    expect(authCubit.state.email, isNull);
  });

  testWidgets('ProfileBridge handles malformed message without crash', (tester) async {
    final authCubit = AuthCubit();

    await tester.pumpWidget(
      BlocProvider<AuthCubit>.value(
        value: authCubit,
        child: const MaterialApp(
          home: Scaffold(
            body: ProfileScreen(),
          ),
        ),
      ),
    );
    await tester.pump();

    final profileBridge = MockPlatformWebViewController.registeredChannels.firstWhere(
      (c) => c.name == 'ProfileBridge',
    );

    profileBridge.onMessageReceived(
      const JavaScriptMessage(
        message: 'not-valid-json-string',
      ),
    );
    await tester.pump();

    expect(authCubit.state.isAuthenticated, isFalse);
    expect(authCubit.state.fullName, 'Tamu');
  });
}
