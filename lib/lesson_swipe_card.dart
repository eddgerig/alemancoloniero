import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'widgets/animated_turtle_button.dart';
import 'widgets/exit_lesson_dialog.dart';
import 'services/api_service.dart';

class LessonSwipeCardPage extends StatefulWidget {
  final String moduleBadge;
  final String title;
  final String subtitle;
  final String voiceBy;
  final List<dynamic> cardDeck;
  final VoidCallback? onLessonComplete;

  const LessonSwipeCardPage({
    super.key,
    required this.moduleBadge,
    required this.title,
    required this.subtitle,
    this.voiceBy = '',
    required this.cardDeck,
    this.onLessonComplete,
  });

  @override
  State<LessonSwipeCardPage> createState() => _LessonSwipeCardPageState();
}

class _LessonSwipeCardPageState extends State<LessonSwipeCardPage> {
  Offset _cardOffset = Offset.zero;
  bool _isDragging = false;
  int _currentCardIndex = 0;
  bool _isPlaying = false;

  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioPlayer _feedbackPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playCardAudio(speed: 1.0);
    });
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

  Future<void> _playCardAudio({double speed = 1.0}) async {
    if (widget.cardDeck.isEmpty) return;
    final currentCard = widget.cardDeck[_currentCardIndex];
    final String? rawUrl = currentCard['audio_url'];
    final String? fullUrl = ApiService.buildAudioUrl(rawUrl);
    if (fullUrl == null || fullUrl.isEmpty) {
      debugPrint('No hay audio disponible para la tarjeta $_currentCardIndex');
      return;
    }

    try {
      await _audioPlayer.stop();
      await _audioPlayer.setPlaybackRate(speed);
      await _audioPlayer.play(UrlSource(fullUrl));
    } catch (e) {
      debugPrint('Error reproduciendo audio de tarjeta ($fullUrl): $e');
    }
  }

  void _onSwipe(bool swipedLeft) {
    if (widget.cardDeck.isEmpty) return;

    final currentCard = widget.cardDeck[_currentCardIndex];
    final bool cardIsCorrect = (currentCard['es_correcto'] == true);

    // Swiped LEFT (towards ✓ Checkmark side) -> expects cardIsCorrect == true
    // Swiped RIGHT (towards ✕ Cross side) -> expects cardIsCorrect == false
    final bool userWasRight = swipedLeft ? cardIsCorrect : !cardIsCorrect;

    _playFeedbackSound(userWasRight);

    _showFeedbackSheet(
      isCorrect: userWasRight,
      correctWord: (currentCard['titulo'] ?? '').toString(),
    );
  }

  void _advanceToNextCardOrLesson() {
    if (_currentCardIndex < widget.cardDeck.length - 1) {
      setState(() {
        _cardOffset = Offset.zero;
        _currentCardIndex++;
      });
      _playCardAudio(speed: 1.0);
    } else {
      widget.onLessonComplete?.call();
    }
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
                    isCorrect ? '¡Excelente!' : 'Incorrecto',
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
                            isCorrect ? 'TARJETA:' : 'RESPUESTA CORRECTA',
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
                      onTap: () => _playCardAudio(),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          color: Color(0xFF29B6F6),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isPlaying ? Icons.pause_rounded : Icons.volume_up_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
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
                    if (isCorrect) {
                      _advanceToNextCardOrLesson();
                    } else {
                      setState(() {
                        _cardOffset = Offset.zero;
                      });
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
    if (widget.cardDeck.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.info_outline_rounded, size: 60, color: Colors.amber),
                const SizedBox(height: 16),
                const Text('No hay tarjetas registradas para esta lección.'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    widget.onLessonComplete?.call();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF27AE60),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Siguiente Lección'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final currentCard = widget.cardDeck[_currentCardIndex];
    final String titleStr = (currentCard['titulo'] ?? '').toString();
    final String imageStr = (currentCard['imagen_url'] ?? '').toString();
    final double progress = (_currentCardIndex + 1) / widget.cardDeck.length;

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
                        value: progress,
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
                "${widget.moduleBadge} · TARJETA ${_currentCardIndex + 1}/${widget.cardDeck.length}",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  letterSpacing: 0.5,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Title & Subtitle
            Text(
              widget.title,
              textAlign: TextAlign.center,
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

            // Audio Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => _playCardAudio(speed: 1.0),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: _isPlaying ? const Color(0xFF0288D1) : const Color(0xFF29B6F6),
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(
                      _isPlaying ? Icons.graphic_eq_rounded : Icons.volume_up_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                AnimatedTurtleButton(
                  onTap: () => _playCardAudio(speed: 0.6),
                ),
              ],
            ),

            if (widget.voiceBy.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.mic_none_rounded, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'Voz: ${widget.voiceBy}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],

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
                                    child: imageStr.startsWith('http')
                                        ? Image.network(
                                            imageStr,
                                            fit: BoxFit.contain,
                                            errorBuilder: (context, error, stackTrace) => Center(
                                              child: Text(
                                                imageStr.length <= 4 ? imageStr : '🎴',
                                                style: const TextStyle(fontSize: 90),
                                              ),
                                            ),
                                          )
                                        : Center(
                                            child: Text(
                                              imageStr.isNotEmpty ? imageStr : '🎴',
                                              style: const TextStyle(fontSize: 90),
                                            ),
                                          ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    titleStr,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2C3E50),
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
