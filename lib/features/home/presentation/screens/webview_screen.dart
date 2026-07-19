import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:rs_islam_app/features/home/presentation/bloc/webview_cubit.dart';

/// Entry point publik — membungkus layar WebView dengan [WebViewCubit]
/// lokal agar state loading/error dapat diobservasi oleh [BlocObserver].
class WebViewScreen extends StatelessWidget {
  const WebViewScreen({
    super.key,
    required this.url,
    required this.title,
  });

  final String url;
  final String title;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WebViewCubit(),
      child: _WebViewBody(url: url, title: title),
    );
  }
}

/// Body aktual WebView — StatefulWidget agar bisa menginisialisasi
/// [WebViewController] di [initState], sekarang sudah memiliki akses
/// ke [WebViewCubit] yang disediakan oleh [WebViewScreen] di atasnya.
class _WebViewBody extends StatefulWidget {
  const _WebViewBody({required this.url, required this.title});

  final String url;
  final String title;

  @override
  State<_WebViewBody> createState() => _WebViewBodyState();
}

class _WebViewBodyState extends State<_WebViewBody> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          // Gunakan context.read karena kita hanya perlu memanggil method,
          // bukan mendengarkan state — tidak perlu BlocBuilder di sini.
          onPageStarted: (_) =>
              context.read<WebViewCubit>().onPageStarted(),
          onPageFinished: (_) =>
              context.read<WebViewCubit>().onPageFinished(),
          onWebResourceError: (_) =>
              context.read<WebViewCubit>().onPageError(),
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _handleBack();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          leading: BackButton(onPressed: _handleBack),
        ),
        body: BlocBuilder<WebViewCubit, WebViewState>(
          builder: (context, state) {
            return Stack(
              children: [
                if (!state.hasError) WebViewWidget(controller: _controller),
                if (state.isLoading && !state.hasError)
                  const Center(child: CircularProgressIndicator()),
                if (state.hasError)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.wifi_off, size: 48),
                          const SizedBox(height: 12),
                          const Text(
                            'Gagal memuat halaman. Periksa koneksi internet Anda.',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: () {
                              context.read<WebViewCubit>().resetError();
                              _controller.loadRequest(Uri.parse(widget.url));
                            },
                            child: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
