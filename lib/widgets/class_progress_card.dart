import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ClassProgressCard extends StatelessWidget {
  final double value;
  final String label;
  final double size;
  final double strokeWidth;
  final Color color;
  final Color trackColor;
  final bool animated;

  const ClassProgressCard({
    super.key,
    required this.value,
    this.label = 'Class Progress',
    this.size = 72,
    this.strokeWidth = 8,
    this.color = const Color.fromARGB(255, 141, 204, 105),
    this.trackColor = const Color(0xFFE6EAED),
    this.animated = true,
  });

  @override
  Widget build(BuildContext context) {
    final v = value.clamp(0.0, 1.0);
    final percent = (v * 100).round();

    Widget ring(double t) => Stack(
      fit: StackFit.expand,
      children: [
        CircularProgressIndicator(
          value: t,
          strokeWidth: strokeWidth,
          backgroundColor: trackColor,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
        Center(
          child: Text(
            '$percent%',
            style: GoogleFonts.poppins(
              fontSize: size * 0.26,
              fontWeight: FontWeight.w700,
              color: const Color.fromARGB(255, 141, 204, 105),
            ),
          ),
        ),
      ],
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x11000000)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: animated
                ? TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: v),
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeOutCubic,
                    builder: (_, t, __) => ring(t),
                  )
                : ring(v),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
