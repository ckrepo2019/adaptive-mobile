// lib/views/student/home/student_global_layout.dart
import 'package:flutter/material.dart';

class GlobalLayout extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool useSafeArea;

  const GlobalLayout({
    super.key,
    required this.child,
    this.padding,
    this.useSafeArea = true,

  });

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: child,
    );
    return useSafeArea ? SafeArea(child: content) : content;
  }
}
