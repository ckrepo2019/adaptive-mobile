import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ClassProgressCard extends StatelessWidget {
  final double value;
  final String? label;            // Optional: if null, show "Progress" inside the ring
  final double size;
  final double strokeWidth;
  final Color color;
  final Color trackColor;
  final bool animated;
  final bool showShadow;

  const ClassProgressCard({
    super.key,
    required this.value,
    this.label,
    this.size = 72,
    this.strokeWidth = 8,
    this.color = const Color.fromARGB(255, 141, 204, 105),
    this.trackColor = const Color(0xFFE6EAED),
    this.animated = true,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0.0, 1.0);
    final percent = (clamped * 100).round();

    final percentStyle = GoogleFonts.poppins(
      fontSize: size * 0.26,
      fontWeight: FontWeight.w700,
      color: color,
    );

    final progressFallbackStyle = GoogleFonts.poppins(
      fontSize: size * 0.08,
      fontWeight: FontWeight.w400,
      color: Colors.black,
      height: 0.2,
    );

    final labelStyle = GoogleFonts.poppins(
      fontSize: 13,
      color: Colors.grey.shade700,
      fontWeight: FontWeight.w600,
    );

    Widget ring(double t) {
      return Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: t,
            strokeWidth: strokeWidth,
            backgroundColor: trackColor,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('$percent%', style: percentStyle),
                if (label == null)
                  Text('Progress', style: progressFallbackStyle),
              ],
            ),
          ),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: showShadow
            ? const [
                BoxShadow(
                  color: Color(0x0F000000),
                  blurRadius: 10,
                  offset: Offset(0, 6),
                ),
              ]
            : const [],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: animated
                ? TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: clamped),
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeOutCubic,
                    builder: (_, t, __) => ring(t),
                  )
                : ring(clamped),
          ),
          if (label != null) ...[
            const SizedBox(height: 10),
            Text(label!, textAlign: TextAlign.center, style: labelStyle),
          ],
        ],
      ),
    );
  }
}
