import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

/// State untuk sebuah layar WebView (loading / sukses / error).
final class WebViewState extends Equatable {
  const WebViewState({
    this.isLoading = true,
    this.hasError = false,
  });

  final bool isLoading;
  final bool hasError;

  WebViewState copyWith({bool? isLoading, bool? hasError}) => WebViewState(
        isLoading: isLoading ?? this.isLoading,
        hasError: hasError ?? this.hasError,
      );

  @override
  List<Object> get props => [isLoading, hasError];
}

// ---------------------------------------------------------------------------
// Cubit
// ---------------------------------------------------------------------------

/// Cubit yang mengelola status loading/error sebuah [WebViewScreen].
///
/// Dapat dipakai ulang untuk semua layar WebView (termasuk DARSI) —
/// cukup buat instance berbeda per layar.
class WebViewCubit extends Cubit<WebViewState> {
  WebViewCubit() : super(const WebViewState());

  /// Dipanggil ketika halaman mulai dimuat.
  void onPageStarted() => emit(const WebViewState(isLoading: true, hasError: false));

  /// Dipanggil ketika halaman selesai dimuat.
  void onPageFinished() => emit(state.copyWith(isLoading: false));

  /// Dipanggil ketika terjadi error saat memuat halaman.
  void onPageError() => emit(const WebViewState(isLoading: false, hasError: true));

  /// Reset error lalu muat ulang (dipakai tombol "Coba Lagi").
  void resetError() => emit(state.copyWith(hasError: false, isLoading: true));
}
