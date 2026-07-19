import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rs_islam_app/features/home/presentation/widgets/custom_bottom_nav_bar.dart';

/// Cubit yang mengelola tab aktif pada [CustomBottomNavBar].
///
/// State-nya hanyalah [BottomNavItem] (value-type sederhana), sehingga
/// kita tidak perlu membungkusnya di class terpisah.
class NavigationCubit extends Cubit<BottomNavItem> {
  NavigationCubit() : super(BottomNavItem.home);

  /// Pindah ke tab [item].
  void selectTab(BottomNavItem item) => emit(item);
}
