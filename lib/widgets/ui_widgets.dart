import 'package:flutter/material.dart';

/// Reusable card with left accent, rounded corners, ripple, and soft shadow.
class InkCardShell extends StatelessWidget {
  final Widget child;
  final Color leftAccent;
  final VoidCallback? onTap;

  const InkCardShell({
    super.key,
    required this.child,
    required this.leftAccent,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(12);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: radius,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border(left: BorderSide(color: leftAccent, width: 3)),
          ),
          child: child,
        ),
      ),
    );
  }
}
