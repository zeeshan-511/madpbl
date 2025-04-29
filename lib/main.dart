import 'package:flutter/material.dart';
import 'welcome_screen.dart'; // First screen on launch

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WelcomeScreen(), // ✅ Start from WelcomeScreen
    );
  }
}
