import 'dart:math';
import 'package:flutter/material.dart';
import 'widgets/gradient_background.dart';
import 'dashboard.dart';
import 'speaker_story.dart';

class SpeakerCardUnlockPage extends StatefulWidget {
  final String speakerName;
  final String? speakerImage;

  const SpeakerCardUnlockPage({
    super.key,
    this.speakerName = 'Yolanda Fher',
    this.speakerImage,
  });

  @override
  State<SpeakerCardUnlockPage> createState() => _SpeakerCardUnlockPageState();
}

class _SpeakerCardUnlockPageState extends State<SpeakerCardUnlockPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFlipped = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: pi).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutBack),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (!_isFlipped) {
      _controller.forward();
      setState(() {
        _isFlipped = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

                // Flip Card Widget
                GestureDetector(
                  onTap: _flipCard,
                  child: AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      final angle = _animation.value;
                      final isFrontVisible = angle >= pi / 2;

                      return Transform(
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001) // perspective
                          ..rotateY(angle),
                        alignment: Alignment.center,
                        child: isFrontVisible
                            ? Transform(
                                transform: Matrix4.identity()..rotateY(pi),
                                alignment: Alignment.center,
                                child: _buildFrontCard(),
                              )
                            : _buildBackCard(),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 32),

                // Subtitle / Prompt Text below card (before flip)
                if (!_isFlipped) ...[
                  const Text(
                    'Alguien quiere presentarse',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Toca la ficha para verla',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],

                const Spacer(),

                // Bottom "Abrir" Button (appears after flip)
                if (_isFlipped) ...[
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SpeakerStoryPage(),
                          ),
                        );
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
                        'Abrir',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Front of Card (Revealed Speaker Photo & Name)
  Widget _buildFrontCard() {
    return Container(
      width: 260,
      height: 350,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFC5A059), width: 3.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFC5A059), width: 2),
            ),
            child: ClipOval(
              child: Image.network(
                widget.speakerImage ??
                    'https://images.unsplash.com/photo-1544005313-94ddf0286df2?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=80',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.amber.shade100,
                  child: const Center(
                    child: Text('👵', style: TextStyle(fontSize: 80)),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            widget.speakerName,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

  // Back of Card (Timber frame design + Flower Emblem)
  Widget _buildBackCard() {
    return Container(
      width: 260,
      height: 350,
      decoration: BoxDecoration(
        color: const Color(0xFFFAF6EE),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFC5A059), width: 3.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Timber Frame Cross Pattern (Fachwerk motif)
          CustomPaint(
            size: const Size(260, 350),
            painter: _TimberFramePainter(),
          ),

          // Central Flower Seal
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFFAF6EE),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFC5A059), width: 2),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 6),
              ],
            ),
            child: const Center(
              child: Text('🌺', style: TextStyle(fontSize: 30)),
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper Painter to render the timber frame lines on back of card
class _TimberFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF4A2E1B)
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.square;

    // Vertical Timbers
    canvas.drawLine(Offset(size.width * 0.18, 0), Offset(size.width * 0.18, size.height), paint);
    canvas.drawLine(Offset(size.width * 0.82, 0), Offset(size.width * 0.82, size.height), paint);

    // Horizontal Timbers
    canvas.drawLine(Offset(0, size.height * 0.25), Offset(size.width, size.height * 0.25), paint);
    canvas.drawLine(Offset(0, size.height * 0.75), Offset(size.width, size.height * 0.75), paint);

    // Diagonal Timber Cross
    canvas.drawLine(Offset(size.width * 0.18, size.height * 0.25), Offset(size.width * 0.82, size.height * 0.75), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
