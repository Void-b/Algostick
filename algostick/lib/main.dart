import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const AlgoStickApp());
}

class AlgoStickApp extends StatelessWidget {
  const AlgoStickApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AlgoStick',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          foregroundColor: Colors.white,
        ),
        cardTheme: CardTheme(
          color: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}