import 'package:Adaptive/widgets/base_widgets.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomChip extends BaseWidget {
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;
  final String chipTitle;
  final IconData? iconData;
  final IconData? faIconData;

  const CustomChip({
    super.key,
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
    required this.chipTitle,
    this.iconData,
    this.faIconData,
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
          if (iconData != null)
            Icon(iconData, size: 14, color: textColor)
          else if (faIconData != null)
            FaIcon(faIconData, size: 14, color: textColor),
          if (iconData != null || faIconData != null) const SizedBox(width: 6),
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
