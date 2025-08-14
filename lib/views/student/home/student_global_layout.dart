import 'package:flutter/material.dart';

class StudentGlobalLayout extends StatelessWidget {
  final Widget child;

  const StudentGlobalLayout({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(padding: EdgeInsetsGeometry.all(25), child: child),
      ),
    );
  }
}
