import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_lms/config/routes.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';

class PracticeQuizIntroPage extends StatelessWidget {
  const PracticeQuizIntroPage({
    super.key,
    this.onContinue,
    this.learnerLabel = 'Auditory Learner',
    this.imageAsset = 'assets/images/assignments/practice_quiz_intro_model.png',
  });

  final VoidCallback? onContinue;
  final String learnerLabel;
  final String imageAsset;

  double _clamp(num v, num min, num max) =>
      v < min ? min.toDouble() : (v > max ? max.toDouble() : v.toDouble());

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final w = mq.size.width;
    final h = mq.size.height;

    // typography & paddings
    final titleSize = _clamp(w * 0.095, 28, 36);
    final pillPaddingH = _clamp(w * 0.06, 18, 26);
    final pillHeight = _clamp(h * 0.055, 38, 46);
    final sidePad = _clamp(w * 0.08, 20, 28);

    // push title lower
    final titleTop = _clamp(h * 0.15, 104, 170);

    // illustration: bigger and OVERFLOW past bottom
    final illoHeight = _clamp(h * 0.95, 600, 1000);
    final illoExtraWidthFactor = 1.22; // wider than screen for that big look
    final illoBottomOverlap = _clamp(
      h * 0.22,
      120,
      220,
    ); // negative pushes it below

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0E58FF), Color(0xFF0A49E6), Color(0xFF083BD1)],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Stack(
              children: [
                // --- Big illustration (centered, overlaps below the screen) ---
                Positioned(
                  left: -w * (1.7 - 1) / 2, // now ~70% wider
                  right: -w * (1.7 - 1) / 2,
                  bottom: -_clamp(h * 0.35, 200, 340),
                  child: IgnorePointer(
                    ignoring: true,
                    child: SizedBox(
                      height: _clamp(
                        h * 1.95, // was 1.45 → now 1.65 (super tall)
                        900,
                        1800,
                      ),
                      child: OverflowBox(
                        minWidth: w * 1.7,
                        maxWidth: w * 1.7,
                        minHeight: _clamp(h * 1.65, 900, 1800),
                        maxHeight: _clamp(h * 1.65, 900, 1800),
                        child: Image.asset(
                          imageAsset,
                          fit: BoxFit.contain,
                          alignment: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                ),

                // --- Headline + pill ---
                Positioned(
                  left: sidePad,
                  right: sidePad,
                  top: titleTop,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'You Are Now On\nPractice Mode!',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          height: 1.12,
                          fontSize: titleSize,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: _clamp(h * 0.018, 10, 18)),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: pillPaddingH),
                        height: pillHeight,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          gradient: const LinearGradient(
                            colors: [Color(0xFFBFF6C9), Color(0xFFAEEFB9)],
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x33000000),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: pillHeight * 0.58,
                              height: pillHeight * 0.58,
                              decoration: const BoxDecoration(
                                color: Color(0xFF7BE196),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.hearing_rounded,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              learnerLabel,
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF245B2E),
                                fontWeight: FontWeight.w600,
                                fontSize: _clamp(w * 0.040, 13, 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // --- Bottom truly WHITE button (Material + InkWell) ---
                Positioned(
                  left: sidePad,
                  right: sidePad,
                  bottom: _clamp(h * 0.018, 10, 22),
                  child: SafeArea(
                    top: false,
                    child: SizedBox(
                      height: _clamp(h * 0.065, 48, 56),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: Material(
                          color: Colors.white, // guaranteed white
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                AppRoutes.practiceQuiz,
                                (route) =>
                                    false, // clear everything so back can't return here
                              );
                            },
                            child: Center(
                              child: Text(
                                'Continue',
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF0E58FF),
                                  fontWeight: FontWeight.w700,
                                  fontSize: _clamp(w * 0.045, 15, 18),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
