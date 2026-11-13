import 'dart:async';
import 'package:flutter/material.dart';
import 'login.dart';
import 'widgets/gradient_background.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _book1Animation;
  late Animation<double> _book2Animation;
  late Animation<double> _book3TiltingAnimation;
  late Animation<double> _textFadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 2800),
      vsync: this,
    );

    // Book 1 (Black) rises first
    _book1Animation = Tween<double>(begin: 40, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOutBack),
      ),
    );

    // Book 2 (Yellow) rises second
    _book2Animation = Tween<double>(begin: 40, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.6, curve: Curves.easeOutBack),
      ),
    );

    // Book 3 (Red) tilts to the right (like in the illustration)
    _book3TiltingAnimation = Tween<double>(begin: 0, end: 0.28).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.85, curve: Curves.bounceOut),
      ),
    );

    // App Title Text fades in
    _textFadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.forward();

    // Navigate smoothly to Login after 5 seconds
    Timer(const Duration(seconds: 5), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 600),
            pageBuilder: (context, animation, secondaryAnimation) => const LoginPage(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Animated Books Container
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Column(
                    children: [
                      SizedBox(
                        height: 160,
                        width: 220,
                        child: Stack(
                          alignment: Alignment.bottomLeft,
                          children: [
                            // Book 1: Black
                            Positioned(
                              left: 20,
                              bottom: -_book1Animation.value,
                              child: _buildBook(
                                color: Colors.black,
                                height: 130,
                                width: 42,
                              ),
                            ),

                            // Book 2: Yellow
                            Positioned(
                              left: 70,
                              bottom: -_book2Animation.value,
                              child: _buildBook(
                                color: const Color(0xFFFFCC00),
                                height: 130,
                                width: 42,
                              ),
                            ),

                            // Book 3: Red (Tilting to right)
                            Positioned(
                              left: 122,
                              bottom: 0,
                              child: Transform(
                                transform: Matrix4.identity()
                                  ..rotateZ(_book3TiltingAnimation.value),
                                alignment: Alignment.bottomLeft,
                                child: _buildBook(
                                  color: const Color(0xFFDD0000),
                                  height: 130,
                                  width: 42,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Shelf Base Line
                      Container(
                        width: 240,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 36),

              // Fading App Title & Subtitle
              AnimatedBuilder(
                animation: _textFadeAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _textFadeAnimation.value,
                    child: Column(
                      children: [
                        const Text(
                          'Alemán Coloniero',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'SprochKanschtrli',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const Spacer(),

              // Bottom Loading Indicator
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Color(0xFF27AE60),
                  strokeWidth: 2.5,
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBook({required Color color, required double height, required double width}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
    );
  }
}
