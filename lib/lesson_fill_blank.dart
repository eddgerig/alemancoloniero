import 'package:flutter/material.dart';
import 'widgets/white_turtle_icon.dart';

class LessonFillBlankPage extends StatefulWidget {
  const LessonFillBlankPage({super.key});

  @override
  State<LessonFillBlankPage> createState() => _LessonFillBlankPageState();
}

class _LessonFillBlankPageState extends State<LessonFillBlankPage> {
  int? _selectedIndex;

  final List<String> _options = ['Tes', 'Tr', 'T'];
  final String _sentenceSuffix = 'Brot mit kaffe';
  final String _correctWord = 'Tes';

  void _checkAnswer() {
    if (_selectedIndex == null) return;

    final String selectedWord = _options[_selectedIndex!];
    final bool isCorrect = selectedWord == _correctWord;

    _showFeedbackSheet(
      isCorrect: isCorrect,
      correctWord: 'Tes Brot mit kaffe',
    );
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
    final String selectedWordText = _selectedIndex != null ? _options[_selectedIndex!] : '__________';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
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
                        value: 0.33,
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
              'Selecciona la opción correcta',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'escucha el audio y selecciona la palabra correctas',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 24),

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

            const Spacer(),

            // Fill In The Blank Sentence Display
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  // Blank Line or Selected Option
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: _selectedIndex != null ? const Color(0xFF27AE60) : Colors.grey.shade600,
                          width: 2.5,
                        ),
                      ),
                    ),
                    child: Text(
                      selectedWordText,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: _selectedIndex != null ? const Color(0xFF27AE60) : Colors.transparent,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Sentence Suffix
                  Text(
                    _sentenceSuffix,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Word Tile Option Buttons (Horizontal Row)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(_options.length, (index) {
                  final optionText = _options[index];
                  final isSelected = _selectedIndex == index;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF27AE60) : Colors.grey.shade400,
                          width: isSelected ? 2.5 : 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isSelected
                                ? const Color(0xFF27AE60).withOpacity(0.12)
                                : Colors.black.withOpacity(0.03),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Text(
                        optionText,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 30),

            // Bottom Check Button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _selectedIndex == null ? null : _checkAnswer,
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
    );
  }
}
