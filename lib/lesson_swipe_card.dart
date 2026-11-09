import 'package:flutter/material.dart';
import 'widgets/white_turtle_icon.dart';

class LessonSwipeCardPage extends StatefulWidget {
  const LessonSwipeCardPage({super.key});

  @override
  State<LessonSwipeCardPage> createState() => _LessonSwipeCardPageState();
}

class _LessonSwipeCardPageState extends State<LessonSwipeCardPage> {
  Offset _cardOffset = Offset.zero;
  bool _isDragging = false;

  final List<Map<String, String>> _cards = [
    {'title': 'Pan', 'image': 'assets/images/pan.png', 'emoji': '🍞'},
    {'title': 'Café', 'image': 'assets/images/cafe.png', 'emoji': '☕'},
    {'title': 'Queso', 'image': 'assets/images/queso.png', 'emoji': '🧀'},
    {'title': 'Leche', 'image': 'assets/images/leche.png', 'emoji': '🥛'},
  ];

  int _currentCardIndex = 0;

  void _onSwipe(bool isCorrectChoice) {
    // Show feedback modal sheet based on swipe direction
    _showFeedbackSheet(
      isCorrect: isCorrectChoice,
      correctWord: _cards[_currentCardIndex]['title']!,
    );
  }

  void _nextCard() {
    setState(() {
      _cardOffset = Offset.zero;
      _currentCardIndex = (_currentCardIndex + 1) % _cards.length;
    });
  }

  void _showFeedbackSheet({required bool isCorrect, required String correctWord}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24.0),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 20,
                offset: Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Status (Correct vs Incorrect)
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isCorrect ? const Color(0xFF1B5E20) : const Color(0xFFD35400),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isCorrect ? Icons.check_rounded : Icons.close_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isCorrect ? 'Correcto' : 'Incorrecto',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isCorrect ? const Color(0xFF1B5E20) : const Color(0xFFD35400),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Option/Response Card
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: isCorrect ? const Color(0xFFF8F9FA) : const Color(0xFFD4EFDF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isCorrect ? Colors.grey.shade200 : const Color(0xFFA2D9CE),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isCorrect ? 'OPCIÓN CORRECTA:' : 'RESPUESTA CORRECTA',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isCorrect ? Colors.grey.shade600 : const Color(0xFF1E8449),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            correctWord,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Blue Audio Speaker Button
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          color: Color(0xFF29B6F6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.volume_up_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              if (!isCorrect) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBFBF9),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        color: Colors.grey.shade600,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Volverás a ver esta palabra al final de la lección.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Continuar Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _nextCard();
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
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentCard = _cards[_currentCardIndex];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top Progress Bar & Close Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: 0.5,
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
              'Desliza la imagen hacia el lado\ncorrecto',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'escucha el audio y desliza la imagen',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 16),

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
                    child: const Center(
                      child: WhiteTurtleIcon(size: 20, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.mic_none_rounded, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Text(
                  'Voz: Hans Ruh',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Swipe Directions Header (Checkmark ✓  Dotted Line  Cross ✕)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left: Checkmark (Correct)
                  const Icon(
                    Icons.check_rounded,
                    color: Color(0xFF2E7D32),
                    size: 36,
                  ),

                  // Center Dotted Line Top
                  SizedBox(
                    height: 24,
                    width: 2,
                    child: CustomPaint(
                      painter: _DottedLinePainter(),
                    ),
                  ),

                  // Right: Cross (Incorrect)
                  const Icon(
                    Icons.close_rounded,
                    color: Color(0xFFD32F2F),
                    size: 36,
                  ),
                ],
              ),
            ),

            // Swappable Flashcard Area
            Expanded(
              child: Center(
                child: SizedBox(
                  width: 280,
                  height: 330,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Stack Card 3 (Backmost)
                      Positioned(
                        top: 0,
                        child: Container(
                          width: 240,
                          height: 300,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.grey.shade400, width: 1.5),
                          ),
                        ),
                      ),

                      // Stack Card 2 (Middle)
                      Positioned(
                        top: 10,
                        child: Container(
                          width: 260,
                          height: 300,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.grey.shade300, width: 1.5),
                          ),
                        ),
                      ),

                      // Front Interactive Swipable Card (Top)
                      Positioned(
                        top: 20,
                        child: GestureDetector(
                          onPanStart: (_) {
                            setState(() {
                              _isDragging = true;
                            });
                          },
                          onPanUpdate: (details) {
                            setState(() {
                              _cardOffset += details.delta;
                            });
                          },
                          onPanEnd: (details) {
                            setState(() {
                              _isDragging = false;
                            });
                            if (_cardOffset.dx < -80) {
                              // Swiped Left (Towards ✓ Correct)
                              _onSwipe(true);
                            } else if (_cardOffset.dx > 80) {
                              // Swiped Right (Towards ✕ Incorrect)
                              _onSwipe(false);
                            } else {
                              // Reset position
                              setState(() {
                                _cardOffset = Offset.zero;
                              });
                            }
                          },
                          child: AnimatedContainer(
                            duration: _isDragging ? Duration.zero : const Duration(milliseconds: 200),
                            transform: Matrix4.translationValues(_cardOffset.dx, _cardOffset.dy, 0)
                              ..rotateZ(_cardOffset.dx / 1000),
                            width: 270,
                            height: 300,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.grey.shade300, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Image.asset(
                                      currentCard['image']!,
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) => Center(
                                        child: Text(
                                          currentCard['emoji']!,
                                          style: const TextStyle(fontSize: 90),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Center Dotted Line Indicator
            SizedBox(
              height: 24,
              width: 2,
              child: CustomPaint(
                painter: _DottedLinePainter(),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

/// Helper Painter to draw vertical dotted line
class _DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade500
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    double startY = 0;
    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + 4), paint);
      startY += 8;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
