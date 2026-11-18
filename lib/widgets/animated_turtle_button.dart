import 'package:flutter/material.dart';
import 'white_turtle_icon.dart';

/// Interactive Animated Turtle Button for slow audio playback (0.6x speed)
class AnimatedTurtleButton extends StatefulWidget {
  final VoidCallback onTap;
  final bool isPlayingSlow;
  final double size;

  const AnimatedTurtleButton({
    super.key,
    required this.onTap,
    this.isPlayingSlow = false,
    this.size = 38,
  });

  @override
  State<AnimatedTurtleButton> createState() => _AnimatedTurtleButtonState();
}

class _AnimatedTurtleButtonState extends State<AnimatedTurtleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.2), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _rotationAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -0.12), weight: 25),
      TweenSequenceItem(tween: Tween(begin: -0.12, end: 0.12), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 0.12, end: 0.0), weight: 25),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.isPlayingSlow) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedTurtleButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlayingSlow) {
      if (!_controller.isAnimating) {
        _controller.repeat();
      }
    } else {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _controller.forward(from: 0.0);
        widget.onTap();
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value,
              child: child,
            ),
          );
        },
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: widget.isPlayingSlow
                ? const Color(0xFF0288D1)
                : const Color(0xFF29B6F6),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF29B6F6).withOpacity(0.4),
                blurRadius: widget.isPlayingSlow ? 10 : 4,
                spreadRadius: widget.isPlayingSlow ? 2 : 0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: WhiteTurtleIcon(
              size: widget.size * 0.52,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
