import 'package:flutter/material.dart';

/// Simple fill background to override any parent color (e.g., IntroLayout)
class IntroBackground extends StatelessWidget {
  const IntroBackground({super.key, required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(child: ColoredBox(color: color));
  }
}
