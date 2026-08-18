import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rs_islam_app/features/home/presentation/bloc/auth_cubit.dart';
import 'package:rs_islam_app/features/home/presentation/widgets/home_header.dart';
import 'package:rs_islam_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:rs_islam_app/main.dart';
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

  testWidgets('HomeHeader updates reactively when AuthCubit emits new state', (tester) async {
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final authCubit = AuthCubit();

    await tester.pumpWidget(
      BlocProvider<AuthCubit>.value(
        value: authCubit,
        child: const MaterialApp(
          home: Scaffold(
            body: HomeHeader(),
          ),
        ),
      ),
    );

    // Initial state is 'Tamu'
    expect(find.text('Tamu'), findsOneWidget);

    // Login updates name
    authCubit.login(fullName: 'Ahmad Fauzi Rahman');
    await tester.pump();
    expect(find.text('Ahmad Fauzi Rahman'), findsOneWidget);
    expect(find.text('Tamu'), findsNothing);

    // Logout resets back to 'Tamu'
    authCubit.logout();
    await tester.pumpAndSettle();
    expect(find.text('Tamu'), findsOneWidget);
    expect(find.text('Ahmad Fauzi Rahman'), findsNothing);
  });

  testWidgets('HomeScreen renders guest greeting and home feed', (tester) async {
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const RsIslamApp());
    await tester.pump();

    expect(find.text('Tamu'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Menu Layanan'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Menu Layanan'), findsOneWidget);
  });

  testWidgets('Tapping Profil tab switches to ProfileScreen, tapping Home switches back', (tester) async {
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const RsIslamApp());
    await tester.pump();

    // Verify initial home feed
    expect(find.text('Tamu'), findsOneWidget);

    // Tap Profil tab
    await tester.tap(find.text('Profil'));
    await tester.pump(const Duration(milliseconds: 300));

    // Verify ProfileScreen is rendered
    expect(find.byType(ProfileScreen), findsOneWidget);
    expect(find.text('Profil Akun'), findsOneWidget);

    // Tap Home tab
    await tester.tap(find.text('Home'));
    await tester.pump(const Duration(milliseconds: 300));

    // Verify back to home feed
    expect(find.text('Tamu'), findsOneWidget);
  });

  testWidgets('Integration: Login in ProfileScreen updates HomeHeader username', (tester) async {
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const RsIslamApp());
    await tester.pump();

    expect(find.text('Tamu'), findsOneWidget);

    // Switch to Profile tab
    await tester.tap(find.text('Profil'));
    await tester.pump(const Duration(milliseconds: 300));

    final profileBridge = MockPlatformWebViewController.registeredChannels.firstWhere(
      (c) => c.name == 'ProfileBridge',
    );

    // Simulate login success from web
    profileBridge.onMessageReceived(
      const JavaScriptMessage(
        message: '{"event":"LOGIN_SUCCESS","user":{"fullName":"Ahmad Fauzi Rahman","email":"ahmad@example.com"},"token":"token_abc"}',
      ),
    );
    await tester.pump();

    // Switch back to Home tab
    await tester.tap(find.text('Home'));
    await tester.pump(const Duration(milliseconds: 300));

    // Verify updated name
    expect(find.text('Ahmad Fauzi Rahman'), findsOneWidget);
    expect(find.text('Tamu'), findsNothing);
  });

  testWidgets('Tapping Janji Temu and Riwayat tabs shows placeholder views', (tester) async {
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const RsIslamApp());
    await tester.pump();

    // Tap Janji Temu
    await tester.tap(find.text('Janji Temu'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Janji Temu'), findsWidgets);
    expect(find.text('Fitur ini sedang dalam pengembangan'), findsOneWidget);

    // Tap Riwayat
    await tester.tap(find.text('Riwayat'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Riwayat Medis'), findsOneWidget);
    expect(find.text('Fitur ini sedang dalam pengembangan'), findsOneWidget);
  });
}
