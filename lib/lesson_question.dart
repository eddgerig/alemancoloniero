import 'package:flutter/material.dart';
import 'widgets/gradient_background.dart';

class LessonQuestionPage extends StatefulWidget {
  const LessonQuestionPage({super.key});

  @override
  State<LessonQuestionPage> createState() => _LessonQuestionPageState();
}

class _LessonQuestionPageState extends State<LessonQuestionPage> {
  int? _selectedIndex = 0; // Default selecting 'Pan' as in screenshot

  final List<Map<String, String>> _options = [
    {'title': 'Pan', 'image': 'assets/images/pan.png', 'emoji': '🍞'},
    {'title': 'Café', 'image': 'assets/images/cafe.png', 'emoji': '☕'},
    {'title': 'Queso', 'image': 'assets/images/queso.png', 'emoji': '🧀'},
    {'title': 'Leche', 'image': 'assets/images/leche.png', 'emoji': '🥛'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Top Progress Bar & Close button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: 0.2,
                          minHeight: 10,
                          backgroundColor: Colors.grey.shade300,
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF29B6F6)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 28, color: Color(0xFF2C3E50)),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Module Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B5E20),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "MÓDULO 2 · Z'OOWA KAFFE",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    letterSpacing: 0.5,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Title & Subtitle
              const Text(
                'Selecciona la imagen correcta',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'escucha el audio y selecciona la opción correcta',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 20),

              // Audio Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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

              const SizedBox(height: 24),

              // 2x2 Grid of Option Cards
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: GridView.builder(
                    itemCount: _options.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.95,
                    ),
                    itemBuilder: (context, index) {
                      final option = _options[index];
                      final isSelected = _selectedIndex == index;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedIndex = index;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF27AE60) : Colors.grey.shade300,
                              width: isSelected ? 3.5 : 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isSelected
                                    ? const Color(0xFF27AE60).withOpacity(0.15)
                                    : Colors.black.withOpacity(0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Image.asset(
                                    option['image']!,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) => Center(
                                      child: Text(
                                        option['emoji']!,
                                        style: const TextStyle(fontSize: 60),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Text(
                                option['title']!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2C3E50),
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Bottom Check Button
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _selectedIndex == null
                        ? null
                        : () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('¡Respuesta comprobada!'),
                                backgroundColor: Color(0xFF27AE60),
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
                      'Comprobar',
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
