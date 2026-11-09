import 'package:flutter/material.dart';

/// A custom vector painter that renders a white turtle icon for slow audio playback.
class WhiteTurtleIcon extends StatelessWidget {
  final double size;
  final Color color;

  const WhiteTurtleIcon({
    super.key,
    this.size = 20,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        size: Size(size, size),
        painter: _TurtlePainter(color: color),
      ),
    );
  }
}

class _TurtlePainter extends CustomPainter {
  final Color color;

  _TurtlePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final double w = size.width;
    final double h = size.height;

    // 1. Shell (main dome)
    final Path shellPath = Path();
    shellPath.addArc(
      Rect.fromLTWH(w * 0.18, h * 0.2, w * 0.60, h * 0.50),
      3.14159, // PI (start at left)
      3.14159, // PI (sweep top semicircle)
    );
    shellPath.lineTo(w * 0.78, h * 0.45);
    shellPath.lineTo(w * 0.18, h * 0.45);
    shellPath.close();
    canvas.drawPath(shellPath, paint);

    // 2. Shell Rim / Bottom border
    final RRect rim = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.14, h * 0.45, w * 0.66, h * 0.12),
      const Radius.circular(2),
    );
    canvas.drawRRect(rim, paint);

    // 3. Head
    canvas.drawCircle(Offset(w * 0.82, h * 0.40), w * 0.11, paint);

    // 4. Tail
    final Path tail = Path();
    tail.moveTo(w * 0.16, h * 0.46);
    tail.lineTo(w * 0.06, h * 0.48);
    tail.lineTo(w * 0.16, h * 0.52);
    tail.close();
    canvas.drawPath(tail, paint);

    // 5. Front Leg
    final RRect frontLeg = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.58, h * 0.55, w * 0.13, h * 0.22),
      const Radius.circular(3),
    );
    canvas.drawRRect(frontLeg, paint);

    // 6. Back Leg
    final RRect backLeg = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.24, h * 0.55, w * 0.13, h * 0.22),
      const Radius.circular(3),
    );
    canvas.drawRRect(backLeg, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
