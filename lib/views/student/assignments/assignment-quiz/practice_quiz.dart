import 'package:flutter/material.dart';
import 'package:flutter_lms/config/routes.dart';
import 'package:google_fonts/google_fonts.dart';

class PracticeQuizPage extends StatefulWidget {
  const PracticeQuizPage({super.key});

  @override
  State<PracticeQuizPage> createState() => _PracticeQuizPageState();
}

class _PracticeQuizPageState extends State<PracticeQuizPage> {
  // ==== Sample questions ====
  final List<_Question> _questions = const [
    _Question(
      title:
          '1. What is the algebraic expression for "5 more than a number x"?',
      choices: ['5x', 'x + 5', 'x − 5', '5 − x'],
      correctIndex: 1,
      subject: 'Math 101 : Algebraic Expressions',
    ),
    _Question(
      title: '2. Which of the following is NOT an algebraic expression?',
      choices: ['5x', 'x + 5', '5 − x', '5 ÷ 0'],
      correctIndex: 3,
      subject: 'Math 101 : Algebraic Expressions',
    ),
    _Question(
      title: '3. Simplify the expression: 2x + 3x',
      choices: ['6x', '5x', 'x^2', '2x − 3x'],
      correctIndex: 1,
      subject: 'Math 101 : Algebraic Expressions',
    ),
  ];

  int _index = 0;
  int? _selected; // user tapped option index
  bool? _isCorrect; // null = unanswered, true/false after answer
  int _correctCount = 0; // add this at the top of the State

  _Question get q => _questions[_index];

  // Colors
  static const _blue = Color(0xFF234FF5);
  static const _cardBlue = Color(0xFF234FF5);
  static const _correct = Color(0xFF60C95D);
  static const _wrong = Color(0xFFDE5757);

  void _pick(int i) {
    if (_isCorrect != null) return; // already answered
    final ok = i == q.correctIndex;
    setState(() {
      _selected = i;
      _isCorrect = ok;
    });
  }

  void _next() {
    if (_index < _questions.length - 1) {
      // tally the answer for the current question before moving on
      if (_isCorrect == true) _correctCount++;

      setState(() {
        _index++;
        _selected = null;
        _isCorrect = null;
      });
    } else {
      // include last question's result
      if (_isCorrect == true) _correctCount++;

      // finished — go to results and clear back stack
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.practiceQuizResult,
        (route) => false,
        arguments: {
          'score': _correctCount,
          'total': _questions.length,
          'learnerLabel': 'Auditory Learner',
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final w = mq.size.width;
    final h = mq.size.height;

    final radius = 26.0;
    final answered = _isCorrect != null;
    final progress = (_index + 1) / _questions.length;

    // Card/CTA colors based on state
    final cardColor = !answered ? _cardBlue : (_isCorrect! ? _correct : _wrong);

    final ctaColor = _isCorrect == null
        ? Colors.transparent
        : (_isCorrect! ? _correct : _wrong);

    final ctaText = _isCorrect == null
        ? ''
        : (_isCorrect!
              ? 'Correct!'
              : 'Correct Answer\n${String.fromCharCode(0x41 + q.correctIndex)}. ${q.choices[q.correctIndex]}');

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: Column(
          children: [
            // ===== Header =====
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quiz 1',
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          q.subject,
                          style: GoogleFonts.poppins(
                            fontSize: 12.5,
                            color: Colors.black54,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _PracticeModeChip(),
                        const SizedBox(height: 52),
                      ],
                    ),
                  ),
                  // Counter
                  Text(
                    '${_index + 1}/${_questions.length}',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: const Color(0xFF2D2D2D).withOpacity(0.49),
                    ),
                  ),
                ],
              ),
            ),

            // ===== Section title =====
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Your Progress',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
            // Progress bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _ProgressBar(
                value: progress,
                active: _blue,
                background: Colors.black12,
              ),
            ),
            const SizedBox(height: 16),

            // ===== Question card (one at a time) =====
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: _QuestionCard(
                  key: ValueKey(_index * 10 + (_isCorrect == true ? 1 : 2)),
                  radius: radius,
                  color: cardColor,
                  title: q.title,
                  choices: q.choices,
                  selected: _selected,
                  correctIndex: q.correctIndex,
                  answered: answered,
                  onPick: _pick,
                ),
              ),
            ),

            // Push CTA to bottom
            const SizedBox(height: 12),
            const Spacer(),

            // ===== Bottom CTA (appears only after answering) =====
            Padding(
              padding: const EdgeInsets.only(
                left: 12.0,
                right: 12.0,
                bottom: 12.0,
              ),
              child: SafeArea(
                top: false,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  height: _isCorrect == null ? 0 : 68,
                  margin: const EdgeInsets.fromLTRB(18, 8, 18, 14),
                  decoration: BoxDecoration(
                    color: ctaColor,
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: _isCorrect == null
                        ? null
                        : [
                            BoxShadow(
                              color: ctaColor.withOpacity(0.35),
                              blurRadius: 18,
                              offset: const Offset(0, 10),
                            ),
                          ],
                  ),
                  child: _isCorrect == null
                      ? const SizedBox.shrink()
                      : InkWell(
                          borderRadius: BorderRadius.circular(26),
                          onTap: _next,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Icon(
                                    _isCorrect!
                                        ? Icons.check_rounded
                                        : Icons.close_rounded,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    ctaText,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: _isCorrect! ? 22 : 16,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Colors.white,
                                  size: 26,
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ====== Widgets ======

class _PracticeModeChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFF1F5BFF), width: 1.4),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.hearing_rounded, color: Color(0xFF1F5BFF), size: 18),
          const SizedBox(width: 8),
          Text(
            'Practice Mode',
            style: GoogleFonts.poppins(
              color: const Color(0xFF1F5BFF),
              fontWeight: FontWeight.w600,
              fontSize: 13.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({
    required this.value,
    required this.active,
    required this.background,
  });

  final double value;
  final Color active;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 8,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: LayoutBuilder(
          builder: (context, c) {
            final w = c.maxWidth;
            return Stack(
              children: [
                Container(color: background),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: w * value.clamp(0, 1),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [active, active.withOpacity(0.75)],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    super.key,
    required this.radius,
    required this.color,
    required this.title,
    required this.choices,
    required this.selected,
    required this.correctIndex,
    required this.answered,
    required this.onPick,
  });

  final double radius;
  final Color color;
  final String title;
  final List<String> choices;
  final int? selected;
  final int correctIndex;
  final bool answered;
  final void Function(int index) onPick;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.fromLTRB(
        22,
        22,
        22,
        18,
      ), // ⬅️ more top/side padding
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question text
          Text(
            title,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          // Answer choices
          for (int i = 0; i < choices.length; i++) ...[
            _AnswerTile(
              label: String.fromCharCode(0x41 + i),
              text: choices[i],
              selected: selected == i,
              showResult: answered,
              isCorrect: i == correctIndex,
              onTap: () => onPick(i),
            ),
            if (i != choices.length - 1)
              const SizedBox(height: 8), // ⬅️ tighter gap
          ],
        ],
      ),
    );
  }
}

class _AnswerTile extends StatelessWidget {
  const _AnswerTile({
    required this.label,
    required this.text,
    required this.selected,
    required this.showResult,
    required this.isCorrect,
    required this.onTap,
  });

  final String label;
  final String text;
  final bool selected;
  final bool showResult;
  final bool isCorrect;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const correctBase = Color(0xFF4FB24B);
    const wrongBase = Color(0xFFDE4545);

    final Color textColor = showResult
        ? Colors.white
        : (selected ? Colors.white : Colors.white.withOpacity(0.9));

    // Idle = soft white; after answer = darker green/red
    final Color pillColor = showResult
        ? (isCorrect ? correctBase : wrongBase)
        : Colors.white.withOpacity(0.20);

    return InkWell(
      onTap: showResult ? null : onTap,
      borderRadius: BorderRadius.circular(8),
      hoverColor: const Color(0xFF0A3D91).withOpacity(0.15),
      highlightColor: const Color(0xFF0A3D91).withOpacity(0.25),
      splashColor: const Color(0xFF0A3D91).withOpacity(0.20),

      // ✅ keep EXACT padding; pill will extend beyond via negative insets
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 32),
        child: Stack(
          clipBehavior: Clip.none, // <-- allow pill to extend beyond padding
          alignment: Alignment.centerLeft,
          children: [
            if (selected)
              Positioned.fill(
                left: -32,
                right: -32,
                top: -8, // make pill taller by pulling top upward
                bottom: -8, // make pill taller by pulling bottom downward
                child: Container(
                  decoration: BoxDecoration(
                    color: pillColor,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: showResult
                        ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ]
                        : null,
                  ),
                ),
              ),

            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '$label.',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: textColor,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    text,
                    style: GoogleFonts.poppins(
                      color: textColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ===== Model =====
class _Question {
  final String title;
  final List<String> choices;
  final int correctIndex;
  final String subject;
  const _Question({
    required this.title,
    required this.choices,
    required this.correctIndex,
    required this.subject,
  });
}
