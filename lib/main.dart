import 'package:flutter/material.dart';
import 'welcome_screen.dart';
import 'Signuppage.dart';
import 'Signinpage.dart';// ✅ Import your Sign In screen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // ✅ Set the initial route
      initialRoute: '/',

      // ✅ Define all named routes
      routes: {
        '/': (context) => WelcomeScreen(),   // Your first screen
        '/signin': (context) => SignInScreen(),
        '/signup':(context)=>SignUpScreen(),// Your Sign In screen
        // Add more routes here as needed
      },
    );
  }
}
