import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'widgets/animated_turtle_button.dart';
import 'widgets/exit_lesson_dialog.dart';
import 'services/api_service.dart';

class LessonSelectTextPage extends StatefulWidget {
  final String moduleBadge;
  final String title;
  final String subtitle;
  final String? imageUrl;
  final String? audioUrl;
  final String voiceBy;
  final String correctAnswer;
  final List<dynamic> options;
  final VoidCallback? onLessonComplete;
  final void Function(bool isCorrect)? onAnswerChecked;

  const LessonSelectTextPage({
    super.key,
    required this.moduleBadge,
    required this.title,
    required this.subtitle,
    this.imageUrl,
    this.audioUrl,
    this.voiceBy = '',
    required this.correctAnswer,
    required this.options,
    this.onLessonComplete,
    this.onAnswerChecked,
  });

  @override
  State<LessonSelectTextPage> createState() => _LessonSelectTextPageState();
}

class _LessonSelectTextPageState extends State<LessonSelectTextPage> {
  int? _selectedIndex;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioPlayer _cardAudioPlayer = AudioPlayer();
  final AudioPlayer _feedbackPlayer = AudioPlayer();
  bool _isPlaying = false;

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
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _cardAudioPlayer.dispose();
    _feedbackPlayer.dispose();
    super.dispose();
  }

  Future<void> _playMainAudio({double speed = 1.0}) async {
    final url = ApiService.buildAudioUrl(widget.audioUrl);
    if (url == null || url.isEmpty) return;
    try {
      await _cardAudioPlayer.stop();
      await _audioPlayer.stop();
      await _audioPlayer.setPlaybackRate(speed);
      await _audioPlayer.play(UrlSource(url));
    } catch (e) {
      debugPrint('Error al reproducir audio principal: $e');
    }
  }

  Future<void> _playOptionAudio(String? rawOptionUrl) async {
    final optionUrl = ApiService.buildAudioUrl(rawOptionUrl);
    if (optionUrl == null || optionUrl.isEmpty) return;
    try {
      await _audioPlayer.stop();
      await _cardAudioPlayer.stop();
      await _cardAudioPlayer.play(UrlSource(optionUrl));
    } catch (e) {
      debugPrint('Error al reproducir audio de opción: $e');
    }
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

  void _checkAnswer() {
    if (_selectedIndex == null || widget.options.isEmpty) return;

    final selectedOption = widget.options[_selectedIndex!];
    final String selectedTitle = selectedOption is Map
        ? (selectedOption['texto'] ?? selectedOption['titulo'] ?? selectedOption['title'] ?? '').toString()
        : selectedOption.toString();

    final bool isCorrect = selectedTitle.toLowerCase().trim() == widget.correctAnswer.toLowerCase().trim();

    _playFeedbackSound(isCorrect);

    _showFeedbackSheet(
      isCorrect: isCorrect,
      correctWord: widget.correctAnswer,
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
    final bool hasAudio = widget.audioUrl != null && widget.audioUrl!.isNotEmpty;
    final bool hasImage = widget.imageUrl != null && widget.imageUrl!.isNotEmpty;

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

            const SizedBox(height: 16),

            // Title & Subtitle
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

            // Main Audio Section (Speaker & Animated Turtle)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => _playMainAudio(speed: 1.0),
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
                  onTap: () => _playMainAudio(speed: 0.6),
                ),
              ],
            ),
            if (widget.voiceBy.isNotEmpty) ...[
              const SizedBox(height: 8),
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
            const SizedBox(height: 16),

            // Stacked Text Options List
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: ListView.separated(
                  itemCount: widget.options.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final option = widget.options[index];
                    final String optionText = option is Map
                        ? (option['texto'] ?? option['titulo'] ?? option['title'] ?? '').toString()
                        : option.toString();
                    final String? optionAudio = option is Map ? option['audio_url'] : null;
                    final isSelected = _selectedIndex == index;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedIndex = index;
                        });
                        if (optionAudio != null && optionAudio.isNotEmpty) {
                          _playOptionAudio(optionAudio);
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        height: 54,
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
                                  ? const Color(0xFF27AE60).withOpacity(0.1)
                                  : Colors.black.withOpacity(0.02),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            optionText,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
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
