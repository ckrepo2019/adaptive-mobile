import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_lms/config/routes.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_lms/controllers/student/student_subject.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  Map<String, dynamic>? _args;
  Map<String, dynamic>? _assessment;
  Map<String, dynamic>? _details;
  List<dynamic> _sections = [];

  late final List<_Q> _allQs = [];

  final List<_AnswerRecord> _answers = [];

  final Map<int, int?> _selectedByQ = {};
  final Map<int, String> _textByQ = {};

  int _index = 0;

  final TextEditingController _idController = TextEditingController();

  bool _parsedOnce = false;

  int? _assessmentId;
  int _remaining = 0;
  Timer? _ticker;
  bool _initializing = true;
  bool _startingTimer = false;

  @override
  void initState() {
    super.initState();
    _idController.addListener(() {
      final qid = (_allQs.isEmpty) ? null : _allQs[_index].id;
      if (qid != null) {
        _textByQ[qid] = _idController.text;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _idController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_parsedOnce) return;

    final raw = ModalRoute.of(context)?.settings.arguments;
    if (raw is Map) {
      _args = Map<String, dynamic>.from(raw);
      _assessment = (_args!['assessment'] is Map)
          ? Map<String, dynamic>.from(_args!['assessment'])
          : null;

      _details = (_assessment?['assessment_details'] is Map)
          ? Map<String, dynamic>.from(_assessment!['assessment_details'])
          : null;

      _sections = (_assessment?['assessment_section'] is List)
          ? List<dynamic>.from(_assessment!['assessment_section'])
          : const [];

      _buildQuestionsFromAssessment();

      _assessmentId =
          int.tryParse(
            '${_details?['assessmentID'] ?? _assessment?['assessmentID'] ?? _args?['assessmentId'] ?? 0}',
          ) ??
          0;

      _initAssessmentSession();
    }

    _parsedOnce = true;
  }

  Future<void> _initAssessmentSession() async {
    if (_assessmentId == null || _assessmentId! <= 0) {
      _toast('Missing assessment ID.');
      setState(() => _initializing = false);
      return;
    }

    final remainingRes = await StudentSubjectController.getRemainingTime(
      assessmentId: _assessmentId!,
    );

    if (remainingRes.success && remainingRes.data != null) {
      final v = remainingRes.data!['time_left'];
      _remaining = (v is num) ? v.toInt() : int.tryParse('$v') ?? 0;
    } else {
      if (_startingTimer) return;
      _startingTimer = true;

      final fromArgs = int.tryParse('${_args?['timeLimitSeconds'] ?? ''}');
      final timeLimit = fromArgs ?? 1800;

      final startRes = await StudentSubjectController.startAssessmentTimer(
        assessmentId: _assessmentId!,
        timeLimitSeconds: timeLimit,
      );
      if (!startRes.success) {
        _toast(startRes.message ?? 'Failed to start timer.');
      }
      _remaining = timeLimit;
      _startingTimer = false;
    }

    final ansRes = await StudentSubjectController.getUserAnswers(
      assessmentId: _assessmentId!,
    );
    if (ansRes.success && ansRes.data != null) {
      _populateSavedAnswers(ansRes.data!);
    }

    _syncControllersForCurrent();

    _startTicker();

    setState(() => _initializing = false);
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_remaining <= 0) {
        setState(() => _remaining = 0);
        t.cancel();
      } else {
        setState(() => _remaining--);
      }
    });
  }

  void _populateSavedAnswers(List<Map<String, dynamic>> rows) {
    final byQ = <int, Map<String, dynamic>>{};
    for (final r in rows) {
      final qid = (r['questionID'] is num)
          ? (r['questionID'] as num).toInt()
          : int.tryParse('${r['questionID']}');
      if (qid == null) continue;
      byQ[qid] = r;
    }

    for (final q in _allQs) {
      final row = byQ[q.id];
      if (row == null) continue;

      final aText = (row['answer_text'] ?? row['student_answer']);
      if (aText != null && q.type == 'identification') {
        _textByQ[q.id] = aText.toString();
      }

      final rawChoices = row['choicesID'];
      if (rawChoices != null && q.choices.isNotEmpty) {
        final selectedChoiceId = (rawChoices is num)
            ? rawChoices.toInt()
            : int.tryParse('$rawChoices');
        if (selectedChoiceId != null) {
          final idx = q.choices.indexWhere((c) => c.id == selectedChoiceId);
          if (idx >= 0) _selectedByQ[q.id] = idx;
        }
      }
    }
  }

  void _syncControllersForCurrent() {
    final q = _allQs[_index];
    _idController.text = _textByQ[q.id] ?? '';
  }

  void _buildQuestionsFromAssessment() {
    _allQs.clear();
    if (_sections.isEmpty) return;

    for (final secRaw in _sections) {
      if (secRaw is! Map) continue;
      final sectionName = (secRaw['section_name'] ?? '').toString();
      final sectionDesc = (secRaw['description'] ?? '').toString();
      final questions = (secRaw['questions'] is List)
          ? List<dynamic>.from(secRaw['questions'])
          : const [];

      for (final qRaw in questions) {
        if (qRaw is! Map) continue;
        final qId = qRaw['id'];
        final qText = (qRaw['question_text'] ?? '').toString();
        final qType = (qRaw['type'] ?? '').toString();

        final choicesRaw = (qRaw['choices'] is List)
            ? List<dynamic>.from(qRaw['choices'])
            : const [];

        final normalized = <_Choice>[];
        for (final c in choicesRaw) {
          if (c is! Map) continue;
          final txt = (c['choices'] ?? '').toString().trim();
          final img = c['choice_image']?.toString();
          final isc = (c['is_correct']?.toString() ?? '0') == '1';
          final cid = c['id'];
          normalized.add(
            _Choice(
              id: cid is int ? cid : int.tryParse(cid?.toString() ?? ''),
              text: txt.replaceFirst(RegExp(r'^[A-D]\.\s*'), ''),
              isCorrect: isc,
              imagePath: (img != null && img.trim().isNotEmpty) ? img : null,
            ),
          );
        }

        _allQs.add(
          _Q(
            id: qId is int ? qId : int.tryParse(qId?.toString() ?? '') ?? 0,
            sectionName: sectionName,
            sectionDesc: sectionDesc,
            questionText: qText,
            type: qType,
            choices: normalized,
          ),
        );
      }
    }
  }

  _Q get q => _allQs[_index];
  int get _total => _allQs.length;

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg, style: GoogleFonts.poppins())));
  }

  void _pick(int i) {
    setState(() {
      _selectedByQ[q.id] = i;
    });
  }

  bool get _hasAnswerForCurrent {
    if (q.type == 'identification') {
      final txt = _textByQ[q.id] ?? _idController.text.trim();
      return txt.isNotEmpty;
    }
    return _selectedByQ[q.id] != null;
  }

  Future<void> _postCurrentAnswer() async {
    if (_assessmentId == null) return;

    if (q.type == 'identification') {
      final txt = _textByQ[q.id] ?? _idController.text.trim();
      final res = await StudentSubjectController.saveChoice(
        assessmentId: _assessmentId!,
        questionId: q.id,
        questionType: 'identification',
        answerText: txt,
      );
      if (!res.success) _toast(res.message ?? 'Failed to save answer.');
      _answers.add(
        _AnswerRecord(questionID: q.id, choiceID: null, answerText: txt),
      );
    } else {
      final idx = _selectedByQ[q.id];
      int? choiceId;
      if (idx != null && idx >= 0 && idx < q.choices.length) {
        choiceId = q.choices[idx].id;
      }
      final res = await StudentSubjectController.saveChoice(
        assessmentId: _assessmentId!,
        questionId: q.id,
        questionType: (q.type == 'true_false')
            ? 'true_false'
            : 'multiple_choice',
        choiceId: choiceId,
      );
      if (!res.success) _toast(res.message ?? 'Failed to save choice.');
      _answers.add(
        _AnswerRecord(questionID: q.id, choiceID: choiceId, answerText: null),
      );
    }
  }

  Future<void> _onContinue() async {
    if (_initializing) return;

    if (!_hasAnswerForCurrent) {
      _toast('Please answer the question first.');
      return;
    }

    await _postCurrentAnswer();

    if (_index < _total - 1) {
      setState(() {
        _index++;
      });
      _syncControllersForCurrent();
    } else {
      final summaryQuestions = _allQs
          .map(
            (qq) => {
              'id': qq.id,
              'text': qq.questionText,
              'type': qq.type,
              'choices': qq.choices
                  .map(
                    (c) => {'id': c.id, 'text': c.text, 'image': c.imagePath},
                  )
                  .toList(),
            },
          )
          .toList();

      final summaryAnswers = _answers
          .map(
            (a) => {
              'questionID': a.questionID,
              'choicesID': a.choiceID ?? 0,
              'answer_text': a.answerText,
            },
          )
          .toList();

      Navigator.pushNamed(
        context,
        AppRoutes.quizSummary,
        arguments: {
          'assessmentId': _assessmentId,
          'questions': summaryQuestions,
          'answers': summaryAnswers,
          'assessment': _assessment,
          'args': _args,
        },
      );
    }
  }

  void _onBackQuestion() {
    if (_index == 0 || _initializing) return;
    setState(() {
      _index--;
    });
    _syncControllersForCurrent();
  }

  Future<bool> _onWillPop() async {
    if (_assessmentId != null) {
      await StudentSubjectController.updateTimeLeft(
        assessmentId: _assessmentId!,
        timeLeftSeconds: _remaining,
      );
    }
    return true;
  }

  String _formatClock(int seconds) {
    if (seconds < 0) seconds = 0;
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    final mm = m.toString().padLeft(2, '0');
    final ss = s.toString().padLeft(2, '0');
    return h > 0 ? '$h:$mm:$ss' : '$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    final name =
        (_details?['assessment_name'] ??
                _assessment?['assessment_name'] ??
                'Quiz')
            .toString();
    final desc =
        (_details?['assessment_description'] ??
                _assessment?['assessment_description'] ??
                '')
            .toString();

    if (_allQs.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFF7F7F7),
        body: SafeArea(
          child: Center(
            child: Text(
              'No questions available.',
              style: GoogleFonts.poppins(fontSize: 16),
            ),
          ),
        ),
      );
    }

    const cardBlue = Color(0xFF234FF5);
    const blue = Color(0xFF234FF5);

    final progress = (_index + 1) / _total;
    final sectionTitle = q.sectionName.isEmpty ? 'Section' : q.sectionName;
    final sectionDesc = q.sectionDesc;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F7F7),
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        height: 1.1,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    if (desc.isNotEmpty)
                                      Text(
                                        desc,
                                        style: GoogleFonts.poppins(
                                          fontSize: 12.5,
                                          color: Colors.black54,
                                          height: 1.2,
                                        ),
                                      ),
                                    const SizedBox(height: 10),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.06),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.timer_outlined,
                                            size: 18,
                                            color: blue,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            _initializing
                                                ? 'Starting…'
                                                : _formatClock(_remaining),
                                            style: GoogleFonts.poppins(
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    const SizedBox(height: 36),
                                  ],
                                ),
                              ),
                              Text(
                                '${_index + 1}/$_total',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  color: const Color(
                                    0xFF2D2D2D,
                                  ).withOpacity(0.49),
                                ),
                              ),
                            ],
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              sectionTitle,
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                        if (sectionDesc.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 6),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                sectionDesc,
                                style: GoogleFonts.poppins(
                                  fontSize: 13.5,
                                  color: Colors.black54,
                                  height: 1.25,
                                ),
                              ),
                            ),
                          ),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _ProgressBar(
                            value: progress,
                            active: blue,
                            background: Colors.black12,
                          ),
                        ),
                        const SizedBox(height: 16),

                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                          child: _QuestionCard(
                            radius: 26,
                            color: cardBlue,
                            questionText: q.questionText,
                            type: q.type,
                            choices: q.choices,
                            selected: _selectedByQ[q.id],
                            onPick: _pick,
                            idController: _idController,
                          ),
                        ),

                        const Spacer(),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        bottomNavigationBar: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 14),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: (_index > 0 && !_initializing)
                        ? _onBackQuestion
                        : null,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: blue,
                      side: const BorderSide(color: blue, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.arrow_back_rounded, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Go back',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: (_hasAnswerForCurrent && !_initializing)
                        ? _onContinue
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF234FF5),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.black12,
                      disabledForegroundColor: Colors.white70,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _index == _total - 1 ? 'Submit' : 'Continue',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 22,
                          color: Colors.white,
                        ),
                      ],
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
    required this.radius,
    required this.color,
    required this.questionText,
    required this.type,
    required this.choices,
    required this.selected,
    required this.onPick,
    required this.idController,
  });

  final double radius;
  final Color color;
  final String questionText;
  final String type;
  final List<_Choice> choices;
  final int? selected;
  final void Function(int index) onPick;

  final TextEditingController idController;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
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
          Text(
            questionText,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),

          if (type == 'identification') ...[
            TextField(
              controller: idController,
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 15),
              decoration: InputDecoration(
                hintText: 'Type your answer...',
                hintStyle: GoogleFonts.poppins(color: Colors.white70),
                filled: true,
                fillColor: Colors.white.withOpacity(0.15),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ] else ...[
            for (int i = 0; i < choices.length; i++) ...[
              _ChoiceTile(
                label: String.fromCharCode(0x41 + i),
                text: choices[i].text,
                imageUrl: choices[i].imagePath,
                selected: selected == i,
                onTap: () => onPick(i),
              ),
              if (i != choices.length - 1) const SizedBox(height: 10),
            ],
          ],
        ],
      ),
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.label,
    required this.text,
    required this.imageUrl,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String text;
  final String? imageUrl;
  final bool selected;
  final VoidCallback onTap;

  bool get _hasImage => imageUrl != null && imageUrl!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final Color textColor = selected
        ? Colors.white
        : Colors.white.withOpacity(0.95);
    final Color pillColor = selected
        ? Colors.white.withOpacity(0.20)
        : Colors.white.withOpacity(0.12);

    final String fallbackText = (text.isNotEmpty ? text : 'Option $label');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      hoverColor: const Color(0xFF0A3D91).withOpacity(0.10),
      highlightColor: const Color(0xFF0A3D91).withOpacity(0.18),
      splashColor: const Color(0xFF0A3D91).withOpacity(0.16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.centerLeft,
          children: [
            if (selected)
              Positioned.fill(
                left: -8,
                right: -8,
                top: -8,
                bottom: -8,
                child: Container(
                  decoration: BoxDecoration(
                    color: pillColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.10),
                        blurRadius: 14,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                ),
              ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                    if (!_hasImage)
                      Expanded(
                        child: Text(
                          fallbackText,
                          style: GoogleFonts.poppins(
                            color: textColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),

                if (_hasImage) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      color: Colors.white.withOpacity(0.10),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Image.network(
                          imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stack) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Text(
                                  fallbackText,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    color: textColor,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            );
                          },
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return Center(
                              child: SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  valueColor: const AlwaysStoppedAnimation(
                                    Colors.white,
                                  ),
                                  value: progress.expectedTotalBytes != null
                                      ? (progress.cumulativeBytesLoaded /
                                            (progress.expectedTotalBytes ?? 1))
                                      : null,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  if (text.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      text,
                      style: GoogleFonts.poppins(
                        color: textColor.withOpacity(0.95),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Q {
  final int id;
  final String sectionName;
  final String sectionDesc;
  final String questionText;
  final String type;
  final List<_Choice> choices;

  _Q({
    required this.id,
    required this.sectionName,
    required this.sectionDesc,
    required this.questionText,
    required this.type,
    required this.choices,
  });
}

class _Choice {
  final int? id;
  final String text;
  final bool isCorrect;
  final String? imagePath;
  _Choice({
    required this.id,
    required this.text,
    required this.isCorrect,
    this.imagePath,
  });
}

class _AnswerRecord {
  final int questionID;
  final int? choiceID;
  final String? answerText;

  _AnswerRecord({
    required this.questionID,
    required this.choiceID,
    required this.answerText,
  });
}
