import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:madpbl/home_screen.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'welcome_screen.dart';
import 'Signuppage.dart';
import 'Signinpage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) =>  WelcomeScreen(),
        '/signin': (context) =>  SignInScreen(),
        '/signup': (context) =>  SignUpScreen(),
        '/home'  :(context) => HomeScreen(),
      },
    );
  }
}
