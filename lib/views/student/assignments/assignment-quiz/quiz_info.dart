import 'package:flutter/material.dart';
import 'package:flutter_lms/config/routes.dart';
import 'package:flutter_lms/widgets/app_bar.dart'; // your GlobalAppBar path
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_lms/controllers/student/student_subject.dart';
import 'package:flutter_lms/controllers/api_response.dart';

class QuizInfoItem {
  final String title;
  final String subject;
  final String date;
  final String duration;
  final String? description;
  final String type; // e.g., 'Quiz', 'Assignment', 'Essay'
  const QuizInfoItem({
    required this.title,
    required this.subject,
    required this.date,
    required this.duration,
    required this.type,
    this.description,
  });
}

class QuizInfoPage extends StatefulWidget {
  const QuizInfoPage({super.key});

  @override
  State<QuizInfoPage> createState() => _QuizInfoPageState();
}

class _QuizInfoPageState extends State<QuizInfoPage> {
  // route-provided fallbacks
  late String _title;
  late String _subject;
  late String _date;
  late String _duration;
  late String _description;
  late String _type;

  int? _assessmentId; // teacherAssessmentID
  bool _fetchStarted = false;

  // fetched/passed backend JSON blob
  Map<String, dynamic>? _assessmentData;

  // ensure we only redirect once
  bool _redirected = false;

  double _clamp(double v, double min, double max) =>
      v < min ? min : (v > max ? max : v);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is QuizInfoItem) {
      _title = args.title;
      _subject = args.subject;
      _date = args.date;
      _duration = args.duration;
      _type = args.type;
      _description = args.description?.trim().isNotEmpty == true
          ? args.description!
          : _defaultDescription();
    } else if (args is Map) {
      _title = (args['title'] ?? '').toString();
      _subject = (args['subject'] ?? '').toString();
      _date = (args['date'] ?? '').toString();
      _duration = (args['duration'] ?? '').toString();
      _type = (args['type'] ?? '').toString();
      _description = (args['description'] as String?)?.trim().isNotEmpty == true
          ? args['description'] as String
          : _defaultDescription();

      // teacherAssessmentID
      final dynamic rawId = args['teacherAssessmentID'] ?? args['id'];
      if (rawId != null) {
        final parsed = int.tryParse(rawId.toString());
        if (parsed != null && parsed > 0) {
          _assessmentId = parsed;
          debugPrint('Received assessment id: $_assessmentId');
        }
      }

      // Optional: full assessment already passed in
      final dynamic incomingAssessment = args['assessment'];
      if (incomingAssessment is Map) {
        _assignmentSetAndMaybeRedirect(
          Map<String, dynamic>.from(incomingAssessment),
        );
      }
    } else {
      _title = 'Quadratic Equations';
      _subject = 'Math Quiz 1';
      _date = 'Today, 3:00 PM';
      _duration = '20 min';
      _type = 'Quiz';
      _description = _defaultDescription();
    }

    // If we didn't get full data but have an id, fetch
    if (!_fetchStarted &&
        _assessmentData == null &&
        _assessmentId != null &&
        _assessmentId! > 0) {
      _fetchStarted = true;
      _fetchAssessment(_assessmentId!);
    }
  }

  // ---------------- Helpers: score detection + redirect ----------------

  bool _hasComputedScore(Map<String, dynamic>? assessment) {
    if (assessment == null) return false;
    final ascore = assessment['assessment_score'];
    if (ascore is Map) {
      final s = ascore['score'];
      if (s is num) return true;
      if (s is String && num.tryParse(s) != null) return true;
    }
    return false;
  }

  void _goToResult(Map<String, dynamic> assessment) {
    if (_redirected) return;
    _redirected = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.quizResult,
        (route) => false,
        arguments: {
          'assessment': assessment, // pass whole blob
        },
      );
    });
  }

  void _assignmentSetAndMaybeRedirect(Map<String, dynamic> data) {
    _assessmentData = data;
    if (_hasComputedScore(_assessmentData)) {
      _goToResult(_assessmentData!);
    } else {
      setState(() {}); // just to refresh UI with fetched data
    }
  }

  // ---------------- Backend fetch ----------------

  Future<void> _fetchAssessment(int teacherAssessmentId) async {
    try {
      final ApiResponse<Map<String, dynamic>> res =
          await StudentSubjectController.fetchAssessmentDetails(
            teacherAssessmentId: teacherAssessmentId,
          );

      if (!mounted) return;

      if (res.success && res.data != null) {
        debugPrint('[assessmentJson] SUCCESS: ${res.data!.keys.toList()}');
        _assignmentSetAndMaybeRedirect(res.data!);
      } else {
        debugPrint('[assessmentJson] ERROR: ${res.message}');
      }
    } catch (e) {
      debugPrint('[assessmentJson] EXCEPTION: $e');
    }
  }

  // --------- Derivers from backend JSON ---------
  String get _assessmentName {
    final n = _assessmentData?['assessment_details']?['assessment_name'];
    return (n is String && n.trim().isNotEmpty) ? n : _title;
  }

  String get _assessmentDescription {
    final d = _assessmentData?['assessment_details']?['assessment_description'];
    if (d is String && d.trim().isNotEmpty) return d;
    return _description;
  }

  int? get _passingRate {
    final p = _assessmentData?['assessment_details']?['passingrate'];
    if (p is num) return p.toInt();
    return int.tryParse('${p ?? ''}');
  }

  Map<String, dynamic>? get _settings {
    final s =
        _assessmentData?['assessment_details']?['teacher_assessment_settings'];
    if (s is List && s.isNotEmpty && s.first is Map) {
      return Map<String, dynamic>.from(s.first);
    }
    return null;
  }

  String get _durationFromBackend {
    final h = _settings?['duration_hours'];
    final m = _settings?['duration_minutes'];
    final hh = (h is num) ? h.toInt() : int.tryParse('${h ?? ''}') ?? 0;
    final mm = (m is num) ? m.toInt() : int.tryParse('${m ?? ''}') ?? 0;

    if (hh == 0 && mm == 0) return _duration;
    final parts = <String>[];
    if (hh > 0) parts.add('$hh ${hh == 1 ? "hour" : "hours"}');
    if (mm > 0) parts.add('$mm ${mm == 1 ? "min" : "mins"}');
    return parts.isEmpty ? '0 min' : parts.join(' ');
  }

  String _defaultDescription() => '''
This quiz helps you learn how to solve quadratic equations — those with an x² term — using simple, step-by-step methods.

You'll start by identifying the standard form:
ax² + bx + c = 0

Then, you'll explore four ways to solve them:
• Factoring (when numbers split easily)
• Using square roots (when there’s no bx term)
• Completing the square (to form a perfect square)
• The quadratic formula (a method that works every time)

You'll also learn about the discriminant (b² - 4ac), which tells you how many solutions there are — two, one, or none.

By the end of this quiz, you'll understand how to match the approach to the details of the problem and solve quickly with confidence.
''';

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final w = mq.size.width;

    final padX = _clamp(w * 0.06, 16, 24);
    final titleSize = _clamp(w * 0.065, 20, 28);
    final aboutSize = _clamp(w * 0.050, 16, 20);
    final bodySize = _clamp(w * 0.040, 13, 15);

    final textTheme = GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme);

    // derived / fallback values for display
    final bannerTitle = _assessmentName; // from backend
    final aboutText = _assessmentDescription; // from backend
    final shownDuration = _durationFromBackend; // from backend settings

    final bool alreadyGraded = _hasComputedScore(_assessmentData);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: GlobalAppBar(
        centerTitle: true,
        title: 'Quiz Info',
        showBack: true,
        onBack: () => Navigator.maybePop(context),
        showProfile: false,
        showNotifications: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(padX, 12, padX, 24),
          children: [
            // Banner showing subject + assessment_name
            _BannerCard(
              subject: _subject.isEmpty ? 'Subject' : _subject,
              title: bannerTitle.isEmpty ? _title : bannerTitle,
              type: _type.isEmpty ? 'Quiz' : _type,
            ),

            const SizedBox(height: 14),

            // Passing Rate pill (stylish)
            if (_passingRate != null)
              _PassingRatePill(passingRate: _passingRate!),

            const SizedBox(height: 18),

            // About Heading
            Text(
              'About this Quiz',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.black87,
                fontSize: aboutSize,
              ),
            ),
            const SizedBox(height: 8),

            // Body Copy (assessment_description)
            Text(
              aboutText.trim(),
              style: textTheme.bodyMedium?.copyWith(
                height: 1.5,
                color: const Color(0xFF777777),
                fontSize: bodySize,
              ),
            ),

            const SizedBox(height: 20),

            // Meta (Date • Duration)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x12000000),
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: DefaultTextStyle(
                style: textTheme.bodyMedium!.copyWith(color: Colors.black87),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 18,
                      color: Colors.black54,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _date.isEmpty ? '—' : _date,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.access_time_outlined,
                      size: 18,
                      color: Colors.black54,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      shownDuration,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // Sticky CTA — if graded, "View Result" → results; else "Take Quiz" → intro
      bottomNavigationBar: SafeArea(
        minimum: EdgeInsets.fromLTRB(padX, 8, padX, 12),
        child: SizedBox(
          height: 52,
          width: double.infinity,
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF234FF5), Color(0xFF142E8F)],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: ElevatedButton(
              onPressed: () {
                if (alreadyGraded && _assessmentData != null) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.quizResult,
                    (route) => false,
                    arguments: {'assessment': _assessmentData},
                  );
                  return;
                }
                // Bulk pass-through for taking the quiz
                Navigator.pushNamed(
                  context,
                  AppRoutes.quizIntro,
                  arguments: {
                    'teacherAssessmentID': _assessmentId,
                    'assessment':
                        _assessmentData, // entire JSON blob (may be null)
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                alreadyGraded ? 'View Result' : 'Take Quiz',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: titleSize * 0.62,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Stylish Passing Rate pill
class _PassingRatePill extends StatelessWidget {
  final int passingRate;
  const _PassingRatePill({required this.passingRate});

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme);
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF34D399), Color(0xFF059669)], // green gradient
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(999),
          boxShadow: const [
            BoxShadow(
              color: Color(0x22059669),
              blurRadius: 10,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.verified, size: 18, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              'Passing Rate: $passingRate%',
              style: textTheme.labelLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Banner that always uses the built-in asset:
/// assets/images/assignments/assignment-icon.png
class _BannerCard extends StatelessWidget {
  final String subject;
  final String title;
  final String type;

  const _BannerCard({
    required this.subject,
    required this.title,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final w = mq.size.width;
    final h = _clamp(mq.size.height * 0.18, 128, 176);

    final leftPad = _clamp(w * 0.07, 20, 26);
    final imagePadding = _clamp(w * 0.04, 12, 18);
    final subjectFs = _clamp(h * 0.12, 12, 15);
    final titleFs = _clamp(h * 0.20, 25, 20);

    final textTheme = GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme);

    return Container(
      height: h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x15000000),
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF234FF5), Color(0xFF142E8F)],
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // LEFT: subject + title
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: leftPad),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${subject.isEmpty ? "Subject" : subject} ${type.isEmpty ? "Quiz" : type}',
                    style: textTheme.labelMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: subjectFs,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title.isEmpty ? 'Untitled Assessment' : title,
                    softWrap: true,
                    maxLines: null,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      height: 1.05,
                      fontSize: titleFs,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // RIGHT: image
          Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                0,
                imagePadding * 0.01,
                imagePadding * 0.1,
                imagePadding * 0.01,
              ),
              child: Image.asset(
                'assets/images/assignments/assignment-icon.png',
                fit: BoxFit.contain,
                height: h - imagePadding * 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _clamp(double v, double min, double max) =>
      v < min ? min : (v > max ? max : v);
}
