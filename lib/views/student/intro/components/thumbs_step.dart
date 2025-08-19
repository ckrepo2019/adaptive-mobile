import 'package:flutter/material.dart';
import 'centered_column.dart';
import 'intro_theme.dart';
import 'typography.dart';
import 'thumb_button.dart';

/// Slide for thumbs up/down questions
class ThumbsStep extends StatelessWidget {
  const ThumbsStep({
    super.key,
    required this.header,
    required this.question,
    required this.onThumbUp,
    required this.onThumbDown,
    this.textColor = IntroTheme.text,
  });

  final String header;
  final String question;
  final VoidCallback onThumbUp;
  final VoidCallback onThumbDown;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return CenteredColumn(
      children: [
        const Spacer(),
        BodySmall(header, color: textColor),
        const SizedBox(height: 10),
        TitleMedium(question, color: textColor),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ThumbButton(icon: Icons.thumb_up, onTap: onThumbUp),
            const SizedBox(width: 10),
            ThumbButton(icon: Icons.thumb_down, onTap: onThumbDown),
          ],
        ),
        const Spacer(),
      ],
    );
  }
}
