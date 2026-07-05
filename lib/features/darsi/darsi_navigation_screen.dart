import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rs_islam_app/core/constants/app_spacing.dart';
import 'package:rs_islam_app/core/theme/app_colors.dart';
import 'package:rs_islam_app/core/theme/app_radius.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Where the DARSI Next.js webview is served. Defaults to the deployed Vercel
/// production URL (OTA-updatable, per docs/ARCHITECTURE.md). Override at build/run
/// time with `--dart-define=DARSI_URL=...` for local dev instead:
///   - a USB-connected real device with `adb reverse tcp:3000 tcp:3000` → http://localhost:3000/
///   - Android emulator without adb reverse → http://10.0.2.2:3000/
///   - device on the same LAN without adb reverse → the PC's LAN IP, e.g. http://192.168.1.10:3000/
/// The backend API (FastAPI) is still local for now regardless of this URL — the
/// WebView's JS runs on-device, so NEXT_PUBLIC_API_BASE_URL's 127.0.0.1:8000 fallback
/// still resolves via `adb reverse tcp:8000 tcp:8000`.
const String _darsiUrl = String.fromEnvironment(
  'DARSI_URL',
  defaultValue: 'https://darsi-indoor-navigation.vercel.app/',
);

class DarsiNavigationScreen extends StatefulWidget {
  const DarsiNavigationScreen({super.key});

  @override
  State<DarsiNavigationScreen> createState() => _DarsiNavigationScreenState();
}

/// Native bridge to the embedded Unity (UaaL) AR module. The Android side
/// (MainActivity.kt) launches UnityPlayerGameActivity with the payload.
/// Method name + channel name are the locked contract.
const _unityChannel = MethodChannel('darsi/unity');

class _DarsiNavigationScreenState extends State<DarsiNavigationScreen> {
  late final WebViewController _controller;
  var _loading = true;
  var _hasError = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.pageBackground)
      // The Next.js UI posts to window.DarsiBridge.postMessage(json) — this is
      // the bridge that receives those messages on the Flutter side.
      // Channel name is the locked contract (docs/API_CONTRACT.md / INTEGRATION.md).
      ..addJavaScriptChannel(
        'DarsiBridge',
        onMessageReceived: _onWebMessage,
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() {
            _loading = true;
            _hasError = false;
          }),
          onPageFinished: (_) => setState(() => _loading = false),
          onWebResourceError: (_) => setState(() {
            _loading = false;
            _hasError = true;
          }),
        ),
      )
      ..loadRequest(Uri.parse(_darsiUrl));

    // Receive Unity (UaaL) -> Flutter events on the same channel (T4.5).
    _unityChannel.setMethodCallHandler(_onUnityEvent);
  }

  Future<dynamic> _onUnityEvent(MethodCall call) async {
    debugPrint('DARSI unity->flutter: ${call.method} ${call.arguments}');
    if (call.method == 'arSessionClosed') {
      // Hand the AR result back to the WebView so it can resume (window.onARSessionClosed
      // is defined by the Next.js side, T3.5). Payload is trusted JSON from our own Unity.
      final payload = call.arguments as String? ?? '{}';
      await _controller.runJavaScript(
        'window.onARSessionClosed && window.onARSessionClosed($payload)',
      );
    }
    // localizationSuccess / navigationArrived / arSessionReady: no host UI action yet.
  }

  @override
  void dispose() {
    _unityChannel.setMethodCallHandler(null);
    super.dispose();
  }

  void _onWebMessage(JavaScriptMessage message) {
    // Messages look like: {"action":"launchAR","poiName":"IGD","floor":"Lt.1"}
    final data = jsonDecode(message.message) as Map<String, dynamic>;
    switch (data['action']) {
      case 'launchAR':
        _launchAr(data);
      default:
        debugPrint('DARSI: unknown message ${message.message}');
    }
  }

  Future<void> _launchAr(Map<String, dynamic> data) async {
    // Forward the full launchAR payload to Unity (UaaL). The native side reads it
    // as an intent extra; UaaLEntryPoint buffers it until localization succeeds.
    debugPrint('DARSI launchAR: $data');
    try {
      await _unityChannel.invokeMethod('launchAr', jsonEncode(data));
    } on PlatformException catch (e) {
      debugPrint('DARSI launchAR failed: ${e.message}');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuka AR: ${e.message}')),
      );
    }
  }

  Future<void> _handleBack() async {
    if (await _controller.canGoBack()) {
      await _controller.goBack();
      return;
    }
    if (mounted) Navigator.of(context).pop();
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
          // Green behind the rounded card corners so the curve looks correct
          backgroundColor: AppColors.headerGradientEnd,
          body: Column(
            children: [
              _DarsiHeader(onBack: _handleBack),
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
                  child: Stack(
                    children: [
                      if (!_hasError) WebViewWidget(controller: _controller),
                      if (_loading && !_hasError)
                        const Center(child: CircularProgressIndicator()),
                      if (_hasError) _ErrorView(onRetry: _reload),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _reload() {
    setState(() => _hasError = false);
    _controller.loadRequest(Uri.parse(_darsiUrl));
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
              'Gagal memuat halaman. Periksa koneksi internet Anda.',
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

// ---------------------------------------------------------------------------
// Header — replicates the "Layanan Unggulan" AppBar style:
// green gradient + back arrow + title/subtitle + stadium pattern ornament.
// ---------------------------------------------------------------------------

class _DarsiHeader extends StatelessWidget {
  const _DarsiHeader({required this.onBack});

  final VoidCallback onBack;

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
          // Ornamental pattern on the right (same as HomeHeader)
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
          // Header content
          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.only(
                left: AppSpacing.s(context, 4),
                right: AppSpacing.s(context, AppSpacing.pageHorizontal),
                top: AppSpacing.s(context, 4),
                bottom: AppSpacing.s(context, 28),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: AppSpacing.s(context, 24),
                    ),
                    onPressed: onBack,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(
                      minWidth: AppSpacing.s(context, 40),
                      minHeight: AppSpacing.s(context, 40),
                    ),
                  ),
                  SizedBox(width: AppSpacing.s(context, 4)),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Navigasi Indoor',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: AppSpacing.s(context, 18),
                          ),
                        ),
                        SizedBox(height: AppSpacing.s(context, 2)),
                        Text(
                          'Temukan ruangan dengan AR',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.75),
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

// ---------------------------------------------------------------------------
// Stadium pattern painter — identical to the one used in HomeHeader
// (replicated here because the original is a private class).
// ---------------------------------------------------------------------------

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
