import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_lms/config/routes.dart';

class AchievementsPage extends StatelessWidget {
  const AchievementsPage({
    super.key,
    this.exp = 75,
    this.proficiency = 70,
    this.familiarity = 70,
    this.onAchievements,
    this.onReviewMaster,
    this.onContinue,
  });

  final int exp;
  final int proficiency;
  final int familiarity;
  final VoidCallback? onAchievements;
  final VoidCallback? onReviewMaster;
  final VoidCallback? onContinue;

  static const Color kBgTop = Color(0xFF2F6BFF);
  static const Color kBgBottom = Color(0xFF1537B9);
  static const Color kExpCard = Color(0xFFFFC44D);
  static const Color kExpAccent = Color(0xFFF59E0B);
  static const Color kProfCard = Color(0xFF22C55E);
  static const Color kProfAccent = Color(0xFF16A34A);
  static const Color kFamCard = Color(0xFF06B6D4);
  static const Color kFamAccent = Color(0xFF0891B2);
  static const Color kBtnPrimary = Color(0xFF2563EB);
  static const Color kBtnText = Colors.white;

  ({
    String title,
    String subtitle,
    String asset,
    String leftLabel,
    VoidCallback? leftOnTap,
  })
  _case() {
    if (exp >= 100 && proficiency >= 100 && familiarity >= 100) {
      return (
        title: 'Legendary!',
        subtitle:
            "Congratulations! You've proven your\nskills and unlocked a new\nachievement",
        asset: 'assets/images/assignments/achievement-star.png',
        leftLabel: 'Achievements',
        leftOnTap: onAchievements,
      );
    } else if (proficiency >= 100 && familiarity >= 100 && exp >= 95) {
      return (
        title: 'Flawless!',
        subtitle: "0 mistakes; You're superb in these\nquizzes, keep it up!",
        asset: 'assets/images/assignments/achievement-flawless.png',
        leftLabel: 'Achievements',
        leftOnTap: onAchievements,
      );
    } else if (exp >= 60 && proficiency >= 60 && familiarity >= 60) {
      return (
        title: 'You Passed!',
        subtitle: "You passed, keep it up and let's\nmaster this lesson!",
        asset: 'assets/images/assignments/achievement-you-passed.png',
        leftLabel: 'Review & Master',
        leftOnTap: onReviewMaster,
      );
    } else {
      return (
        title: "Let's Try Again!",
        subtitle:
            "Failing is part of the progress, let's\nreview and try again!",
        asset: 'assets/images/assignments/achievement-you-failed.png',
        leftLabel: 'Review & Master',
        leftOnTap: onReviewMaster,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = _case();
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
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
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      SizedBox(
                        width: 400,
                        height: 400,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 160,
                              height: 160,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0x33FFC44D),
                                    blurRadius: 40,
                                    spreadRadius: 10,
                                  ),
                                  BoxShadow(
                                    color: Color(0x22FFC44D),
                                    blurRadius: 80,
                                    spreadRadius: 30,
                                  ),
                                ],
                              ),
                            ),
                            Image.asset(
                              data.asset,
                              width: 400,
                              height: 400,
                              fit: BoxFit.contain,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        data.title,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        data.subtitle,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withOpacity(0.92),
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          bg: kExpCard,
                          accent: kExpAccent,
                          labelTop: 'Total EXP',
                          value: '⚡ $exp',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          bg: kProfCard,
                          accent: kProfAccent,
                          labelTop: 'Proficiency',
                          value: '⭐ $proficiency',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          bg: kFamCard,
                          accent: kFamAccent,
                          labelTop: 'Familiarity',
                          value: '$familiarity%',
                        ),
                      ),
                    ],
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
                            onPressed:
                                onReviewMaster ??
                                () => Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  AppRoutes.achievementQuizStreak,
                                  (route) => false,
                                ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(27),
                              ),
                            ),
                            child: Text(
                              data.leftLabel,
                              style: GoogleFonts.poppins(
                                color: kBtnPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: data.leftLabel == 'Review & Master'
                                    ? 12
                                    : 14,
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
                                  AppRoutes.achievementsTop,
                                  (route) => false,
                                ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kBtnPrimary,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(27),
                              ),
                            ),
                            child: Text(
                              'Continue',
                              style: GoogleFonts.poppins(
                                color: kBtnText,
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

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.bg,
    required this.accent,
    required this.labelTop,
    required this.value,
  });

  final Color bg;
  final Color accent;
  final String labelTop;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            labelTop,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 12,
                    offset: Offset(0, 7),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: accent,
                      height: 1,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
