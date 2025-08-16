// lib/views/student/home/student_global_layout.dart
import 'package:flutter/material.dart';

class StudentGlobalLayout extends StatelessWidget {
  final bool showBack;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool useSafeArea;

  const StudentGlobalLayout(this.showBack, {
    super.key,
    required this.child,
    this.padding,
    this.useSafeArea = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Padding(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: child,
    );
    return useSafeArea ? SafeArea(child: content) : content;
  }
}
