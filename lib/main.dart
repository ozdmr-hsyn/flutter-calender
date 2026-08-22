import 'package:flutter/material.dart';

import 'screens/takvim_home_screen.dart';

void main() {
  runApp(const TakvimApp());
}

class TakvimApp extends StatefulWidget {
  const TakvimApp({super.key});

  @override
  State<TakvimApp> createState() => _TakvimAppState();
}

class _TakvimAppState extends State<TakvimApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Döngüsel Takvim',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
      ),
      home: TakvimHomeScreen(onThemeToggle: _toggleTheme),
    );
  }
}