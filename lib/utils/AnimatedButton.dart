import 'package:flutter/material.dart';
import 'package:presshop/utils/Common.dart';
import 'package:presshop/utils/CommonWigdets.dart';

class AnimatedButtonWidget extends StatefulWidget {
  VoidCallback onPressed;
  String buttonText;
  Size size;
  bool shouldRestartAnimation = false;
  AnimatedButtonWidget(
      {super.key,
      required this.onPressed,
      required this.buttonText,
      required this.shouldRestartAnimation,
      required this.size});

  @override
  _AnimatedButtonState createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButtonWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _revealAnimation;
  late Animation<double> _opacityAnimation;
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );
    _revealAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutCubic,
      ),
    );
    _opacityAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.forward();
    });

    _revealAnimation.addListener(() {
      if (_revealAnimation.isCompleted) {
        if (mounted) {
          widget.onPressed();
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.shouldRestartAnimation) {
      widget.shouldRestartAnimation = false;
      if (_controller.isCompleted) {
        _controller.reset();
      }
      if (!_controller.isAnimating) {
        _controller.forward();
      }
    }
    return Center(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return ClipRect(
              child: Align(
                alignment: Alignment.centerLeft,
                widthFactor: _revealAnimation.value, // Left-to-right reveal
                child: AnimatedOpacity(
                  opacity: _opacityAnimation.value,
                  duration: const Duration(microseconds: 350),
                  child: SizedBox(
                    width: widget.size.width,
                    height: widget.size.width * numD13,
                    child: commonElevatedButton(
                        widget.buttonText,
                        widget.size,
                        commonButtonTextStyle(widget.size),
                        commonButtonStyle(widget.size, colorThemePink), () {
                      _controller.reset();
                      widget.onPressed();
                    }),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
