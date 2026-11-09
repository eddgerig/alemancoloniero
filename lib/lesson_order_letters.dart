import 'package:flutter/material.dart';

class LessonOrderLettersPage extends StatefulWidget {
  const LessonOrderLettersPage({super.key});

  @override
  State<LessonOrderLettersPage> createState() => _LessonOrderLettersPageState();
}

class _LessonOrderLettersPageState extends State<LessonOrderLettersPage> {
  final String _targetWord = 'BROT';
  final List<String> _availableLetters = ['O', 'T', 'P', 'R', 'A', 'B', 'S', 'U'];

  final List<String?> _selectedSlots = [null, null, null, null];
  final List<int?> _slotOriginIndices = [null, null, null, null];

  void _onLetterTap(int letterIndex) {
    if (_slotOriginIndices.contains(letterIndex)) {
      // Letter already selected
      return;
    }

    // Find first empty slot
    final int emptyIndex = _selectedSlots.indexOf(null);
    if (emptyIndex != -1) {
      setState(() {
        _selectedSlots[emptyIndex] = _availableLetters[letterIndex];
        _slotOriginIndices[emptyIndex] = letterIndex;
      });
    }
  }

  void _onSlotTap(int slotIndex) {
    if (_selectedSlots[slotIndex] != null) {
      setState(() {
        _selectedSlots[slotIndex] = null;
        _slotOriginIndices[slotIndex] = null;
      });
    }
  }

  void _checkAnswer() {
    final String currentWord = _selectedSlots.map((e) => e ?? '').join('');
    final bool isCorrect = currentWord == _targetWord;

    _showFeedbackSheet(
      isCorrect: isCorrect,
      correctWord: 'Brot',
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
    final bool isAllFilled = !_selectedSlots.contains(null);

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
                        value: 0.66,
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
              'Seleccione y ordene las letras',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Selecciona las letras correctas para formar la palabra',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 16),

            // Image Prominent Center
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Center(
                  child: Image.asset(
                    'assets/images/pan.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Center(
                      child: Text('🍞', style: TextStyle(fontSize: 100)),
                    ),
                  ),
                ),
              ),
            ),

            // Letter Slots (4 empty boxes sitting on a line)
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_targetWord.length, (index) {
                    final letter = _selectedSlots[index];

                    return GestureDetector(
                      onTap: () => _onSlotTap(index),
                      child: Container(
                        width: 52,
                        height: 58,
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: letter != null ? const Color(0xFF27AE60) : Colors.grey.shade400,
                            width: letter != null ? 2.0 : 1.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            letter ?? '',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 10),
                // Horizontal Underline
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Divider(color: Colors.grey.shade400, thickness: 1.5),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Available Letter Tiles Keyboard Grid (2 x 4)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Column(
                children: [
                  // Row 1: O, T, P, R
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(4, (i) {
                      final isSelected = _slotOriginIndices.contains(i);
                      final letter = _availableLetters[i];

                      return _buildLetterTile(
                        letter: letter,
                        isSelected: isSelected,
                        onTap: () => _onLetterTap(i),
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                  // Row 2: A, B, S, U
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(4, (i) {
                      final letterIdx = i + 4;
                      final isSelected = _slotOriginIndices.contains(letterIdx);
                      final letter = _availableLetters[letterIdx];

                      return _buildLetterTile(
                        letter: letter,
                        isSelected: isSelected,
                        onTap: () => _onLetterTap(letterIdx),
                      );
                    }),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Bottom Check Button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: isAllFilled ? _checkAnswer : null,
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

  Widget _buildLetterTile({
    required String letter,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: isSelected ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey.shade200 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.grey.shade300 : Colors.grey.shade400,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Center(
          child: Text(
            isSelected ? '' : letter,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
        ),
      ),
    );
  }
}
