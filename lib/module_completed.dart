import 'package:flutter/material.dart';
import 'widgets/gradient_background.dart';
import 'speaker_card_unlock.dart';
import 'dashboard.dart';

class ModuleCompletedPage extends StatelessWidget {
  final String moduleTitle;
  final int wordsWorked;
  final int completedLessons;
  final String nextModuleName;

  const ModuleCompletedPage({
    super.key,
    this.moduleTitle = "Z'Oowa Kaffe",
    this.wordsWorked = 34,
    this.completedLessons = 5,
    this.nextModuleName = 'Módulo 3: Famili',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Top Subtitle
                const Text(
                  'Módulo Completado',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),

                const SizedBox(height: 10),

                // Module Title
                Text(
                  moduleTitle,
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1B5E20),
                    fontFamily: 'Serif',
                  ),
                ),

                const SizedBox(height: 16),

                // Mascot holding "Guad" sign
                SizedBox(
                  height: 200,
                  child: Image.asset(
                    'assets/images/mascot_guad.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Image.asset(
                      'assets/images/mascot.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Center(
                        child: Text('🦔', style: TextStyle(fontSize: 110)),
                      ),
                    ),
                  ),
                ),

                const Spacer(),

                // Two Stat Cards (Side by Side)
                Row(
                  children: [
                    // Card 1: Palabras Trabajadas
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 15,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              '$wordsWorked',
                              style: const TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.w900,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Palabras\nTrabajadas',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1B5E20),
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Card 2: Lecciones
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 15,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              '$completedLessons',
                              style: const TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.w900,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Lecciones',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1B5E20),
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Next Unlocked Module Pill Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9).withOpacity(0.85),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFA5D6A7), width: 1.2),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.lock_outline_rounded,
                        color: Color(0xFF1B5E20),
                        size: 24,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        nextModuleName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Bottom Continuar Button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SpeakerCardUnlockPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF27AE60),
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: const Color(0xFF1E8449).withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Continuar',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
