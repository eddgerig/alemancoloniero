import 'package:flutter/material.dart';
import 'widgets/gradient_background.dart';
import 'lesson_question.dart';

class ModuleIntroPage extends StatelessWidget {
  const ModuleIntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header with Module badge & Close button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 32), // Spacer for centering
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B5E20),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'MÓDULO 2',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 28, color: Color(0xFF2C3E50)),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      // Title
                      const Text(
                        "Z'Oowa Kaffe",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Audio Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Speaker Button
                          GestureDetector(
                            onTap: () {},
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: const BoxDecoration(
                                color: Color(0xFF29B6F6),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 6,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.volume_up_rounded,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Turtle Button
                          GestureDetector(
                            onTap: () {},
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: const BoxDecoration(
                                color: Color(0xFF29B6F6),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.pets_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Voice Attribution
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.mic_none_rounded, size: 16, color: Colors.grey),
                          SizedBox(width: 4),
                          Text(
                            'Voz: Yolanda Fehr',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Intro Illustration Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          'assets/images/zoowa_kaffe_intro.png',
                          height: 240,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 200,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.amber.shade50,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.amber.shade200),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('☕🥖🍰', style: TextStyle(fontSize: 60)),
                                SizedBox(height: 8),
                                Text(
                                  'assets/images/zoowa_kaffe_intro.png',
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Description Text
                      RichText(
                        textAlign: TextAlign.center,
                        text: const TextSpan(
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF34495E),
                            height: 1.5,
                          ),
                          children: [
                            TextSpan(
                              text:
                                  'El café de la tarde, la merienda que reúne a la familia coloniera alrededor de la mesa. Se sirve café con leche y se acompaña con pan, mantequilla y postres de la casa. Su nombre viene de ',
                            ),
                            TextSpan(
                              text: 'oowa',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
                            ),
                            TextSpan(
                              text: ', que significa "tarde".',
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // Bottom Button "Empezar"
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LessonQuestionPage()),
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
                      'Empezar',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
