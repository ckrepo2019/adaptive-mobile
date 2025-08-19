import 'package:flutter/widgets.dart';

/// Reusable vertical layout with left alignment and safe spacing.
class CenteredColumn extends StatelessWidget {
  final List<Widget> children;
  const CenteredColumn({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}
