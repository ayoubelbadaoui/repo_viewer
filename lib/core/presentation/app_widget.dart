import 'package:flutter/material.dart';
import 'package:reso_coder/splash/presentation/splash_page.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Repo Viewer',
      home: SplashPage(),
    );
  }
}
