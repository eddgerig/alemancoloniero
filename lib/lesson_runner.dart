import 'package:flutter/material.dart';
import 'lesson_question.dart';
import 'cognitive_pause.dart';
import 'lesson_order_letters.dart';
import 'lesson_select_text.dart';
import 'lesson_match_text_pairs.dart';
import 'lesson_swipe_card.dart';
import 'lesson_fill_blank.dart';
import 'module_completed.dart';
import 'services/api_service.dart';

/// Runner that manages the sequential flow through all lessons in a module
class LessonRunnerPage extends StatefulWidget {
  final int moduloId;
  final String moduleTitle;
  final List<dynamic> lessons;
  final Map<String, dynamic>? estadisticasCierre;
  final Map<String, dynamic>? unlockedSpeaker;

  const LessonRunnerPage({
    super.key,
    required this.moduloId,
    required this.moduleTitle,
    required this.lessons,
    this.estadisticasCierre,
    this.unlockedSpeaker,
  });

  @override
  State<LessonRunnerPage> createState() => _LessonRunnerPageState();
}

class _LessonRunnerPageState extends State<LessonRunnerPage> {
  int _currentIndex = 0;
  int _correctAnswersCount = 0;
  int _incorrectAnswersCount = 0;

  void _registerAnswer(bool isCorrect) {
    setState(() {
      if (isCorrect) {
        _correctAnswersCount++;
      } else {
        _incorrectAnswersCount++;
      }
    });
  }

  Future<void> _nextLesson() async {
    if (_currentIndex + 1 < widget.lessons.length) {
      setState(() {
        _currentIndex++;
      });
    } else {
      final Map<String, dynamic>? stats = widget.estadisticasCierre;

      int wordsWorked = 0;
      if (stats != null) {
        if (stats['palabras_trabajadas'] is int && stats['palabras_trabajadas'] > 0) {
          wordsWorked = stats['palabras_trabajadas'];
        } else if (stats['unidades_lexicas'] is int && stats['unidades_lexicas'] > 0) {
          wordsWorked = stats['unidades_lexicas'];
        } else if (stats['total_unidades_lexicas'] is int && stats['total_unidades_lexicas'] > 0) {
          wordsWorked = stats['total_unidades_lexicas'];
        }
      }
      if (wordsWorked == 0) {
        wordsWorked = widget.lessons.length * 2;
      }

      int completedLessons = 0;
      if (stats != null) {
        if (stats['actividades'] is int && stats['actividades'] > 0) {
          completedLessons = stats['actividades'];
        } else if (stats['total_actividades'] is int && stats['total_actividades'] > 0) {
          completedLessons = stats['total_actividades'];
        } else if (stats['lecciones_completadas'] is int && stats['lecciones_completadas'] > 0) {
          completedLessons = stats['lecciones_completadas'];
        } else if (stats['lecciones'] is int && stats['lecciones'] > 0) {
          completedLessons = stats['lecciones'];
        }
      }
      if (completedLessons == 0) {
        completedLessons = widget.lessons.length;
      }

      final String? nextModule = stats?['siguiente_modulo'];

      // Calculate approval percentage in frontend
      final int totalAttempts = _correctAnswersCount + _incorrectAnswersCount;
      final int totalActivities = totalAttempts > 0 ? totalAttempts : completedLessons;
      final double porcentajeAcierto = totalActivities > 0
          ? (_correctAnswersCount / totalActivities) * 100
          : 100.0;
      final bool esAprobado = porcentajeAcierto >= 70.0;

      debugPrint('==================================================');
      debugPrint('CÁLCULO DE PORCENTAJE DE APROBACIÓN DE MÓDULO:');
      debugPrint('- Módulo: ${widget.moduleTitle}');
      debugPrint('- Respuestas Correctas: $_correctAnswersCount');
      debugPrint('- Respuestas Incorrectas: $_incorrectAnswersCount');
      debugPrint('- Total Actividades Evaluadas: $totalActivities');
      debugPrint('- Porcentaje de Acierto: ${porcentajeAcierto.toStringAsFixed(1)}%');
      debugPrint('- Estado: ${esAprobado ? "APROBADO (>= 70%)" : "NO APROBADO (< 70%)"}');
      debugPrint('==================================================');

      if (esAprobado) {
        final user = await ApiService.getMe();
        final progressResult = await ApiService.startModuleProgress(
          usuarioId: user.id,
          moduloId: widget.moduloId,
          estado: 'completado',
        );

        if (progressResult['success'] == true) {
          debugPrint('Progreso del módulo actualizado a completado.');
        } else {
          debugPrint(
            'No se pudo actualizar el progreso: ${progressResult['error']}',
          );
        }
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ModuleCompletedPage(
            moduleTitle: widget.moduleTitle,
            wordsWorked: wordsWorked,
            completedLessons: completedLessons,
            correctAnswers: _correctAnswersCount > 0 ? _correctAnswersCount : completedLessons,
            incorrectAnswers: _incorrectAnswersCount,
            nextModuleName: nextModule,
            unlockedSpeaker: widget.unlockedSpeaker,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.lessons.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.info_outline_rounded, size: 60, color: Colors.amber),
              const SizedBox(height: 16),
              const Text('No hay lecciones registradas para este módulo.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF27AE60),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Volver al Dashboard'),
              ),
            ],
          ),
        ),
      );
    }

    final Map<String, dynamic> currentLesson =
        Map<String, dynamic>.from(widget.lessons[_currentIndex]);
    final String lessonType = (currentLesson['tipo'] ?? '').toString();

    // 1. Activity: selectImageGrid
    if (lessonType == 'selectImageGrid') {
      return LessonQuestionPage(
        key: ValueKey('lesson_$_currentIndex'),
        moduleBadge: widget.moduleTitle,
        title: currentLesson['pregunta_titulo'] ?? 'Selecciona la opción correcta',
        subtitle: currentLesson['pregunta_subtitulo'] ?? 'escucha el audio y responde',
        audioUrl: currentLesson['audio_url'],
        voiceBy: currentLesson['voz_hablante'] ?? '',
        correctAnswer: currentLesson['respuesta_correcta'] ?? '',
        options: currentLesson['opciones'] ?? [],
        onAnswerChecked: _registerAnswer,
        onLessonComplete: _nextLesson,
      );
    }

    // 2. Activity: pausaCognitiva
    if (lessonType == 'pausaCognitiva') {
      return CognitivePausePage(
        key: ValueKey('lesson_$_currentIndex'),
        wordsCount: currentLesson['palabras_reconocidas_conteo'] ?? 1,
        mensajeTitulo: currentLesson['mensaje_titulo'] ?? '¡Ya reconoces palabras nuevas!',
        mensajeSubtitulo: currentLesson['mensaje_subtitulo'] ?? 'Ahora vamos a escribirlas',
        onContinue: _nextLesson,
      );
    }

    // 3. Activity: orderLetters
    if (lessonType == 'orderLetters') {
      final List<dynamic> rawLetters = currentLesson['letras_disponibles'] ?? [];
      final List<String> letters = rawLetters.map((e) => e.toString()).toList();

      return LessonOrderLettersPage(
        key: ValueKey('lesson_$_currentIndex'),
        moduleBadge: widget.moduleTitle,
        title: currentLesson['pregunta_titulo'] ?? 'Seleccione y ordene las letras',
        subtitle: currentLesson['pregunta_subtitulo'] ?? 'Selecciona las letras correctas para formar la palabra',
        imageUrl: currentLesson['imagen_url'],
        targetWord: (currentLesson['palabra_objetivo'] ?? 'MOORKA').toString(),
        availableLetters: letters,
        onAnswerChecked: _registerAnswer,
        onLessonComplete: _nextLesson,
      );
    }

    // 4. Activity: selectTextOption
    if (lessonType == 'selectTextOption') {
      final List<dynamic> rawOptions = currentLesson['opciones_texto'] ??
          currentLesson['opciones_detalle'] ??
          currentLesson['opciones'] ??
          [];

      return LessonSelectTextPage(
        key: ValueKey('lesson_$_currentIndex'),
        moduleBadge: widget.moduleTitle,
        title: currentLesson['pregunta_titulo'] ?? 'Selecciona la opción correcta',
        subtitle: currentLesson['pregunta_subtitulo'] ?? 'escucha el audio y selecciona la opción correcta',
        imageUrl: currentLesson['imagen_url'],
        audioUrl: currentLesson['audio_url'],
        voiceBy: currentLesson['voz_hablante'] ?? '',
        correctAnswer: currentLesson['respuesta_correcta'] ?? '',
        options: rawOptions,
        onAnswerChecked: _registerAnswer,
        onLessonComplete: _nextLesson,
      );
    }

    // 5. Activity: matchTextPairs
    if (lessonType == 'matchTextPairs') {
      final List<dynamic> rawPairs = currentLesson['parejas'] ?? [];

      return LessonMatchTextPairsPage(
        key: ValueKey('lesson_$_currentIndex'),
        moduleBadge: widget.moduleTitle,
        title: currentLesson['pregunta_titulo'] ?? 'Conecta los pares correspondientes',
        subtitle: currentLesson['pregunta_subtitulo'] ?? 'Toca el pronombre y conéctalo con su forma verbal',
        pairs: rawPairs,
        onAnswerChecked: _registerAnswer,
        onLessonComplete: _nextLesson,
      );
    }

    // 6. Activity: swipeCard
    if (lessonType == 'swipeCard') {
      final List<dynamic> rawCards = currentLesson['mazo_tarjetas'] ?? [];

      return LessonSwipeCardPage(
        key: ValueKey('lesson_$_currentIndex'),
        moduleBadge: widget.moduleTitle,
        title: currentLesson['pregunta_titulo'] ?? 'Desliza la imagen hacia el lado correcto',
        subtitle: currentLesson['pregunta_subtitulo'] ?? 'escucha el audio y desliza la imagen',
        voiceBy: currentLesson['voz_hablante'] ?? '',
        cardDeck: rawCards,
        onAnswerChecked: _registerAnswer,
        onLessonComplete: _nextLesson,
      );
    }

    // 7. Activity: fillInBlank
    if (lessonType == 'fillInBlank') {
      final List<dynamic> rawOptions = currentLesson['fichas_opciones'] ??
          currentLesson['opciones'] ??
          [];
      final List<String> options = rawOptions.map((e) => e.toString()).toList();

      return LessonFillBlankPage(
        key: ValueKey('lesson_$_currentIndex'),
        moduleBadge: widget.moduleTitle,
        title: currentLesson['pregunta_titulo'] ?? 'Selecciona la opción correcta',
        subtitle: currentLesson['pregunta_subtitulo'] ?? 'escucha el audio y selecciona la palabra correcta',
        audioUrl: currentLesson['audio_url'],
        voiceBy: currentLesson['voz_hablante'] ?? '',
        sentencePrefix: currentLesson['oracion_prefijo'] ?? '',
        sentenceSuffix: currentLesson['oracion_sufijo'] ?? '',
        correctAnswer: (currentLesson['respuesta_correcta'] ?? '').toString(),
        fullCorrectSentence: currentLesson['oracion_completa_correcta']?.toString(),
        options: options,
        onAnswerChecked: _registerAnswer,
        onLessonComplete: _nextLesson,
      );
    }

    // Unsupported/Unimplemented activity type
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.engineering_rounded, size: 60, color: Colors.amber),
                const SizedBox(height: 16),
                Text(
                  lessonType.isNotEmpty ? 'Actividad "$lessonType" en desarrollo' : 'Actividad no disponible',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Esta actividad ($lessonType) aún no ha sido habilitada por el servidor.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _nextLesson,
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
      ),
    );
  }
}
