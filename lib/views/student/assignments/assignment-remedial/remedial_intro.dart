import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:Adaptive/config/routes.dart';
import 'package:Adaptive/controllers/student/student_remedial.dart';
import 'package:Adaptive/controllers/api_response.dart';

class RemedialIntroPage extends StatefulWidget {
  const RemedialIntroPage({
    super.key,
    this.onContinue,
    this.learnerLabel = 'Auditory Learner',
    this.imageAsset = 'assets/images/assignments/practice_quiz_intro_model.png',
  });

  final VoidCallback? onContinue;
  final String learnerLabel;
  final String imageAsset;

  @override
  State<RemedialIntroPage> createState() => _RemedialIntroPageState();
}

class _RemedialIntroPageState extends State<RemedialIntroPage> {
  bool _didFetch = false;
  bool _loading = false;
  String? _error;
  String? _debugJson;
  String _learnerPillLabel = '';
  int? _teacherAssessmentID;
  int? _assessmentId;
  Map<String, dynamic>? _masteryData;

  @override
  void initState() {
    super.initState();
    _learnerPillLabel = widget.learnerLabel;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didFetch) return;
    _didFetch = true;
    _loadMasteryFromRoute();
  }

  double _clamp(num v, num min, num max) =>
      v < min ? min.toDouble() : (v > max ? max.toDouble() : v.toDouble());

  int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }

  int? _firstTeacherAssessmentIdFromDetails(Map<String, dynamic>? details) {
    if (details == null) return null;
    final d = Map<String, dynamic>.from(details);
    final direct = _asInt(
      d['id'] ??
          d['teacherAssessmentID'] ??
          d['teacherAssessmentId'] ??
          d['teacher_assessment_id'],
    );
    if (direct != null && direct > 0) return direct;
    final act = d['teacher_assessment_activation'];
    if (act is List && act.isNotEmpty) {
      final first = act.first;
      if (first is Map) {
        final v = _asInt(
          first['teacherAssessmentID'] ??
              first['teacherAssessmentId'] ??
              first['teacher_assessment_id'],
        );
        if (v != null && v > 0) return v;
      }
    }
    final sel = d['teacher_assessment_selection'];
    if (sel is List && sel.isNotEmpty) {
      final first = sel.first;
      if (first is Map) {
        final v = _asInt(
          first['teacherAssessmentID'] ??
              first['teacherAssessmentId'] ??
              first['teacher_assessment_id'],
        );
        if (v != null && v > 0) return v;
      }
    }
    return null;
  }

  Future<void> _loadMasteryFromRoute() async {
    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    final Map<String, dynamic>? args = (routeArgs is Map)
        ? Map<String, dynamic>.from(routeArgs)
        : null;

    final Map<String, dynamic>? assessment = (args?['assessment'] is Map)
        ? Map<String, dynamic>.from(args!['assessment'])
        : null;

    final Map<String, dynamic>? details =
        (assessment?['assessment_details'] is Map)
        ? Map<String, dynamic>.from(assessment!['assessment_details'])
        : null;

    int? teacherAssessmentID = _asInt(
      args?['teacherAssessmentID'] ??
          args?['teacherAssessmentId'] ??
          args?['teacher_assessment_id'],
    );
    teacherAssessmentID ??= _firstTeacherAssessmentIdFromDetails(details);
    teacherAssessmentID ??= _asInt(
      assessment?['id'] ??
          assessment?['teacherAssessmentID'] ??
          assessment?['teacherAssessmentId'] ??
          assessment?['teacher_assessment_id'],
    );

    int? assessmentId = _asInt(args?['assessmentId'] ?? args?['assessmentID']);
    assessmentId ??= _asInt(
      details?['assessmentID'] ?? details?['assessmentId'],
    );
    assessmentId ??= _asInt(
      assessment?['assessmentID'] ?? assessment?['assessmentId'],
    );

    _teacherAssessmentID = teacherAssessmentID;
    _assessmentId = assessmentId;

    if (_teacherAssessmentID == null || _teacherAssessmentID! <= 0) {
      setState(() => _error = 'Missing teacherAssessmentID in route args.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    final ApiResponse<Map<String, dynamic>> res =
        await StudentRemedialController.fetchRemedialMastery(
          teacherAssessmentID: _teacherAssessmentID!,
        );

    if (!mounted) return;

    if (res.success) {
      _masteryData = res.data ?? {};
      try {
        final pretty = const JsonEncoder.withIndent('  ').convert(res.data);
        _debugJson = pretty;
      } catch (_) {
        _debugJson = jsonEncode(res.data ?? {});
      }

      String? pill;
      final lp = res.data?['learners_profile'];
      if (lp is List && lp.isNotEmpty) {
        final first = lp.first;
        if (first is Map) {
          final name = first['learners_type_name'];
          if (name is String && name.trim().isNotEmpty) {
            pill = '${name.trim()} Learner';
          }
        }
      }

      setState(() {
        _loading = false;
        if (pill != null) _learnerPillLabel = pill;
      });
    } else {
      setState(() {
        _loading = false;
        _error = res.message ?? 'Failed to fetch mastery.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final w = mq.size.width;
    final h = mq.size.height;

    final titleSize = _clamp(w * 0.050, 25, 25);
    final pillPaddingH = _clamp(w * 0.06, 18, 26);
    final pillHeight = _clamp(h * 0.055, 38, 46);
    final sidePad = _clamp(w * 0.08, 20, 28);
    final titleTop = _clamp(h * 0.15, 104, 170);

    final derivedLearner = _learnerPillLabel;

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
                Positioned(
                  left: -w * (1.7 - 1) / 2,
                  right: -w * (1.7 - 1) / 2,
                  bottom: -_clamp(h * 0.35, 200, 340),
                  child: IgnorePointer(
                    ignoring: true,
                    child: SizedBox(
                      height: _clamp(h * 1.95, 900, 1800),
                      child: OverflowBox(
                        minWidth: w * 1.7,
                        maxWidth: w * 1.7,
                        minHeight: _clamp(h * 1.65, 900, 1800),
                        maxHeight: _clamp(h * 1.65, 900, 1800),
                        child: Image.asset(
                          widget.imageAsset,
                          fit: BoxFit.contain,
                          alignment: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: sidePad,
                  right: sidePad,
                  top: titleTop,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Let's Correct the\n Exercises you missed!",
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
                              derivedLearner,
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
                          color: Colors.white,
                          child: InkWell(
                            onTap:
                                (_teacherAssessmentID == null ||
                                    _masteryData == null)
                                ? null
                                : () {
                                    Navigator.of(
                                      context,
                                    ).pushNamedAndRemoveUntil(
                                      AppRoutes.remedialQuiz,
                                      (route) => false,
                                      arguments: {
                                        'teacherAssessmentID':
                                            _teacherAssessmentID,
                                        'assessmentId': _assessmentId,
                                        'mastery': _masteryData,
                                      },
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
                if (_loading)
                  const Positioned(
                    left: 16,
                    top: 12,
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                  ),
                if (_error != null)
                  Positioned(
                    left: 16,
                    right: 16,
                    top: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _error!,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                if (_debugJson != null)
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: _clamp(h * 0.12, 80, 140),
                    child: Opacity(
                      opacity: 0.85,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: BoxConstraints(
                          maxHeight: _clamp(h * 0.25, 120, 220),
                        ),
                        child: SingleChildScrollView(
                          child: Text(
                            _debugJson!,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              height: 1.2,
                              fontFamily: 'monospace',
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
