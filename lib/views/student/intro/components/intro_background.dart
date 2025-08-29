import 'package:flutter/material.dart';

class IntroBackground extends StatelessWidget {
  const IntroBackground({super.key, required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(child: ColoredBox(color: color));
  }
}
