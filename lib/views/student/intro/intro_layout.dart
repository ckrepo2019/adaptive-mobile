import 'package:flutter/material.dart';

class IntroLayout extends StatelessWidget {
  final Widget child;

  const IntroLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF234FF5), // #234FF5
      body: SafeArea(child: child),
    );
  }
}
