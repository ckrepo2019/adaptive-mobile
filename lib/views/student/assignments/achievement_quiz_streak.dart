import 'package:flutter/material.dart';
import 'package:Adaptive/config/routes.dart';
import 'package:google_fonts/google_fonts.dart';

class AchievementQuizStreakPage extends StatelessWidget {
  const AchievementQuizStreakPage({
    super.key,
    this.streak = 1,
    this.onReviewMaster,
    this.onContinue,
    this.asset = 'assets/images/assignments/achievement-quiz-streak.png',
  });

  final int streak;
  final VoidCallback? onReviewMaster;
  final VoidCallback? onContinue;
  final String asset;

  static const Color kBgTop = Color(0xFF2F6BFF);
  static const Color kBgBottom = Color(0xFF1537B9);
  static const Color kYellow = Color(0xFFFFC44D);
  static const Color kYellowDark = Color(0xFFF59E0B);
  static const Color kDotDark = Color(0xFF0E3A8A);
  static const Color kBtnPrimary = Color.fromARGB(255, 37, 37, 37);

  @override
  Widget build(BuildContext context) {
    final s = streak.clamp(1, 5);
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [kBgTop, kBgBottom],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 28),
                SizedBox(
                  width: 300,
                  height: 300,
                  child: Image.asset(asset, fit: BoxFit.contain),
                ),
                const SizedBox(height: 12),
                Text(
                  'Your Quiz Streak',
                  style: GoogleFonts.poppins(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 18),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Row(
                    children: List.generate(
                      5,
                      (i) => Expanded(
                        child: Center(
                          child: Text(
                            '${i + 1}',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white.withOpacity(0.85),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: List.generate(5, (i) {
                      final idx = i + 1;
                      Widget dot;
                      if (idx == s) {
                        dot = _FilledCheckDot(
                          size: 44,
                          fill: kYellow,
                          icon: Icons.check,
                          iconColor: Colors.white,
                        );
                      } else if (idx == s + 1) {
                        dot = _DashedRing(
                          size: 44,
                          color: kYellow,
                          strokeWidth: 3,
                          gaps: 20,
                        );
                      } else {
                        dot = _SolidDot(size: 44, color: kDotDark);
                      }
                      return Expanded(child: Center(child: dot));
                    }),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Text(
                    'engage with practice lesson to up your\nstreaks!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.9),
                      height: 1.35,
                    ),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 54,
                          child: ElevatedButton(
                            onPressed: onReviewMaster ?? () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(27),
                              ),
                            ),
                            child: Text(
                              'Review & Master',
                              style: GoogleFonts.poppins(
                                color: Color(0xFF1537B9),
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 54,
                          child: ElevatedButton(
                            onPressed:
                                onContinue ??
                                () => Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  AppRoutes.yourAchievements,
                                  (route) => false,
                                ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF234FF5),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(27),
                              ),
                            ),
                            child: Text(
                              'Continue',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SolidDot extends StatelessWidget {
  const _SolidDot({required this.size, required this.color});
  final double size;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

class _FilledCheckDot extends StatelessWidget {
  const _FilledCheckDot({
    required this.size,
    required this.fill,
    required this.icon,
    required this.iconColor,
  });
  final double size;
  final Color fill;
  final IconData icon;
  final Color iconColor;
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: fill,
      shape: BoxShape.circle,
      boxShadow: const [
        BoxShadow(
          color: Color(0x33000000),
          blurRadius: 8,
          offset: Offset(0, 3),
        ),
      ],
    ),
    child: Icon(icon, color: iconColor, size: size * 0.46),
  );
}

class _DashedRing extends StatelessWidget {
  const _DashedRing({
    required this.size,
    required this.color,
    required this.strokeWidth,
    this.gaps = 16,
  });
  final double size;
  final Color color;
  final double strokeWidth;
  final int gaps;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: size,
    height: size,
    child: CustomPaint(
      painter: _DashedCirclePainter(
        color: color,
        strokeWidth: strokeWidth,
        gaps: gaps,
      ),
    ),
  );
}

class _DashedCirclePainter extends CustomPainter {
  _DashedCirclePainter({
    required this.color,
    required this.strokeWidth,
    required this.gaps,
  });
  final Color color;
  final double strokeWidth;
  final int gaps;
  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2 - strokeWidth / 2;
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final total = 360.0;
    final units = gaps;
    final dashAngle = (total / units) * 0.6;
    final gapAngle = (total / units) - dashAngle;
    double start = -90;
    for (int i = 0; i < units; i++) {
      final sweep = dashAngle * 3.1415926535 / 180;
      final startRad = start * 3.1415926535 / 180;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: r),
        startRad,
        sweep,
        false,
        paint,
      );
      start += dashAngle + gapAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
