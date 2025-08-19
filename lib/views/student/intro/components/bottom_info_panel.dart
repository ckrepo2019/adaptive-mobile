import 'package:flutter/material.dart';
import 'intro_theme.dart';
import 'typography.dart';

/// Reusable rounded-top blue panel (identical to the hobbies page)
class BottomInfoPanel extends StatelessWidget {
  const BottomInfoPanel({
    super.key,
    required this.header,
    required this.title,
    required this.body,
  });

  final String header;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: IntroTheme.blue,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: DefaultTextStyle(
        style: const TextStyle(color: Colors.white),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            BodySmall(header, color: Colors.white),
            const SizedBox(height: 8),
            TitleMedium(title, color: Colors.white),
            const SizedBox(height: 12),
            BodySmall(body, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
