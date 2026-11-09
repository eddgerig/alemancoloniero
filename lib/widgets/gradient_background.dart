import 'package:flutter/material.dart';

/// App Gradient Constants
class AppGradients {
  static const LinearGradient mainBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFE8F3F8), // Light blue top
      Color(0xFFDCEDDC), // Light green middle
      Color(0xFFA3CFA4), // Soft green bottom
    ],
  );

  static const BoxDecoration mainBackgroundDecoration = BoxDecoration(
    gradient: mainBackgroundGradient,
  );
}

/// A reusable container widget that wraps its child with the main app gradient background.
class GradientBackground extends StatelessWidget {
  final Widget child;

  const GradientBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: AppGradients.mainBackgroundDecoration,
      child: child,
    );
  }
}
