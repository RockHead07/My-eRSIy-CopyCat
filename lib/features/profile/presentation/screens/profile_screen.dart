import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rs_islam_app/core/constants/app_spacing.dart';
import 'package:rs_islam_app/core/theme/app_colors.dart';
import 'package:rs_islam_app/core/theme/app_radius.dart';
import 'package:rs_islam_app/features/home/presentation/bloc/auth_cubit.dart';
import 'package:rs_islam_app/features/home/presentation/bloc/webview_cubit.dart';
import 'package:webview_flutter/webview_flutter.dart';

const String _profileAuthUrl = String.fromEnvironment(
  'PROFILE_AUTH_URL',
  defaultValue: 'https://darsi-indoor-navigation.vercel.app/profile',
);

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WebViewCubit(),
      child: const _ProfileBody(),
    );
  }
}

class _ProfileBody extends StatefulWidget {
  const _ProfileBody();

  @override
  State<_ProfileBody> createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<_ProfileBody> {
  late final WebViewController _controller;

  // Layar auth (login/register/lupa password) berdiri sendiri di WebView
  // dengan heading-nya sendiri -- header hijau native jadi dobel di atasnya.
  // Disembunyikan berdasar path URL WebView saat ini, bukan cuma di /profile.
  bool _hideHeader = false;

  bool _isAuthPath(String url) => (Uri.tryParse(url)?.path ?? '').startsWith('/auth/');

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.pageBackground)
      ..addJavaScriptChannel(
        'ProfileBridge',
        onMessageReceived: _onWebMessage,
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            if (!mounted) return;
            context.read<WebViewCubit>().onPageStarted();
            setState(() => _hideHeader = _isAuthPath(url));
          },
          onPageFinished: (url) {
            if (!mounted) return;
            context.read<WebViewCubit>().onPageFinished();
            setState(() => _hideHeader = _isAuthPath(url));
          },
          onWebResourceError: (_) {
            if (mounted) context.read<WebViewCubit>().onPageError();
          },
        ),
      )
      ..loadRequest(Uri.parse(_profileAuthUrl));
  }

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

  Future<void> _handleBack() async {
    if (await _controller.canGoBack()) {
      await _controller.goBack();
    }
  }

  void _reload() {
    context.read<WebViewCubit>().resetError();
    _controller.loadRequest(Uri.parse(_profileAuthUrl));
  }

  @override
  Widget build(BuildContext context) {
    final showHeader = !_hideHeader;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: showHeader ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) async {
          if (didPop) return;
          await _handleBack();
        },
        child: Scaffold(
          backgroundColor: showHeader ? AppColors.headerGradientEnd : AppColors.pageBackground,
          body: Column(
            children: [
              if (showHeader) const _ProfileHeader(),
              Expanded(
                child: SafeArea(
                  top: !showHeader,
                  bottom: false,
                  child: Container(
                    width: double.infinity,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: AppColors.pageBackground,
                      borderRadius: showHeader
                          ? const BorderRadius.vertical(top: Radius.circular(AppRadius.xl))
                          : BorderRadius.zero,
                    ),
                    child: BlocBuilder<WebViewCubit, WebViewState>(
                      builder: (context, state) {
                        return Stack(
                          children: [
                            if (!state.hasError)
                              WebViewWidget(controller: _controller),
                            if (state.isLoading && !state.hasError)
                              const Center(child: CircularProgressIndicator()),
                            if (state.hasError) _ErrorView(onRetry: _reload),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

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
          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.only(
                left: AppSpacing.s(context, AppSpacing.pageHorizontal),
                right: AppSpacing.s(context, AppSpacing.pageHorizontal),
                top: AppSpacing.s(context, 14),
                bottom: AppSpacing.s(context, 20),
              ),
              child: Row(
                children: [
                  Container(
                    width: AppSpacing.s(context, 44),
                    height: AppSpacing.s(context, 44),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person_outline_rounded,
                      color: Colors.white,
                      size: AppSpacing.s(context, 26),
                    ),
                  ),
                  SizedBox(width: AppSpacing.s(context, 12)),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Profil Akun',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: AppSpacing.s(context, 18),
                          ),
                        ),
                        SizedBox(height: AppSpacing.s(context, 2)),
                        Text(
                          'Masuk atau kelola akun Anda',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
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
              'Gagal memuat halaman profil. Periksa koneksi internet Anda.',
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
