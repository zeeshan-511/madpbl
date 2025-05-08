import 'package:flutter/material.dart';
import 'Signinpage.dart'; // Make sure path is correct
import 'Signuppage.dart';

class StartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Your App Logo
              Image.asset(
                'assets/logo.jpg', // Replace with your actual logo path
                height: 120,
              ),
              SizedBox(height: 40),

              // Sign In Button
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignInScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 60, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Sign In',
                  style: TextStyle(color: Colors.deepPurple, fontSize: 16),
                ),
              ),
              SizedBox(height: 16),

              // Sign Up Button
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context)=>SignUpScreen()),
                  ); // Optional: define this route
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple.shade100,
                  padding: EdgeInsets.symmetric(horizontal: 60, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Sign Up',
                  style: TextStyle(color: Colors.deepPurple.shade900, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
