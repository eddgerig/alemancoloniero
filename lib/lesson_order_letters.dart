import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'widgets/exit_lesson_dialog.dart';

class LessonOrderLettersPage extends StatefulWidget {
  final String moduleBadge;
  final String title;
  final String subtitle;
  final String? imageUrl;
  final String targetWord;
  final List<String> availableLetters;
  final VoidCallback? onLessonComplete;

  const LessonOrderLettersPage({
    super.key,
    required this.moduleBadge,
    required this.title,
    required this.subtitle,
    this.imageUrl,
    required this.targetWord,
    required this.availableLetters,
    this.onLessonComplete,
  });

  @override
  State<LessonOrderLettersPage> createState() => _LessonOrderLettersPageState();
}

class _LessonOrderLettersPageState extends State<LessonOrderLettersPage> {
  late List<String?> _selectedSlots;
  late List<int?> _slotOriginIndices;
  final AudioPlayer _feedbackPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _selectedSlots = List<String?>.filled(widget.targetWord.length, null);
    _slotOriginIndices = List<int?>.filled(widget.targetWord.length, null);
  }

  @override
  void dispose() {
    _feedbackPlayer.dispose();
    super.dispose();
  }

  Future<void> _playFeedbackSound(bool isCorrect) async {
    try {
      await _feedbackPlayer.stop();
      if (isCorrect) {
        await _feedbackPlayer.play(AssetSource('audio/correct_answer.wav'));
      } else {
        await _feedbackPlayer.play(AssetSource('audio/incorrect_answer.mp3'));
      }
    } catch (e) {
      debugPrint('Error al reproducir audio de feedback: $e');
    }
  }

  void _onLetterTap(int letterIndex) {
    if (_slotOriginIndices.contains(letterIndex)) {
      return;
    }

    final int emptyIndex = _selectedSlots.indexOf(null);
    if (emptyIndex != -1) {
      setState(() {
        _selectedSlots[emptyIndex] = widget.availableLetters[letterIndex];
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
    final bool isCorrect = currentWord.toUpperCase().trim() == widget.targetWord.toUpperCase().trim();

    _playFeedbackSound(isCorrect);

    _showFeedbackSheet(
      isCorrect: isCorrect,
      correctWord: widget.targetWord,
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
                            isCorrect ? 'PALABRA CORRECTA:' : 'RESPUESTA CORRECTA',
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
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    if (widget.onLessonComplete != null) {
                      widget.onLessonComplete!();
                    }
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
                    onPressed: () => showExitLessonDialog(context),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF1B5E20),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                widget.moduleBadge,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Center(
                  child: widget.imageUrl != null && widget.imageUrl!.startsWith('http')
                      ? Image.network(
                          widget.imageUrl!,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Text(
                            widget.imageUrl != null && widget.imageUrl!.length <= 4
                                ? widget.imageUrl!
                                : '☀️',
                            style: const TextStyle(fontSize: 100),
                          ),
                        )
                      : Text(
                          widget.imageUrl != null && widget.imageUrl!.isNotEmpty
                              ? widget.imageUrl!
                              : '☀️',
                          style: const TextStyle(fontSize: 100),
                        ),
                ),
              ),
            ),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(widget.targetWord.length, (index) {
                    final letter = _selectedSlots[index];

                    return GestureDetector(
                      onTap: () => _onSlotTap(index),
                      child: Container(
                        width: 46,
                        height: 52,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
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
                              fontSize: 20,
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Divider(color: Colors.grey.shade400, thickness: 1.5),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: List.generate(widget.availableLetters.length, (i) {
                  final isSelected = _slotOriginIndices.contains(i);
                  final letter = widget.availableLetters[i];

                  return _buildLetterTile(
                    letter: letter,
                    isSelected: isSelected,
                    onTap: () => _onLetterTap(i),
                  );
                }),
              ),
            ),
            const SizedBox(height: 20),
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
        width: 48,
        height: 48,
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
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
        ),
      ),
    );
  }
}
