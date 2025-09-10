import 'package:flutter/material.dart';
import 'package:Adaptive/config/routes.dart';
import 'components/intro_theme.dart';
import 'components/centered_column.dart';
import 'components/typography.dart';
import 'components/hobbies_step.dart';
import 'components/thumbs_step.dart';
import 'components/intro_footer.dart';
import '../../../controllers/student/student_home.dart';

class LearnerQuestion {
  final int id;
  final String text;
  final int number;
  const LearnerQuestion({
    required this.id,
    required this.number,
    required this.text,
  });
}

class IntroductionPage extends StatefulWidget {
  const IntroductionPage({super.key});

  @override
  State<IntroductionPage> createState() => _IntroductionPageState();
}

class _IntroductionPageState extends State<IntroductionPage> {
  int get totalPages => 3 + _questions.length;
  final PageController _pageController = PageController();
  int _currentPage = 0;
  String? _token;
  int? _userType;
  int? _syID;
  int? _learnerAssessmentID;
  bool _submitting = false;

  int? _coerceInt(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    if (v is Map) {
      final m = v.cast<String, dynamic>();
      return _coerceInt(
        m['id'] ??
            m['value'] ??
            m['syID'] ??
            m['learnerassessmentID'] ??
            m['learner_assessment_id'],
      );
    }
    return null;
  }

  final Set<int> _selectedHobbyIds = {};

  Map<String, dynamic>? _studentHomeData;
  List<HobbyChipData> _backendHobbies = const <HobbyChipData>[];
  List<LearnerQuestion> _questions = const <LearnerQuestion>[]; // <-- NEW
  final Map<int, bool> _answers = {}; // <-- NEW

  bool _printed = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<LearnerQuestion> _extractLearnerQuestions(Map<String, dynamic> d) {
    final raw = (d['learner_questions'] as List?)?.cast<dynamic>() ?? const [];
    final out = <LearnerQuestion>[];
    final seen = <int>{};
    var i = 0;
    for (final q in raw) {
      final qm = (q as Map).cast<String, dynamic>();
      final id = (qm['id'] as num?)?.toInt();
      final text = (qm['question_text'] ?? '').toString().trim();
      final number = (qm['question_number'] as num?)?.toInt() ?? (i + 1);
      i++;
      if (id == null || id <= 0 || text.isEmpty) continue;
      if (seen.add(id)) {
        out.add(LearnerQuestion(id: id, number: number, text: text));
      }
    }
    return out;
  }

  List<HobbyChipData> _extractHobbiesWithIds(
    Map<String, dynamic> d, {
    String sep = ' • ',
  }) {
    final types = (d['hobbies_type'] as List?)?.cast<dynamic>() ?? const [];
    final out = <HobbyChipData>[];
    final seenIds = <int>{};

    for (final t in types) {
      final tm = (t as Map).cast<String, dynamic>();
      final typeName = (tm['name'] ?? '').toString().trim();
      final hobbies = (tm['hobbies'] as List?)?.cast<dynamic>() ?? const [];

      for (final h in hobbies) {
        final hm = (h as Map).cast<String, dynamic>();
        final id = (hm['id'] as num?)?.toInt();
        final name = (hm['name'] ?? '').toString().trim();
        if (id == null || id <= 0 || name.isEmpty) continue;

        final label = typeName.isNotEmpty ? '$name$sep$typeName' : name;
        if (seenIds.add(id)) {
          out.add(HobbyChipData(id: id, label: label));
        }
      }
    }
    return out;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_printed) return;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      if (args['studentHomeData'] is Map) {
        _studentHomeData = Map<String, dynamic>.from(
          args['studentHomeData'] as Map,
        );
        _backendHobbies = _extractHobbiesWithIds(_studentHomeData!);
        _questions = _extractLearnerQuestions(_studentHomeData!);

        _syID ??= _coerceInt(_studentHomeData!['sy']);
        _learnerAssessmentID ??= _coerceInt(
          _studentHomeData!['learner_assessment'],
        );

        _syID ??= _coerceInt(_studentHomeData!['syID']);
        _learnerAssessmentID ??= _coerceInt(
          _studentHomeData!['learnerassessmentID'],
        );
      }

      _syID ??= _coerceInt(args['syID']);

      _learnerAssessmentID ??= _coerceInt(args['learner_assessment']);
      _learnerAssessmentID ??= _coerceInt(args['learnerassessmentID']);

      _token = args['token'] as String?;
      _userType = args['userType'] as int?;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_printed) return;
      _printed = true;

      if (_studentHomeData == null) {
        debugPrint('[Intro] No studentHomeData received. args=$args');
      }
    });
  }

  void _nextPage() {
    if (_currentPage < totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      if (!_submitting) _submitGetStarted();
    }
  }

  void _onDotTap(int index) {
    if (index < _currentPage) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onThumbSelect(bool isUp) {}

  void _onQuestionAnswer(int qid, bool isUp) {
    setState(() {
      _answers[qid] = isUp;
    });
    debugPrint('[LEARNER_Q] id=$qid answer=${isUp ? 'up' : 'down'}');
  }

  Future<void> _submitGetStarted() async {
    if (_syID == null || _learnerAssessmentID == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Missing school year or assessment ID.')),
      );
      return;
    }

    final responses = _questions.map((q) {
      final isUp = _answers[q.id] == true;
      return {
        'question_id': q.id,
        'question_number': q.number,
        'answer': isUp ? 'yes' : 'no',
      };
    }).toList();

    setState(() => _submitting = true);
    try {
      final res = await StudentHomeController.submitGetStarted(
        token: _token,
        syID: _syID!,
        learnerAssessmentID: _learnerAssessmentID!,
        responses: responses,
        hobbies: _selectedHobbyIds.toList(),
      );

      if (res.success) {
        int? studentId;
        final studentData = _studentHomeData?['student'];
        if (studentData is Map) {
          studentId = (studentData['id'] as num?)?.toInt();
        }

        Navigator.pushReplacementNamed(
          context,
          AppRoutes.analyzing,
          arguments: {'studentId': studentId},
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(res.message ?? 'Submit failed')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Network error: $e')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isHobbyPage = (_currentPage == 2);
    final Color scaffoldBg = isHobbyPage ? Colors.white : IntroTheme.blue;

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: totalPages,
              physics: const PageScrollPhysics(),
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 80),
                  child: _buildPage(index),
                );
              },
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 84,
                color: IntroTheme.blue,
                child: IntroFooter(
                  total: totalPages,
                  current: _currentPage,
                  onNext: _nextPage,
                  activeColor: Colors.white,
                  inactiveColor: Colors.white.withOpacity(0.35),
                  textColor: Colors.white,
                  isLast: _currentPage == totalPages - 1,
                  onDotTap: _onDotTap,
                  maxVisibleDots: 4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return Container(
          color: IntroTheme.blue,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: const CenteredColumn(
            children: [
              Spacer(),
              TitleSmall(
                'Welcome to your adaptive learning.',
                color: Colors.white,
              ),
              SizedBox(height: 10),
              TitleLarge('Learn smarter\nNot Harder!', color: Colors.white),
              Spacer(),
            ],
          ),
        );
      case 1:
        return Container(
          color: IntroTheme.blue,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: const CenteredColumn(
            children: [
              Spacer(),
              TitleMedium('Getting Started', color: Colors.white),
              SizedBox(height: 10),
              BodySmall(
                'Before we start, please take a moment to\n'
                'complete our assessment questionnaire.\n'
                'This will help us understand your learning\n'
                'style and create a personalized\n'
                'experience just for you.',
                color: Colors.white,
              ),
              Spacer(),
            ],
          ),
        );

      case 2:
        final List<HobbyChipData> items = _backendHobbies.isNotEmpty
            ? _backendHobbies
            : HobbyChipData.defaults();

        return HobbiesStep(
          hobbies: items,
          selectedIds: _selectedHobbyIds,
          onToggleId: (id) {
            setState(() {
              debugPrint('Selected Hobby IDs: $_selectedHobbyIds');
              if (_selectedHobbyIds.contains(id)) {
                _selectedHobbyIds.remove(id);
              } else {
                _selectedHobbyIds.add(id);
              }
            });
          },
        );

      case 3:
        return Container(
          color: IntroTheme.blue,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ThumbsStep(
            header: "Let's get to know each other",
            question:
                'Do you learn best when\ninformation is presented\nin charts or diagrams?',
            onThumbUp: () => _onThumbSelect(true),
            onThumbDown: () => _onThumbSelect(false),
            textColor: Colors.white,
          ),
        );

      default:
        final qIndex = index - 3;
        final q = _questions[qIndex];

        return Container(
          color: IntroTheme.blue,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ThumbsStep(
            header: "Let's get to know each other",
            question: q.text,
            onThumbUp: () => _onQuestionAnswer(q.id, true),
            onThumbDown: () => _onQuestionAnswer(q.id, false),
            textColor: Colors.white,
          ),
        );
    }
  }
}
