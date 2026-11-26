import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'services/api_service.dart';
import 'models/user_model.dart';
import 'lesson_runner.dart';
import 'widgets/animated_turtle_button.dart';
import 'widgets/exit_lesson_dialog.dart';
import 'widgets/error_modal.dart';
import 'widgets/loading_screen.dart';

class ModuleIntroPage extends StatefulWidget {
  final int moduloId;

  const ModuleIntroPage({
    super.key,
    this.moduloId = 1,
  });

  @override
  State<ModuleIntroPage> createState() => _ModuleIntroPageState();
}

class _ModuleIntroPageState extends State<ModuleIntroPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _isLoading = true;
  Map<String, dynamic>? _moduleData;
  String? _errorMessage;

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
    _fetchModuleLessons();
  }

  Future<void> _fetchModuleLessons() async {
    final result = await ApiService.getModuleLessons(widget.moduloId);
    
    debugPrint('==================================================');
    debugPrint('CARGA DEL MÓDULO ${widget.moduloId}');
    debugPrint('Respuesta completa: $result');
    debugPrint('==================================================');

    if (mounted) {
      if (result['success'] == true) {
        setState(() {
          _moduleData = result['data'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result['error'] ?? 'Error al cargar módulo';
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playAudio(String? audioUrl, {double speed = 1.0}) async {
    if (audioUrl == null || audioUrl.isEmpty) return;
    try {
      await _audioPlayer.stop();
      await _audioPlayer.setPlaybackRate(speed);
      await _audioPlayer.play(UrlSource(audioUrl));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al reproducir audio: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const LoadingScreen(
        message: 'Cargando lecciones del módulo...',
      );
    }

    if (_errorMessage != null || _moduleData == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded, size: 60, color: Colors.amber),
                  const SizedBox(height: 16),
                  const Text(
                    'No hay contenido disponible',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _errorMessage ?? 'Ocurrió un problema al obtener la lección.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF27AE60),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Volver al Dashboard'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final Map<String, dynamic>? introMap = _moduleData!['introduccion'] is Map<String, dynamic>
        ? _moduleData!['introduccion']
        : null;

    final String moduleTitle = _moduleData!['modulo_titulo'] ?? "MÓDULO ${widget.moduloId}";

    final String introTitle = introMap?['titulo'] ??
        _moduleData!['intro_titulo'] ??
        introMap?['registro_sonoro_nombre'] ??
        _moduleData!['intro_registro_sonoro_nombre'] ??
        moduleTitle.replaceAll('MÓDULO ${widget.moduloId} · ', '');

    final String introText = introMap?['texto'] ??
        _moduleData!['intro_texto'] ??
        "En la Colonia Tovar, el saludo es la muestra más importante de respeto y cercanía. En este módulo aprenderás a presentarte y saludar a la familia coloniera.";

    final String? introImageUrl = introMap?['ilustracion_url'] ??
        _moduleData!['intro_ilustracion_url'];

    final List<dynamic> lecciones = _moduleData!['lecciones'] ?? [];
    final Map<String, dynamic>? firstLesson = lecciones.isNotEmpty ? lecciones.first : null;

    final String audioUrl = introMap?['registro_sonoro_url'] ??
        _moduleData!['intro_registro_sonoro_url'] ??
        firstLesson?['audio_url'] ??
        'https://res.cloudinary.com/dsefkkkp/video/upload/v1794357254/gct_zoba_kaffe.mp4';

    final String voiceBy = introMap?['hablante_nombre'] ??
        _moduleData!['intro_hablante_nombre'] ??
        firstLesson?['voz_hablante'] ??
        '';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header with Module badge & Close button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 32),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B5E20),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      moduleTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 28, color: Color(0xFF2C3E50)),
                    onPressed: () => showExitLessonDialog(context),
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
                    // Title: Registro sonoro nombre or Module name
                    Text(
                      introTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Audio Player Controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () => _playAudio(audioUrl, speed: 1.0),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: _isPlaying ? const Color(0xFF0288D1) : const Color(0xFF29B6F6),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.12),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
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
                          onTap: () => _playAudio(audioUrl, speed: 0.6),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    if (voiceBy.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.mic_none_rounded, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            'Voz: $voiceBy',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],

                    const SizedBox(height: 20),

                    // Intro Illustration Image
                    if (introImageUrl != null && introImageUrl.isNotEmpty) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          introImageUrl,
                          height: 240,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    Text(
                      introText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF34495E),
                        height: 1.5,
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
                  onPressed: () async {
                    await _audioPlayer.stop();
                    if (!mounted) return;

                    final BackendUser user = await ApiService.getMe();
                    final progressResult = await ApiService.startModuleProgress(
                      usuarioId: user.id,
                      moduloId: widget.moduloId,
                      estado: 'en_curso',
                      //intento: 1,
                    );

                    if (progressResult['success'] != true) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(progressResult['error'] ?? 'No se pudo registrar el inicio del módulo'),
                        ),
                      );
                      return;
                    }

                    final Map<String, dynamic> combinedStats = {};
                    if (_moduleData!['estadisticas_cierre'] is Map<String, dynamic>) {
                      combinedStats.addAll(_moduleData!['estadisticas_cierre']);
                    }
                    if (_moduleData!['totales'] is Map<String, dynamic>) {
                      combinedStats.addAll(_moduleData!['totales']);
                    }
                    if (_moduleData!['total_actividades'] != null) {
                      combinedStats['total_actividades'] = _moduleData!['total_actividades'];
                    }
                    if (_moduleData!['total_unidades_lexicas'] != null) {
                      combinedStats['total_unidades_lexicas'] = _moduleData!['total_unidades_lexicas'];
                    }

                    if (lecciones.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LessonRunnerPage(
                            moduloId: widget.moduloId,
                            moduleTitle: moduleTitle,
                            lessons: lecciones,
                            estadisticasCierre: combinedStats,
                            unlockedSpeaker: _moduleData!['hablante_desbloqueable'] is Map<String, dynamic>
                                ? _moduleData!['hablante_desbloqueable']
                                : null,
                          ),
                        ),
                      );
                    } else {
                      _showNoContentModal();
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
    );
  }

  void _showNoContentModal({String? customMessage}) {
    ErrorModal.show(
      context: context,
      title: 'Contenido no disponible',
      message: customMessage ??
          'Aún no hay lecciones disponibles registradas para este módulo en el servidor. Las APIs de este contenido se están implementando.',
      confirmText: 'Entendido',
    );
  }
}
