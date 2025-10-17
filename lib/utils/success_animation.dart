import 'package:flutter/material.dart';
import '../constants/theme2.dart';
import '../utils/pok.dart';


class SuccessAnimation extends StatefulWidget {
  final bool isFailure;
  const SuccessAnimation({super.key, this.isFailure = false});
  @override
  _SuccessAnimationState createState() => _SuccessAnimationState();
}

class _SuccessAnimationState extends State<SuccessAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    _startAnimation();
  }

  Future<void> _startAnimation() async {
    while (mounted) {
      await _controller.forward();
      if (!mounted) return;
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      await _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.stop(); // Stop any ongoing animation
    _controller.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            for (int i = 0; i < 8; i++)
              Transform.rotate(
                angle: i * 0.785398, // 45 degrees in radians
                child: Transform.translate(
                  offset: Offset(0, -85 - 50 * _animation.value),
                  child: Container(
                    width: 4,
                    height: 20,
                    color: widget.isFailure?Colors.redAccent.withOpacity(1 - _animation.value):
                    Colors.green.withOpacity(1 - _animation.value),
                  ),
                ),
              ),
            Transform.scale(
              scale: 1 + 0.2 * _animation.value,
              child: Icon(
                widget.isFailure?Icons.cancel:Icons.check_circle,
                color: widget.isFailure?Colors.redAccent:CommonColors.green,
                size: 150.minSp,
              ),
            ),
          ],
        );
      },
    );
  }
}

class FailureAnimation extends StatelessWidget {
  const FailureAnimation({super.key});

  @override
  Widget build(BuildContext context) {
    return SuccessAnimation(isFailure: true);
  }
}

