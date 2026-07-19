import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rs_islam_app/core/bloc/app_bloc_observer.dart';
import 'package:rs_islam_app/core/theme/app_theme.dart';
import 'package:rs_islam_app/features/home/presentation/bloc/navigation_cubit.dart';
import 'package:rs_islam_app/features/home/presentation/screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Pasang observer global BLoC — semua state change & error akan tercetak
  // di console saat debug mode (lihat AppBlocObserver).
  Bloc.observer = const AppBlocObserver();

  // Whole app is portrait-only. (The Unity AR activity is a separate Android
  // activity — its own orientation is locked in the manifest, not here.)
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(const RsIslamApp());
}

class RsIslamApp extends StatelessWidget {
  const RsIslamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      // Daftarkan semua Cubit/Bloc yang bersifat global (app-level) di sini.
      // Cubit yang bersifat lokal per-layar (WebViewCubit, ArtikelCubit)
      // disediakan langsung di dalam widget layar masing-masing via BlocProvider.
      providers: [
        BlocProvider<NavigationCubit>(
          create: (_) => NavigationCubit(),
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
