import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'widgets/gradient_background.dart';
import 'speaker_card_unlock.dart';
import 'dashboard.dart';

class ModuleCompletedPage extends StatefulWidget {
  final String moduleTitle;
  final int wordsWorked;
  final int completedLessons;
  final int correctAnswers;
  final int incorrectAnswers;
  final String? nextModuleName;
  final Map<String, dynamic>? unlockedSpeaker;

  const ModuleCompletedPage({
    super.key,
    required this.moduleTitle,
    required this.wordsWorked,
    required this.completedLessons,
    this.correctAnswers = 0,
    this.incorrectAnswers = 0,
    this.nextModuleName,
    this.unlockedSpeaker,
  });

  @override
  State<ModuleCompletedPage> createState() => _ModuleCompletedPageState();
}

class _ModuleCompletedPageState extends State<ModuleCompletedPage>
    with TickerProviderStateMixin {
  /// Duración total de la secuencia de entrada.
  static const Duration _introDuration = Duration(milliseconds: 2400);

  late final AnimationController _intro; // secuencia de entrada escalonada
  late final AnimationController _loop; // flotación de la mascota / pulso del botón
  late final AnimationController _rays; // rotación de los rayos de luz
  late final AnimationController _confetti; // explosión de confeti

  late final List<_ConfettiParticle> _particles;

  @override
  void initState() {
    super.initState();

    _intro = AnimationController(vsync: this, duration: _introDuration);
    _loop = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _rays = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();
    _confetti = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );

    final rnd = math.Random();
    _particles = List.generate(90, (_) => _ConfettiParticle.random(rnd));

    _intro.forward();

    // La mascota "aterriza" → lanzamos confeti + vibración.
    Future.delayed(const Duration(milliseconds: 450), () {
      if (!mounted) return;
      HapticFeedback.mediumImpact();
      _confetti.forward();
    });
  }

  @override
  void dispose() {
    _intro.dispose();
    _loop.dispose();
    _rays.dispose();
    _confetti.dispose();
    super.dispose();
  }

  /// Animación curva sobre un tramo [begin, end] de la secuencia de entrada.
  Animation<double> _interval(double begin, double end,
      {Curve curve = Curves.easeOutCubic}) {
    return CurvedAnimation(
      parent: _intro,
      curve: Interval(begin, end, curve: curve),
    );
  }

  Duration _delayFor(double intervalStart) => Duration(
      milliseconds:
          (_introDuration.inMilliseconds * intervalStart).round() + 150);

  bool get _hasUnlockedSpeaker =>
      widget.unlockedSpeaker != null &&
      (widget.unlockedSpeaker!['nombre'] ?? '').toString().isNotEmpty &&
      widget.unlockedSpeaker!['relato_id'] != null;

  void _onContinue() {
    HapticFeedback.lightImpact();
    if (_hasUnlockedSpeaker) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SpeakerCardUnlockPage()),
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const DashboardPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasNext =
        widget.nextModuleName != null && widget.nextModuleName!.isNotEmpty;

    // Tramos de la secuencia (0.0 → 1.0 de _introDuration)
    final subtitleAnim = _interval(0.00, 0.18);
    final titleAnim = _interval(0.06, 0.32, curve: Curves.easeOutBack);
    final mascotAnim = _interval(0.08, 0.45, curve: Curves.elasticOut);
    final raysAnim = _interval(0.15, 0.40);
    const cardStarts = [0.34, 0.42, 0.50, 0.58];
    final cardAnims = [
      for (final s in cardStarts)
        _interval(s, s + 0.22, curve: Curves.easeOutBack),
    ];
    final pillAnim = _interval(0.70, 0.86, curve: Curves.easeOutBack);
    final buttonAnim = _interval(0.78, 1.00, curve: Curves.easeOutBack);

    final stats = [
      _StatData(widget.wordsWorked, 'Palabras\nTrabajadas',
          const Color(0xFF1B5E20), Icons.auto_stories_rounded),
      _StatData(widget.completedLessons, 'Actividades\nCompletadas',
          const Color(0xFF29B6F6), Icons.task_alt_rounded),
      _StatData(widget.correctAnswers, 'Respuestas\nCorrectas',
          const Color(0xFF27AE60), Icons.check_circle_rounded),
      _StatData(widget.incorrectAnswers, 'Respuestas\nIncorrectas',
          const Color(0xFFE74C3C), Icons.cancel_rounded),
    ];

    Widget card(int i) => _PopIn(
          animation: cardAnims[i],
          slideFrom: const Offset(0, 0.35),
          child: _buildStatCard(stats[i], delay: _delayFor(cardStarts[i])),
        );

    return Scaffold(
      body: Stack(
        children: [
          GradientBackground(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    const SizedBox(height: 16),

                    // Subtítulo superior
                    _FadeSlide(
                      animation: subtitleAnim,
                      from: const Offset(0, -0.6),
                      child: const Text(
                        'Módulo Completado',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Título del módulo
                    _PopIn(
                      animation: titleAnim,
                      child: Text(
                        widget.moduleTitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1B5E20),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Mascota con rayos giratorios, pop elástico y flotación
                    SizedBox(
                      height: 170,
                      child: Stack(
                        alignment: Alignment.center,
                        clipBehavior: Clip.none,
                        children: [
                          FadeTransition(
                            opacity: raysAnim,
                            child: ScaleTransition(
                              scale: raysAnim,
                              child: RotationTransition(
                                turns: _rays,
                                child: const CustomPaint(
                                  size: Size(260, 260),
                                  painter: _SunburstPainter(
                                    color: Color(0xFFFFD54F),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          AnimatedBuilder(
                            animation: Listenable.merge([mascotAnim, _loop]),
                            builder: (context, child) {
                              final bob = Curves.easeInOut.transform(_loop.value);
                              final tilt = (bob - 0.5) * 0.06;
                              return Transform.translate(
                                offset: Offset(0, -6 * bob),
                                child: Transform.rotate(
                                  angle: tilt * mascotAnim.value,
                                  child: Transform.scale(
                                    scale: mascotAnim.value,
                                    child: child,
                                  ),
                                ),
                              );
                            },
                            child: Image.asset(
                              'assets/images/mascot_guad.png',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  Image.asset(
                                'assets/images/mascot.png',
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Center(
                                  child: Text('🦔',
                                      style: TextStyle(fontSize: 100)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Cuadrícula 2x2 de tarjetas que aparecen en cascada
                    Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: card(0)),
                            const SizedBox(width: 14),
                            Expanded(child: card(1)),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(child: card(2)),
                            const SizedBox(width: 14),
                            Expanded(child: card(3)),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Píldora del siguiente módulo desbloqueado
                    if (hasNext)
                      _PopIn(
                        animation: pillAnim,
                        child: _NextModulePill(
                          name: widget.nextModuleName!,
                          unlockAnimation: pillAnim,
                        ),
                      ),

                    const Spacer(),

                    // Botón Continuar estilo 3D con pulso
                    _FadeSlide(
                      animation: buttonAnim,
                      from: const Offset(0, 1.2),
                      child: AnimatedBuilder(
                        animation: Listenable.merge([_loop, _intro]),
                        builder: (context, child) {
                          final pulse = _intro.isCompleted
                              ? 1.0 +
                                  0.025 *
                                      Curves.easeInOut.transform(_loop.value)
                              : 1.0;
                          return Transform.scale(scale: pulse, child: child);
                        },
                        child: _PressableButton(
                          label: 'Continuar',
                          color: const Color(0xFF27AE60),
                          shadowColor: const Color(0xFF1E8449),
                          onPressed: _onContinue,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),

          // Capa de confeti (no bloquea toques)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _ConfettiPainter(
                  animation: _confetti,
                  particles: _particles,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(_StatData s, {required Duration delay}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: s.color.withValues(alpha: 0.25), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: s.color.withValues(alpha: 0.18),
            blurRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(s.icon, color: s.color, size: 24),
          const SizedBox(height: 6),
          _AnimatedNumberCounter(
            targetValue: s.value,
            color: s.color,
            delay: delay,
          ),
          const SizedBox(height: 4),
          Text(
            s.label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatData {
  final int value;
  final String label;
  final Color color;
  final IconData icon;
  const _StatData(this.value, this.label, this.color, this.icon);
}

// ---------------------------------------------------------------------------
// Transiciones reutilizables
// ---------------------------------------------------------------------------

/// Aparece con escala (rebote) + desvanecimiento + desplazamiento opcional.
class _PopIn extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;
  final Offset slideFrom;

  const _PopIn({
    required this.animation,
    required this.child,
    this.slideFrom = Offset.zero,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final v = animation.value; // puede sobrepasar 1.0 (easeOutBack)
        return Opacity(
          opacity: v.clamp(0.0, 1.0),
          child: FractionalTranslation(
            translation: slideFrom * (1 - v),
            child: Transform.scale(scale: 0.6 + 0.4 * v, child: child),
          ),
        );
      },
      child: child,
    );
  }
}

/// Desvanecimiento + desplazamiento sin escala.
class _FadeSlide extends StatelessWidget {
  final Animation<double> animation;
  final Offset from;
  final Widget child;

  const _FadeSlide({
    required this.animation,
    required this.from,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final v = animation.value;
        return Opacity(
          opacity: v.clamp(0.0, 1.0),
          child: FractionalTranslation(
            translation: from * (1 - v),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

// ---------------------------------------------------------------------------
// Píldora "Siguiente módulo" con candado que se abre
// ---------------------------------------------------------------------------

class _NextModulePill extends StatelessWidget {
  final String name;
  final Animation<double> unlockAnimation;

  const _NextModulePill({required this.name, required this.unlockAnimation});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFA5D6A7), width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: unlockAnimation,
            builder: (context, _) {
              final unlocked = unlockAnimation.value > 0.55;
              // Pequeño "sacudón" al abrir el candado
              final shake = math.sin(unlockAnimation.value * math.pi * 4) *
                  0.25 *
                  (1 - unlockAnimation.value.clamp(0.0, 1.0));
              return Transform.rotate(
                angle: shake,
                child: Icon(
                  unlocked ? Icons.lock_open_rounded : Icons.lock_rounded,
                  color: const Color(0xFF1B5E20),
                  size: 22,
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              'Siguiente: $name',
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Botón 3D estilo Duolingo (se "hunde" al presionarlo)
// ---------------------------------------------------------------------------

class _PressableButton extends StatefulWidget {
  final String label;
  final Color color;
  final Color shadowColor;
  final VoidCallback onPressed;

  const _PressableButton({
    required this.label,
    required this.color,
    required this.shadowColor,
    required this.onPressed,
  });

  @override
  State<_PressableButton> createState() => _PressableButtonState();
}

class _PressableButtonState extends State<_PressableButton> {
  static const double _depth = 5;
  bool _pressed = false;

  void _setPressed(bool v) {
    if (_pressed != v) setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: widget.onPressed,
      child: SizedBox(
        height: 54 + _depth,
        width: double.infinity,
        child: Stack(
          children: [
            // Base (sombra sólida)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 54,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: widget.shadowColor,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            // Cara del botón
            AnimatedPositioned(
              duration: const Duration(milliseconds: 70),
              curve: Curves.easeOut,
              left: 0,
              right: 0,
              top: _pressed ? _depth : 0,
              height: 54,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    widget.label.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      color: Colors.white,
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

// ---------------------------------------------------------------------------
// Rayos de luz detrás de la mascota
// ---------------------------------------------------------------------------

class _SunburstPainter extends CustomPainter {
  final Color color;
  const _SunburstPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;
    const rays = 12;
    const sweep = math.pi / rays;

    final rayPaint = Paint()
      ..shader = RadialGradient(
        colors: [color.withValues(alpha: 0.55), color.withValues(alpha: 0.0)],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    for (var i = 0; i < rays; i++) {
      final a = i * 2 * math.pi / rays;
      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..lineTo(center.dx + radius * math.cos(a - sweep / 2),
            center.dy + radius * math.sin(a - sweep / 2))
        ..lineTo(center.dx + radius * math.cos(a + sweep / 2),
            center.dy + radius * math.sin(a + sweep / 2))
        ..close();
      canvas.drawPath(path, rayPaint);
    }

    // Halo suave central
    canvas.drawCircle(
      center,
      radius * 0.45,
      Paint()
        ..shader = RadialGradient(
          colors: [color.withValues(alpha: 0.45), color.withValues(alpha: 0.0)],
        ).createShader(Rect.fromCircle(center: center, radius: radius * 0.45)),
    );
  }

  @override
  bool shouldRepaint(covariant _SunburstPainter oldDelegate) =>
      oldDelegate.color != color;
}

// ---------------------------------------------------------------------------
// Confeti
// ---------------------------------------------------------------------------

class _ConfettiParticle {
  final double angle; // dirección inicial (radianes)
  final double speed; // px/s
  final double size;
  final double spin; // rad/s
  final double wobble; // fase de oscilación lateral
  final Color color;
  final bool isCircle;

  _ConfettiParticle({
    required this.angle,
    required this.speed,
    required this.size,
    required this.spin,
    required this.wobble,
    required this.color,
    required this.isCircle,
  });

  static const _palette = [
    Color(0xFF58CC02),
    Color(0xFF1CB0F6),
    Color(0xFFFFC800),
    Color(0xFFFF4B4B),
    Color(0xFFCE82FF),
    Color(0xFFFF9600),
  ];

  factory _ConfettiParticle.random(math.Random r) {
    // Mayormente hacia arriba, abanico de ~150°
    final angle = -math.pi / 2 + (r.nextDouble() - 0.5) * math.pi * 0.85;
    return _ConfettiParticle(
      angle: angle,
      speed: 450 + r.nextDouble() * 650,
      size: 6 + r.nextDouble() * 6,
      spin: (r.nextDouble() - 0.5) * 14,
      wobble: r.nextDouble() * math.pi * 2,
      color: _palette[r.nextInt(_palette.length)],
      isCircle: r.nextDouble() < 0.3,
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final Animation<double> animation;
  final List<_ConfettiParticle> particles;

  _ConfettiPainter({required this.animation, required this.particles})
      : super(repaint: animation);

  static const double _gravity = 400; // px/s²
  static const double _drag = 1.6; // amortiguación de la velocidad inicial

  @override
  void paint(Canvas canvas, Size size) {
    final progress = animation.value;
    if (progress == 0 || progress == 1) return;

    final seconds = progress *
        (animation is AnimationController
            ? (animation as AnimationController).duration!.inMilliseconds /
                1000
            : 3.2);
    // Origen: zona de la mascota
    final origin = Offset(size.width / 2, size.height * 0.24);
    final opacity = progress < 0.75 ? 1.0 : (1 - progress) / 0.25;

    // Desplazamiento con arrastre: v * (1 - e^{-kt}) / k
    final dragFactor = (1 - math.exp(-_drag * seconds)) / _drag;

    final paint = Paint();
    for (final p in particles) {
      final dx = math.cos(p.angle) * p.speed * dragFactor +
          math.sin(seconds * 6 + p.wobble) * 12;
      final dy = math.sin(p.angle) * p.speed * dragFactor +
          0.5 * _gravity * seconds * seconds;
      final pos = origin + Offset(dx, dy);
      if (pos.dy > size.height + 20) continue;

      paint.color = p.color.withValues(alpha: opacity.clamp(0.0, 1.0));
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(p.spin * seconds);
      if (p.isCircle) {
        canvas.drawCircle(Offset.zero, p.size / 2, paint);
      } else {
        // Efecto de "voltereta" 3D escalando el ancho
        final flip = math.cos(seconds * 8 + p.wobble).abs();
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset.zero,
              width: p.size * (0.3 + 0.7 * flip),
              height: p.size * 0.6,
            ),
            const Radius.circular(1.5),
          ),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => false;
}

// ---------------------------------------------------------------------------
// Contador numérico animado estilo Duolingo
// ---------------------------------------------------------------------------

class _AnimatedNumberCounter extends StatefulWidget {
  final int targetValue;
  final Color color;
  final Duration delay;

  const _AnimatedNumberCounter({
    required this.targetValue,
    required this.color,
    this.delay = Duration.zero,
  });

  @override
  State<_AnimatedNumberCounter> createState() => _AnimatedNumberCounterState();
}

class _AnimatedNumberCounterState extends State<_AnimatedNumberCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _numberAnimation;
  late Animation<double> _scaleAnimation;
  int _lastValue = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _numberAnimation = IntTween(begin: 0, end: widget.targetValue).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 70),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.35), weight: 12),
      TweenSequenceItem(
        tween: Tween(begin: 1.35, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 18,
      ),
    ]).animate(_controller);

    // "Tick" háptico suave cada vez que cambia el número
    _numberAnimation.addListener(() {
      final v = _numberAnimation.value;
      if (v != _lastValue) {
        _lastValue = v;
        if (v == widget.targetValue && v > 0) HapticFeedback.selectionClick();
      }
    });

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Text(
            '${_numberAnimation.value}',
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w900,
              color: widget.color,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        );
      },
    );
  }
}
