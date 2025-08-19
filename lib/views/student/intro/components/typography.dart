import 'package:flutter/widgets.dart';
import 'intro_theme.dart';

class TitleSmall extends StatelessWidget {
  final String text;
  final Color color;
  const TitleSmall(this.text, {super.key, this.color = IntroTheme.subText});

  @override
  Widget build(BuildContext context) =>
      Text(text, style: TextStyle(color: color, fontSize: 14));
}

class TitleLarge extends StatelessWidget {
  final String text;
  final Color color;
  const TitleLarge(this.text, {super.key, this.color = IntroTheme.text});

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(
      color: color,
      fontSize: 40,
      fontWeight: FontWeight.bold,
      letterSpacing: 2,
      height: 1.2,
    ),
  );
}

class TitleMedium extends StatelessWidget {
  final String text;
  final Color color;
  const TitleMedium(this.text, {super.key, this.color = IntroTheme.text});

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(
      color: color,
      fontSize: 30,
      fontWeight: FontWeight.bold,
      height: 1.25,
    ),
  );
}

class BodySmall extends StatelessWidget {
  final String text;
  final Color color;
  const BodySmall(this.text, {super.key, this.color = IntroTheme.subText});

  @override
  Widget build(BuildContext context) =>
      Text(text, style: TextStyle(color: color, fontSize: 18));
}
