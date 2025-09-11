import 'package:flutter/material.dart';
import 'package:Adaptive/config/constants.dart';
import 'package:Adaptive/widgets/ui_widgets.dart';
import 'package:google_fonts/google_fonts.dart';

class ClassTimeline extends StatelessWidget {
  const ClassTimeline({super.key});

  @override
  Widget build(BuildContext context) {
    return InkCardShell(
      leftAccent: AppConstants.mainColorTheme,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center, // align left
            children: [
              Text(
                '07:00',
                style: GoogleFonts.poppins(
                  color: Colors.blue.shade800,
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                ),
              ),
              Text(
                "AM",
                style: const TextStyle(
                  height: 0.1, // reduce spacing between
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),

          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            width: 2,
            height: 60, // adjust height as needed
            color: Colors.grey.shade400.withOpacity(0.5),
          ),

          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Mathematics", style: TextStyle(fontWeight: FontWeight.w400, color: Colors.grey.shade500),),
              Text("Essential Algebra\nFor Beginners", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 20),),
            ],
          )

        ],
      ),
    );
  }
}
