import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PracticeQuizResultPage extends StatelessWidget {
  const PracticeQuizResultPage({
    super.key,
    required this.score,
    required this.total,
    this.learnerLabel = 'Auditory Learner',
    this.onTakeActualQuiz,
  });

  final int score;
  final int total;
  final String learnerLabel;
  final VoidCallback? onTakeActualQuiz;

  double _clamp(num v, num min, num max) =>
      v < min ? min.toDouble() : (v > max ? max.toDouble() : v.toDouble());

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final w = mq.size.width;
    final h = mq.size.height;

    // Sizes to match the mock
    final sidePad = _clamp(w * 0.08, 18, 28);
    final titleTopPad = _clamp(h * 0.04, 16, 28);
    final bigNumSize = _clamp(w * 0.45, 120, 220);
    final denomSize = _clamp(w * 0.18, 42, 72);
    final pillHeight = _clamp(h * 0.055, 38, 46);
    final buttonHeight = _clamp(h * 0.065, 48, 56);

    final args = ModalRoute.of(context)!.settings.arguments as Map?;
    final score = (args?['score'] as int?) ?? 0;
    final total = (args?['total'] as int?) ?? 0;
    final learnerLabel =
        (args?['learnerLabel'] as String?) ?? 'Auditory Learner';

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2F6BFF), Color(0xFF1537B9)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Header
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: EdgeInsets.only(top: titleTopPad),
                  child: Text(
                    'Practice Results',
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w600,
                      fontSize: _clamp(w * 0.06, 18, 22),
                    ),
                  ),
                ),
              ),

              // Big score + pill
              Align(
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 3/5
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$score',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            height: 0.95,
                            fontWeight: FontWeight.w800,
                            fontSize: bigNumSize,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '/$total',
                          style: GoogleFonts.poppins(
                            color: Colors.white.withOpacity(0.7),
                            fontWeight: FontWeight.w700,
                            fontSize: denomSize,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),

                    // green pill
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: _clamp(w * 0.06, 18, 26),
                      ),
                      height: pillHeight,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFBFF6C9), Color(0xFFAEEFB9)],
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x33000000),
                            blurRadius: 14,
                            offset: Offset(0, 6),
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

              // Bottom button
              Positioned(
                left: sidePad,
                right: sidePad,
                bottom: _clamp(h * 0.02, 12, 22),
                child: SafeArea(
                  top: false,
                  child: SizedBox(
                    height: buttonHeight,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Material(
                        color: Colors.white,
                        child: InkWell(
                          onTap: onTakeActualQuiz,
                          child: Center(
                            child: Text(
                              'Take Actual Quiz',
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF2F6BFF),
                                fontWeight: FontWeight.w700,
                                fontSize: _clamp(w * 0.042, 14, 18),
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
    );
  }
}
