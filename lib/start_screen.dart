import 'package:flutter/material.dart';
import 'Signinpage.dart'; // Make sure path is correct
import 'Signuppage.dart';

class StartScreen extends StatefulWidget {
  @override
  _StartScreenState createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _logoAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,

    );

    _slideController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    // Setup animations
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.bounceOut,
    ));

    _logoAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    // Start animations
    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(Duration(milliseconds: 300));
    _fadeController.forward();
    await Future.delayed(Duration(milliseconds: 400));
    _scaleController.forward();
    await Future.delayed(Duration(milliseconds: 200));
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
              Color(0xFF6B73FF),
              Color(0xFF9A9CE6),
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Animated background particles
            ...List.generate(20, (index) => _buildFloatingParticle(index)),

            // Main content
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated Logo
                    AnimatedBuilder(
                      animation: _logoAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _logoAnimation.value * 1.1,
                          child: Transform.rotate(
                            angle: (1 - _logoAnimation.value) * 0.5,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 20,
                                    offset: Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/logo.jpg', // Replace with your actual logo path
                                  height: 140,
                                  width: 140,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: 140,
                                      width: 140,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          colors: [Colors.white, Colors.grey.shade200],
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.flutter_dash,
                                        size: 60,
                                        color: Colors.deepPurple,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: 60),

                    // Welcome text
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Text(
                        'Welcome Back!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 8,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 12),

                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Text(
                        'Sign in to continue your journey',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),

                    SizedBox(height: 50),

                    // Animated Buttons
                    SlideTransition(
                      position: _slideAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Column(
                          children: [
                            // Sign In Button
                            _buildAnimatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, anim1, anim2) => SignInScreen(),
                                    transitionDuration: Duration(milliseconds: 600),
                                    transitionsBuilder: (context, anim1, anim2, child) {
                                      return FadeTransition(
                                        opacity: anim1,
                                        child: SlideTransition(
                                          position: Tween(
                                            begin: Offset(1.0, 0.0),
                                            end: Offset.zero,
                                          ).animate(anim1),
                                          child: child,
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                              text: 'Sign In',
                              isPrimary: true,
                            ),

                            SizedBox(height: 20),

                            // Sign Up Button
                            _buildAnimatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, anim1, anim2) => SignUpScreen(),
                                    transitionDuration: Duration(milliseconds: 600),
                                    transitionsBuilder: (context, anim1, anim2, child) {
                                      return FadeTransition(
                                        opacity: anim1,
                                        child: SlideTransition(
                                          position: Tween(
                                            begin: Offset(-1.0, 0.0),
                                            end: Offset.zero,
                                          ).animate(anim1),
                                          child: child,
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                              text: 'Sign Up',
                              isPrimary: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedButton({
    required VoidCallback onPressed,
    required String text,
    required bool isPrimary,
  }) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(35),
        child: InkWell(
          borderRadius: BorderRadius.circular(35),
          onTap: onPressed,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(35),
              gradient: isPrimary
                  ? LinearGradient(
                colors: [Colors.white, Colors.grey.shade50],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
                  : LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.2),
                  Colors.white.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: isPrimary ? Colors.transparent : Colors.white.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 15,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isPrimary ? Color(0xFF667eea) : Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingParticle(int index) {
    final random = (index * 2654435761) % 4294967296 / 4294967296;
    final size = 3.0 + random * 5;
    final duration = 3000 + (random * 2000).toInt();

    return Positioned(
      left: random * MediaQuery.of(context).size.width,
      top: (random * 0.7) * MediaQuery.of(context).size.height,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: Duration(milliseconds: duration),
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, -value * 100),
            child: Opacity(
              opacity: (1 - value) * 0.6,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.7),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.3),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        onEnd: () {
          if (mounted) {
            setState(() {}); // Restart animation
          }
        },
      ),
    );
  }
}