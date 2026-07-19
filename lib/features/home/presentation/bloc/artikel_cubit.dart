import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

/// State untuk section Artikel Kesehatan.
final class ArtikelState extends Equatable {
  const ArtikelState({this.selectedCategory = 0});

  final int selectedCategory;

  ArtikelState copyWith({int? selectedCategory}) => ArtikelState(
        selectedCategory: selectedCategory ?? this.selectedCategory,
      );

  @override
  List<Object> get props => [selectedCategory];
}

// ---------------------------------------------------------------------------
// Cubit
// ---------------------------------------------------------------------------

/// Cubit yang mengelola filter kategori pada [ArtikelKesehatanSection].
class ArtikelCubit extends Cubit<ArtikelState> {
  ArtikelCubit() : super(const ArtikelState());

  /// Pilih kategori berdasarkan [index].
  void selectCategory(int index) =>
      emit(state.copyWith(selectedCategory: index));
}
