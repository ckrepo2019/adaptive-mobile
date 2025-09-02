// lib/views/student/quizzes/remedial_quiz.dart
import 'package:flutter/material.dart';
import 'package:flutter_lms/config/routes.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_lms/widgets/app_bar.dart';

class RemedialQuizPage extends StatefulWidget {
  const RemedialQuizPage({super.key});

  @override
  State<RemedialQuizPage> createState() => _RemedialQuizPageState();
}

class _RemedialQuizPageState extends State<RemedialQuizPage> {
  // ===== DATA (3 questions) =====
  final List<String> _questions = const [
    "Which is the simplest expression for 4x + 2x ?",
    "What is 3a + 5a ?",
    "Simplify: 7y + y",
  ];

  final List<List<String>> _choices = const [
    ["4x", "6x", "8x", "4x + x + x"],
    ["8a", "35a", "3a + 5a", "2a"],
    ["7y", "8y", "y7", "y + 7"],
  ];

  final List<int> _correctIndexPerQ = const [1, 0, 1];

  final List<String> _explanations = const [
    "Combine like terms: 4x + 2x = 6x because 4 + 2 = 6 and x is common.",
    "Combine like terms: 3a + 5a = 8a.",
    "7y + y = 8y since 7 + 1 = 8 and y is common.",
  ];

  // ===== STATE =====
  int _qIndex = 0;
  int? _selectedIndex;

  bool get _hasSelection => _selectedIndex != null;
  bool get _isCorrect => _selectedIndex == _correctIndexPerQ[_qIndex];

  void _select(int index) {
    if (_selectedIndex != null) return; // lock after first tap
    setState(() => _selectedIndex = index);
  }

  void _goNext() {
    if (_qIndex < _questions.length - 1) {
      setState(() {
        _qIndex += 1;
        _selectedIndex = null;
      });
    } else {
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.remedialQuizResult,
        (route) => false,
        arguments: {},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final orange = const Color(0xFFFF8A00);
    final green = const Color(0xFF22C55E);
    final blue = const Color(0xFF2B50FF);

    final header = Row(
      children: [
        Icon(Icons.refresh_rounded, color: orange, size: 20),
        const SizedBox(width: 6),
        Text(
          'Previous Mistake',
          style: GoogleFonts.poppins(
            color: orange,
            fontSize: 15.5,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Spacer(),
        Text(
          '${_qIndex + 1}/${_questions.length}',
          style: GoogleFonts.poppins(
            color: Colors.black38, // lighter gray
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );

    final questionCard = Material(
      color: Colors.white,
      elevation: 5, // stronger drop shadow
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Numbered question
            Text(
              "${_qIndex + 1}. ${_questions[_qIndex]}",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 14),
            for (int i = 0; i < _choices[_qIndex].length; i++) ...[
              _ChoiceTile(
                index: i,
                label: _choices[_qIndex][i],
                selected: _selectedIndex == i,
                correct: i == _correctIndexPerQ[_qIndex],
                state: _tileStateFor(i),
                onSelect: _select,
              ),
              if (i != _choices[_qIndex].length - 1) const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );

    final continueButton = SizedBox(
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        onPressed: _goNext,
        child: Text(
          'Continue',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9),
      appBar: const GlobalAppBar(
        title: 'Review & Master',
        showNotifications: false,
        showProfile: false,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
        child: _hasSelection
            ? ListView(
                children: [
                  header,
                  const SizedBox(height: 12),
                  questionCard,
                  if (_hasSelection && !_isCorrect) ...[
                    const SizedBox(height: 14),
                    _ExplanationBlock(
                      titleColor: green,
                      title: 'Explanation',
                      body: _explanations[_qIndex],
                    ),
                  ],
                  const SizedBox(height: 14),
                  continueButton,
                ],
              )
            : LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            header,
                            const SizedBox(height: 12),
                            questionCard,
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  _ChoiceVisualState _tileStateFor(int i) {
    if (_selectedIndex == null) return _ChoiceVisualState.neutral;
    final correct = _correctIndexPerQ[_qIndex];
    if (i == correct && _selectedIndex == correct) {
      return _ChoiceVisualState.correctSelected;
    }
    if (i == correct && _selectedIndex != correct) {
      return _ChoiceVisualState.correctUnselected;
    }
    if (i == _selectedIndex && _selectedIndex != correct) {
      return _ChoiceVisualState.wrongSelected;
    }
    return _ChoiceVisualState.neutral;
  }
}

enum _ChoiceVisualState {
  neutral,
  correctSelected,
  correctUnselected,
  wrongSelected,
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.index,
    required this.label,
    required this.selected,
    required this.correct,
    required this.state,
    required this.onSelect,
  });

  final int index;
  final String label;
  final bool selected;
  final bool correct;
  final _ChoiceVisualState state;
  final void Function(int index) onSelect;

  @override
  Widget build(BuildContext context) {
    final green = const Color(0xFF22C55E);
    final red = const Color(0xFFE53935);

    Color bg;
    IconData? tail;

    switch (state) {
      case _ChoiceVisualState.correctSelected:
        bg = green.withOpacity(0.15);
        tail = Icons.check_circle_rounded;
        break;
      case _ChoiceVisualState.correctUnselected:
        bg = green.withOpacity(0.08);
        tail = Icons.check_circle_outline_rounded;
        break;
      case _ChoiceVisualState.wrongSelected:
        bg = red.withOpacity(0.12);
        tail = Icons.cancel_rounded;
        break;
      case _ChoiceVisualState.neutral:
      default:
        bg = Colors.white;
    }

    final letter = String.fromCharCode(65 + index);

    return InkWell(
      onTap: () => onSelect(index),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: () {
              switch (state) {
                case _ChoiceVisualState.correctSelected:
                  return const Color(0xFF22C55E);
                case _ChoiceVisualState.correctUnselected:
                  return const Color(0xFF22C55E).withOpacity(0.8);
                case _ChoiceVisualState.wrongSelected:
                  return const Color(0xFFE53935);
                default:
                  return const Color.fromARGB(0, 255, 255, 255);
              }
            }(),
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            // Flat letter (no circle)
            Text(
              "$letter.",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w800,
                fontSize: 13,
                color: Colors.black,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            if (tail != null) ...[
              const SizedBox(width: 10),
              Icon(
                tail,
                size: 20,
                color: state == _ChoiceVisualState.wrongSelected
                    ? red
                    : const Color(0xFF22C55E),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ExplanationBlock extends StatefulWidget {
  const _ExplanationBlock({
    required this.titleColor,
    required this.title,
    required this.body,
  });

  final Color titleColor;
  final String title;
  final String body;

  @override
  State<_ExplanationBlock> createState() => _ExplanationBlockState();
}

class _ExplanationBlockState extends State<_ExplanationBlock>
    with TickerProviderStateMixin {
  bool _expanded = true; // default expanded

  void _toggle() => setState(() => _expanded = !_expanded);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: widget.titleColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: widget.titleColor.withOpacity(0.8),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row
            Row(
              children: [
                Icon(
                  Icons.psychology_rounded,
                  color: widget.titleColor,
                  size: 30,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w800,
                    fontSize: 18.5,
                    color: widget.titleColor,
                  ),
                ),
                const Spacer(),
                Icon(
                  _expanded
                      ? Icons.expand_less_rounded
                      : Icons.expand_more_rounded,
                  color: const Color(0xFF22C55E),
                  size: 25,
                ),
              ],
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeInOut,
              child: _expanded
                  ? Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        widget.body,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.black87,
                          height: 1.4,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
