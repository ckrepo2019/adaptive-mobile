import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StudentsCountCard extends StatelessWidget {
  final int count;

  final double iconSize;

  final double padding;

  final String assetPath;

  final Color? tint;

  const StudentsCountCard({
    super.key,
    required this.count,
    this.iconSize = 40,
    this.padding = 20,
    this.assetPath = 'assets/images/student-class/student-icon.png',
    this.tint,
  });

  @override
  Widget build(BuildContext context) {
    final label = '$count ${count == 1 ? "Student" : "Students"}';

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x11000000)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: iconSize + 8,
            width: iconSize + 8,
            child: Center(
              child: Image.asset(
                assetPath,
                width: iconSize,
                height: iconSize,
                fit: BoxFit.contain,
                color: tint,
                filterQuality: FilterQuality.high,
                errorBuilder: (_, __, ___) {
                  return Icon(
                    Icons.groups_2_outlined,
                    size: iconSize,
                    color: Colors.black87,
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
