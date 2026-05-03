import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:presshop/core/core_export.dart';

class LoadingDialogContent extends StatefulWidget {
  const LoadingDialogContent({super.key, required this.progress});
  final double progress;

  @override
  State<LoadingDialogContent> createState() => _LoadingDialogContentState();
}

class _LoadingDialogContentState extends State<LoadingDialogContent> {
  int _dotCount = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) {
        setState(() {
          _dotCount = (_dotCount + 1) % 4;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    String dots = "." * _dotCount;
    String text;
    if (widget.progress >= 1.0) {
      text = "Processing$dots";
    } else {
      text = "Uploading$dots ${(widget.progress * 100).toStringAsFixed(0)}%";
    }

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              "assets/lottieFiles/loader_new.json",
              height: 100,
              width: 100,
            ),
            Text(
              text,
              style: commonTextStyle(
                size: size,
                fontSize: size.width * AppDimensions.numD035,
                color: const Color.fromARGB(255, 204, 208, 208),
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
