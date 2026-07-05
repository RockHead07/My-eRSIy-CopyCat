import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rs_islam_app/core/theme/app_theme.dart';
import 'package:rs_islam_app/features/home/presentation/screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Whole app is portrait-only. (The Unity AR activity is a separate Android
  // activity — its own orientation is locked in the manifest, not here.)
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const RsIslamApp());
}

class RsIslamApp extends StatelessWidget {
  const RsIslamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RS Islam Surabaya',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const HomeScreen(),
    );
  }
}
