import 'package:flutter/material.dart';
import 'screens/home/home_screen.dart';

void main() {
  runApp(const AicoApp());
}

class AicoApp extends StatelessWidget {
  const AicoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '에코 (ai-coach)',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF6F1F1),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFA31621),
        ),
      ),
      home: HomeScreen(userName: '테스트', token: null),
    );
  }
}
