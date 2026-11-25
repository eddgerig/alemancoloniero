import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'widgets/exit_lesson_dialog.dart';

class LessonMatchTextPairsPage extends StatefulWidget {
  final String moduleBadge;
  final String title;
  final String subtitle;
  final List<dynamic> pairs;
  final VoidCallback? onLessonComplete;
  final void Function(bool isCorrect)? onAnswerChecked;

  const LessonMatchTextPairsPage({
    super.key,
    required this.moduleBadge,
    required this.title,
    required this.subtitle,
    required this.pairs,
    this.onLessonComplete,
    this.onAnswerChecked,
  });

  @override
  State<LessonMatchTextPairsPage> createState() => _LessonMatchTextPairsPageState();
}

class _LessonMatchTextPairsPageState extends State<LessonMatchTextPairsPage> {
  int? _selectedLeftIndex;
  int? _selectedRightIndex;
  final Set<int> _matchedLeftIndices = {};
  final Set<int> _matchedRightIndices = {};

  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioPlayer _feedbackPlayer = AudioPlayer();

  late List<Map<String, dynamic>> _leftItems;
  late List<Map<String, dynamic>> _rightItems;

  @override
  void initState() {
    super.initState();
    _leftItems = [];
    _rightItems = [];

    for (int i = 0; i < widget.pairs.length; i++) {
      final pair = widget.pairs[i];
      final String? audioA = (pair['audio_url_a'] != null && pair['audio_url_a'].toString().isNotEmpty)
          ? pair['audio_url_a'].toString()
          : pair['audio_url']?.toString();

      final String? audioB = (pair['audio_url_b'] != null && pair['audio_url_b'].toString().isNotEmpty)
          ? pair['audio_url_b'].toString()
          : pair['audio_url']?.toString();

      _leftItems.add({
        'pair_id': pair['id'] ?? i,
        'index': i,
        'text': (pair['texto_a'] ?? '').toString(),
        'audio_url': audioA,
      });
      _rightItems.add({
        'pair_id': pair['id'] ?? i,
        'index': i,
        'text': (pair['texto_b'] ?? '').toString(),
        'audio_url': audioB,
      });
    }

    // Shuffle right items so they aren't directly across from their match
    _rightItems.shuffle();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
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

  Future<void> _playAudio(String? url) async {
    if (url == null || url.isEmpty) return;
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(UrlSource(url));
    } catch (e) {
      debugPrint('Error reproduciendo audio de pareja: $e');
    }
  }

  void _onLeftTap(int index) {
    if (_matchedLeftIndices.contains(index)) return;
    final item = _leftItems[index];
    final String? audioUrl = item['audio_url'];
    if (audioUrl != null && audioUrl.isNotEmpty) {
      _playAudio(audioUrl);
    }
    setState(() {
      _selectedLeftIndex = index;
    });
    _tryMatch();
  }

  void _onRightTap(int index) {
    if (_matchedRightIndices.contains(index)) return;
    final item = _rightItems[index];
    final String? audioUrl = item['audio_url'];
    if (audioUrl != null && audioUrl.isNotEmpty) {
      _playAudio(audioUrl);
    }
    setState(() {
      _selectedRightIndex = index;
    });
    _tryMatch();
  }

  void _tryMatch() {
    if (_selectedLeftIndex == null || _selectedRightIndex == null) return;

    final leftItem = _leftItems[_selectedLeftIndex!];
    final rightItem = _rightItems[_selectedRightIndex!];

    final bool isMatch = leftItem['pair_id'] == rightItem['pair_id'];

    if (isMatch) {
      _playFeedbackSound(true);
      if (leftItem['audio_url'] != null) {
        _playAudio(leftItem['audio_url']);
      }
      setState(() {
        _matchedLeftIndices.add(_selectedLeftIndex!);
        _matchedRightIndices.add(_selectedRightIndex!);
        _selectedLeftIndex = null;
        _selectedRightIndex = null;
      });
    } else {
      _playFeedbackSound(false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Las palabras no coinciden, ¡intenta de nuevo!'),
          duration: Duration(seconds: 1),
        ),
      );
      setState(() {
        _selectedLeftIndex = null;
        _selectedRightIndex = null;
      });
    }
  }

  void _showFeedbackSheet({required bool isCorrect}) {
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
                    decoration: const BoxDecoration(
                      color: Color(0xFF1B5E20),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    '¡Excelente!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B5E20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '¡Has conectado correctamente todas las parejas!',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade700,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onAnswerChecked?.call(isCorrect);
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
                    onPressed: () => showExitLessonDialog(context),
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

            const SizedBox(height: 12),

            // Title & Subtitle
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              widget.subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 16),

            // Matching Area (Left Column: Texto A | Center: Dotted Line | Right Column: Texto B)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    // Left Column (Texto A)
                    Expanded(
                      flex: 5,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(_leftItems.length, (index) {
                          final item = _leftItems[index];
                          final isSelected = _selectedLeftIndex == index;
                          final isMatched = _matchedLeftIndices.contains(index);

                          return GestureDetector(
                            onTap: () => _onLeftTap(index),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              height: 60,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: isMatched
                                    ? const Color(0xFFE8F5E9)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isMatched
                                      ? const Color(0xFF27AE60)
                                      : (isSelected ? const Color(0xFF29B6F6) : Colors.grey.shade300),
                                  width: (isSelected || isMatched) ? 3.0 : 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: isSelected
                                        ? const Color(0xFF29B6F6).withOpacity(0.15)
                                        : Colors.black.withOpacity(0.03),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (isMatched) ...[
                                    const Icon(Icons.check_circle_rounded, color: Color(0xFF27AE60), size: 20),
                                    const SizedBox(width: 8),
                                  ],
                                  Text(
                                    item['text'],
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: isMatched ? const Color(0xFF1B5E20) : const Color(0xFF2C3E50),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ),

                    // Center Dotted Vertical Line
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: CustomPaint(
                        size: const Size(2, double.infinity),
                        painter: _DottedVerticalLinePainter(),
                      ),
                    ),

                    // Right Column (Texto B)
                    Expanded(
                      flex: 5,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(_rightItems.length, (index) {
                          final item = _rightItems[index];
                          final isSelected = _selectedRightIndex == index;
                          final isMatched = _matchedRightIndices.contains(index);

                          return GestureDetector(
                            onTap: () => _onRightTap(index),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              height: 60,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: isMatched
                                    ? const Color(0xFFE8F5E9)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isMatched
                                      ? const Color(0xFF27AE60)
                                      : (isSelected ? const Color(0xFF29B6F6) : Colors.grey.shade300),
                                  width: (isSelected || isMatched) ? 3.0 : 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: isSelected
                                        ? const Color(0xFF29B6F6).withOpacity(0.15)
                                        : Colors.black.withOpacity(0.03),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (isMatched) ...[
                                    const Icon(Icons.check_circle_rounded, color: Color(0xFF27AE60), size: 20),
                                    const SizedBox(width: 8),
                                  ],
                                  Text(
                                    item['text'],
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: isMatched ? const Color(0xFF1B5E20) : const Color(0xFF2C3E50),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

/// Helper Painter to draw center vertical dotted line
class _DottedVerticalLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    double startY = 0;
    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + 5), paint);
      startY += 10;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
