import 'package:flutter/material.dart';
import 'package:Adaptive/config/constants.dart';
import 'package:Adaptive/widgets/ui_widgets.dart';
import 'package:google_fonts/google_fonts.dart';

class ClassTimeline extends StatelessWidget {
  final String time;
  final String title;
  final String subtitle;

  const ClassTimeline({
    super.key,
    required this.time,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final parts = time.split(' ');
    final displayTime = parts.isNotEmpty ? parts.first : time;
    final meridian = parts.length > 1 ? parts.last : '';

    return InkCardShell(
      leftAccent: AppConstants.mainColorTheme,
      child: Row(
        children: [
          Column(
            children: [
              Text(
                displayTime,
                style: GoogleFonts.poppins(
                  color: Colors.blue.shade800,
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                ),
              ),
              Text(
                meridian,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            width: 2,
            height: 60,
            color: Colors.grey.shade400.withOpacity(0.5),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(subtitle,
                  style: TextStyle(
                      fontWeight: FontWeight.w400,
                      color: Colors.grey.shade500)),
              Text(title,
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600, fontSize: 20)),
            ],
          ),
        ],
      ),
    );
  }
}
