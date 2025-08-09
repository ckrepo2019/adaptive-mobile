import 'package:flutter/material.dart';
import 'package:flutter_lms/widgets/base_widgets.dart';

class Achievements extends BaseWidget {
  final Color color;
  final IconData icon;
  final String title;
  final Color titleColor;
  final Color iconColor;

  const Achievements({
    super.key,
    required this.color,
    required this.icon,
    required this.title,
    required this.titleColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Row(
              children: [
                Icon(icon, color: iconColor, size: 16),
                SizedBox(width: 5),
                Text(title, style: TextStyle(color: titleColor)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
