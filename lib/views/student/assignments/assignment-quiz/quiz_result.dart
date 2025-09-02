import 'package:flutter/material.dart';
import 'package:flutter_lms/config/routes.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuizResultPage extends StatelessWidget {
  const QuizResultPage({super.key});

  num? _firstNum(Map? map, List<String> keys) {
    if (map == null) return null;
    for (final k in keys) {
      final v = map[k];
      if (v is num) return v;
      if (v is String) {
        final parsed = num.tryParse(v);
        if (parsed != null) return parsed;
      }
    }
    return null;
  }

  String _firstString(Map? map, List<String> keys, {String fallback = ''}) {
    if (map == null) return fallback;
    for (final k in keys) {
      final v = map[k];
      if (v == null) continue;
      final s = v.toString().trim();
      if (s.isNotEmpty) return s;
    }
    return fallback;
  }

  int _toInt(Object? v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse('${v ?? ''}') ?? 0;
  }

  double _clamp(num v, num min, num max) =>
      v < min ? min.toDouble() : (v > max ? max.toDouble() : v.toDouble());

  int _countItemsFromAssessment(Map a) {
    final sections = (a['assessment_section'] is List)
        ? (a['assessment_section'] as List)
        : const [];
    int total = 0;
    for (final s in sections) {
      if (s is Map && s['questions'] is List) {
        total += (s['questions'] as List).length;
      }
    }
    return total;
  }

  int? _computeCorrectFromAssessment(Map a) {
    final sections = (a['assessment_section'] is List)
        ? (a['assessment_section'] as List)
        : const [];
    if (sections.isEmpty) return null;

    final Map<int, Map> qById = {};
    for (final s in sections) {
      if (s is! Map) continue;
      final qs = (s['questions'] is List) ? (s['questions'] as List) : const [];
      for (final q in qs) {
        if (q is! Map) continue;
        final id = _toInt(q['id']);
        if (id <= 0) continue;
        qById[id] = q;
      }
    }

    final answersWrap = a['assessment_score'];
    final answers = (answersWrap is Map && answersWrap['answers'] is List)
        ? (answersWrap['answers'] as List)
        : const [];
    if (answers.isEmpty) return null;

    int correct = 0;

    for (final ans in answers) {
      if (ans is! Map) continue;
      final qid = _toInt(ans['questionID']);
      if (qid <= 0) continue;
      final q = qById[qid];
      if (q == null) continue;

      final type = '${q['type'] ?? ''}';
      final choices = (q['choices'] is List)
          ? (q['choices'] as List)
          : const [];

      if (type == 'multiple_choice' || type == 'true_false') {
        int? correctId;
        for (final c in choices) {
          if (c is! Map) continue;
          final isCorrect = '${c['is_correct'] ?? ''}' == '1';
          if (isCorrect) {
            correctId = _toInt(c['id']);
            break;
          }
        }
        final selected = _toInt(ans['choicesID']);
        if (correctId != null && selected == correctId) {
          correct++;
        }
      } else if (type == 'check_box') {
        final Set<int> correctSet = {};
        for (final c in choices) {
          if (c is! Map) continue;
          final isCorrect = '${c['is_correct'] ?? ''}' == '1';
          if (isCorrect) correctSet.add(_toInt(c['id']));
        }
        final rawSel = ans['choicesID'];
        final Set<int> sel = {};
        if (rawSel is List) {
          sel.addAll(rawSel.map(_toInt));
        } else {
          final s = '${rawSel ?? ''}';
          if (s.contains(',')) {
            sel.addAll(s.split(',').map((e) => _toInt(e.trim())));
          } else {
            final v = _toInt(s);
            if (v > 0) sel.add(v);
          }
        }
        if (sel.isNotEmpty &&
            sel.length == correctSet.length &&
            sel.containsAll(correctSet)) {
          correct++;
        }
      } else {}
    }

    return correct;
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final w = mq.size.width;
    final h = mq.size.height;

    final titleTopPad = _clamp(h * 0.04, 18, 28);
    final scoreBlockTopGap = _clamp(h * 0.14, 60, 140);
    final bigNumSize = _clamp(w * 0.45, 120, 220);
    final denomSize = _clamp(w * 0.18, 42, 72);
    final learnerPillH = _clamp(h * 0.052, 34, 44);

    final sheetTopRadius = 28.0;
    final sheetSidePad = _clamp(w * 0.06, 16, 22);
    final cardHeight = _clamp(h * 0.12, 92, 106);
    final buttonH = _clamp(h * 0.062, 48, 54);

    final args = ModalRoute.of(context)?.settings.arguments as Map? ?? {};
    final Map? result = args['result'] as Map?;
    final Map? assessment = args['assessment'] as Map?;

    num? scoreNum = _firstNum(result, [
      'score',
      'earned',
      'points',
      'total_score',
      'student_score',
    ]);
    num? overallNum = _firstNum(result, [
      'overall',
      'max',
      'total',
      'possible',
      'overall_score',
    ]);

    if ((result == null || result.isEmpty) && assessment != null) {
      final Map? ascore = assessment['assessment_score'] as Map?;
      final num? aScoreNum = _firstNum(ascore, [
        'score',
        'student_score',
        'earned',
      ]);
      final num? aOverallNum = _firstNum(ascore, [
        'overall',
        'overall_score',
        'max',
      ]);

      final itemsTotal = _countItemsFromAssessment(assessment);
      int? itemsCorrect = _computeCorrectFromAssessment(assessment);

      if ((itemsCorrect == null || itemsCorrect < 0) &&
          aScoreNum != null &&
          aOverallNum != null &&
          aOverallNum > 0 &&
          itemsTotal > 0) {
        itemsCorrect = ((aScoreNum / aOverallNum) * itemsTotal).round();
      }

      if (itemsTotal > 0 && itemsCorrect != null) {
        scoreNum = itemsCorrect;
        overallNum = itemsTotal;
      } else {
        scoreNum ??= aScoreNum;
        overallNum ??= aOverallNum;
      }
    }

    final String scoreTxt = (scoreNum == null)
        ? '--'
        : (scoreNum % 1 == 0
              ? scoreNum.toInt().toString()
              : scoreNum.toStringAsFixed(1));
    final String overallTxt = (overallNum == null)
        ? '--'
        : (overallNum % 1 == 0
              ? overallNum.toInt().toString()
              : overallNum.toStringAsFixed(1));

    final double? pct =
        (scoreNum != null && overallNum != null && overallNum > 0)
        ? (scoreNum / overallNum)
        : null;
    String? learnerLabel;
    String? derivedLearner = learnerLabel;
    try {
      final sp = assessment?['studentprofile'];
      if (sp is Map) {
        final lp = sp['learners_profile'];
        if (lp is List && lp.isNotEmpty && lp.first is Map) {
          final name = lp.first['learners_type_name'];
          if (name is String && name.trim().isNotEmpty) {
            derivedLearner = '${name.trim()} Learner';
          }
        }
      }
    } catch (_) {}

    final num? expNum = _firstNum(result, [
      'exp',
      'total_exp',
      'xp',
      'experience',
    ]);
    final num? profNum = _firstNum(result, ['proficiency', 'skill', 'mastery']);
    final num? famNum = _firstNum(result, [
      'familiarity',
      'familiarity_pct',
      'familiarity_percent',
    ]);

    final String expText =
        expNum?.toString() ??
        (pct != null ? (pct * 100).round().toString() : '--');
    final String profText =
        profNum?.toString() ??
        (pct != null ? (pct * 40).round().toString() : '--');
    final String famText = famNum != null
        ? '${famNum.toString()}%'
        : (pct != null ? '${(pct * 100).toStringAsFixed(0)}%' : '--');

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
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: titleTopPad),
                child: Text(
                  'Quiz Result',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.95),
                    fontWeight: FontWeight.w500,
                    fontSize: _clamp(w * 0.06, 18, 22),
                  ),
                ),
              ),

              SizedBox(height: scoreBlockTopGap),

              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    scoreTxt,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      height: 0.95,
                      fontWeight: FontWeight.w800,
                      fontSize: bigNumSize,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '/$overallTxt',
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.8),
                      fontWeight: FontWeight.w700,
                      fontSize: denomSize,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Container(
                height: learnerPillH,
                padding: EdgeInsets.symmetric(
                  horizontal: _clamp(w * 0.05, 14, 22),
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE1FBE8),
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x26000000),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: learnerPillH * 0.62,
                      height: learnerPillH * 0.62,
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
                    const SizedBox(width: 8),
                    Text(
                      derivedLearner!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF245B2E),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(sheetTopRadius),
                    topRight: Radius.circular(sheetTopRadius),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x22000000),
                      blurRadius: 18,
                      offset: Offset(0, -6),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    sheetSidePad,
                    18,
                    sheetSidePad,
                    _clamp(h * 0.022, 12, 20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quiz Achievements',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF2F6BFF),
                          fontWeight: FontWeight.w700,
                          fontSize: _clamp(w * 0.05, 16, 20),
                        ),
                      ),
                      const SizedBox(height: 14),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              child: _AchievementCard(
                                height: cardHeight,
                                bg: const Color(0xFFFFD94E),
                                headerLeft: 'Total EXP',
                                headerRight: '',
                                innerIcon: Icons.bolt_rounded,
                                innerIconColor: const Color(0xFFB88400),
                                valueText: expText,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              child: _AchievementCard(
                                height: cardHeight,
                                bg: const Color(0xFF93D432),
                                headerLeft: 'Proficiency',
                                headerRight: '',
                                innerIcon: Icons.psychology_alt_rounded,
                                innerIconColor: const Color(0xFF4E8B16),
                                valueText: profText,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              child: _AchievementCard(
                                height: cardHeight,
                                bg: const Color(0xFF50BCF4),
                                headerLeft: 'Familiarity',
                                headerRight: '',
                                innerIcon: null,
                                innerIconColor: Colors.transparent,
                                valueText: famText,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 60),

                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: buttonH,
                              child: OutlinedButton(
                                onPressed: () async {
                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  final token = prefs.getString('token');
                                  final uid = prefs.getString('uid');

                                  Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    AppRoutes.studentShell,
                                    (route) => false,
                                    arguments: {
                                      'token': token,
                                      'uid': uid,
                                      'userType': 4,
                                    },
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: Color(0xFF2F6BFF),
                                    width: 2,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(28),
                                  ),
                                ),
                                child: Text(
                                  'Back to Home',
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF2F6BFF),
                                    fontWeight: FontWeight.w700,
                                    fontSize: _clamp(w * 0.100, 13, 13),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          Expanded(
                            child: SizedBox(
                              height: buttonH,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.remedialIntro,
                                    arguments: {'assessment': assessment},
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  elevation: 0,
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(28),
                                  ),
                                ),
                                child: Ink(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF2F6BFF),
                                        Color(0xFF1537B9),
                                      ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    borderRadius: BorderRadius.circular(28),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Take Remedial',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: _clamp(w * 0.042, 14, 18),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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

class _AchievementCard extends StatelessWidget {
  const _AchievementCard({
    required this.bg,
    required this.headerLeft,
    required this.headerRight,
    required this.valueText,
    this.innerIcon,
    this.innerIconColor,
    required this.height,
  });

  final Color bg;
  final String headerLeft;
  final String headerRight;
  final String valueText;
  final IconData? innerIcon;
  final Color? innerIconColor;
  final double height;

  Color _accentFrom(Color c) {
    final hsl = HSLColor.fromColor(c);
    final darker = hsl.withLightness((hsl.lightness * 0.6).clamp(0.0, 1.0));
    return darker.toColor();
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accentFrom(bg);

    return Container(
      height: height,
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
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            headerLeft,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.white,
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
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (innerIcon != null) ...[
                        Icon(
                          innerIcon,
                          size: 18,
                          color: innerIconColor ?? accent,
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        valueText,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: accent,
                        ),
                      ),
                    ],
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
