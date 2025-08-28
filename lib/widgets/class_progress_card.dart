import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ClassProgressCard extends StatelessWidget {
  /// Progress value from 0.0 to 1.0
  final double value;

  /// Optional label under the ring
  final String label;

  /// Ring diameter (reduced)
  final double size;

  /// Ring thickness (reduced)
  final double strokeWidth;

  /// Progress color
  final Color color;

  /// Track color (the gray part)
  final Color trackColor;

  /// Animate the ring from 0 to [value]
  final bool animated;

  const ClassProgressCard({
    super.key,
    required this.value,
    this.label = 'Class Progress',
    this.size = 72, // was 96
    this.strokeWidth = 8, // was 10
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
              fontSize: size * 0.26, // was 0.28
              fontWeight: FontWeight.w700,
              color: Color.fromARGB(255, 141, 204, 105),
            ),
          ),
        ),
      ],
    );

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14, // was 18
        vertical: 12, // was 16
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14), // was 16
        border: Border.all(color: const Color(0x11000000)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 10, // was 12
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
                    duration: const Duration(
                      milliseconds: 700,
                    ), // a bit snappier
                    curve: Curves.easeOutCubic,
                    builder: (_, t, __) => ring(t),
                  )
                : ring(v),
          ),
          const SizedBox(height: 10), // was 12
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13, // was 15
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
