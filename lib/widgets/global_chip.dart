import 'package:flutter_lms/widgets/base_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomChip extends BaseWidget {
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;
  final String chipTitle;
  final IconData iconData;

  const CustomChip({
    super.key,
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
    required this.chipTitle, required this.iconData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            iconData,
            size: 14,
            color: textColor,
          ),
          const SizedBox(width: 6),
          Text(
            chipTitle,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
