import 'package:flutter/material.dart';
import 'screens/auth.dart';
import 'theme.dart';

void main() => runApp(const GoldMetalApp());

class GoldMetalApp extends StatelessWidget {
  const GoldMetalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeMode,
      builder: (_, mode, __) => MaterialApp(
        title: 'GoldMetal App',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(Brightness.light),
        darkTheme: buildTheme(Brightness.dark),
        themeMode: mode,
        home: const LoginScreen(),
      ),
    );
  }
}
