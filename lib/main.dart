import 'package:flutter/material.dart';
import 'package:rs_islam_app/core/theme/app_theme.dart';
import 'package:rs_islam_app/features/home/presentation/screens/home_screen.dart';

void main() {
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
