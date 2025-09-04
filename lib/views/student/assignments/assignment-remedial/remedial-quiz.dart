// lib/views/student/quizzes/remedial_quiz.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_lms/config/routes.dart';
import 'package:flutter_lms/controllers/student/student_remedial.dart';
import 'package:flutter_lms/controllers/api_response.dart';
import 'package:flutter_lms/widgets/app_bar.dart';
import 'package:google_fonts/google_fonts.dart';

class RemedialQuizPage extends StatefulWidget {
  const RemedialQuizPage({super.key});

  @override
  State<RemedialQuizPage> createState() => _RemedialQuizPageState();
}

class _RemedialQuizPageState extends State<RemedialQuizPage> {
  bool _didFetch = false;
  bool _loading = false;
  String? _error;
  String? _debugJson;

  int? _teacherAssessmentID;
  int? _learnersTypeId;

  Map<String, dynamic>? _takeData;

  final List<Map<String, dynamic>> _items = <Map<String, dynamic>>[];
  final List<int?> _selectedRemedialChoiceIds = <int?>[];

  int _index = 0;

  int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }

  int? _deriveLearnerTypeIdFromMastery(dynamic mastery) {
    if (mastery is Map) {
      final lp = mastery['learners_profile'];
      if (lp is List && lp.isNotEmpty) {
        final first = lp.first;
        if (first is Map) {
          return _asInt(first['learners_type_id'] ?? first['learners_typeID']);
        }
      }
    }
    return null;
  }

  Map<String, dynamic>? _findExplanationForQ(List exp, int qid) {
    for (final e in exp) {
      if (e is Map && _asInt(e['questionID']) == qid) {
        return Map<String, dynamic>.from(e);
      }
    }
    return null;
  }

  Map<String, dynamic>? _findRemedialById(List rqs, int id) {
    for (final r in rqs) {
      if (r is Map && _asInt(r['id']) == id) {
        return Map<String, dynamic>.from(r);
      }
    }
    return null;
  }

  Map<String, dynamic>? _findFirstRemedialForQ(List rqs, int qid) {
    for (final r in rqs) {
      if (r is Map && _asInt(r['questionID']) == qid) {
        return Map<String, dynamic>.from(r);
      }
    }
    return null;
  }

  void _assembleItems() {
    _items.clear();
    _selectedRemedialChoiceIds.clear();

    final wrongs = (_takeData?['wrong_answers'] is List)
        ? (_takeData!['wrong_answers'] as List)
        : const <dynamic>[];
    final exps = (_takeData?['explanation'] is List)
        ? (_takeData!['explanation'] as List)
        : const <dynamic>[];
    final rems = (_takeData?['remedial_questions'] is List)
        ? (_takeData!['remedial_questions'] as List)
        : const <dynamic>[];

    for (final w in wrongs) {
      if (w is! Map) continue;
      final qid = _asInt(w['questionID']) ?? 0;
      if (qid <= 0) continue;

      int? correctChoiceId;
      final choices = (w['question_choices'] is List)
          ? (w['question_choices'] as List)
          : const <dynamic>[];
      for (final c in choices) {
        if (c is Map && _asInt(c['is_correct']) == 1) {
          correctChoiceId = _asInt(c['id']);
          break;
        }
      }

      final exp = _findExplanationForQ(exps, qid);
      Map<String, dynamic>? rq;
      final remedialIdFromExp = _asInt(exp?['remedialQuestionID']);
      if (remedialIdFromExp != null && remedialIdFromExp > 0) {
        rq = _findRemedialById(rems, remedialIdFromExp);
      }
      rq ??= _findFirstRemedialForQ(rems, qid);

      _items.add({
        'wrong': Map<String, dynamic>.from(w),
        'correctChoiceId': correctChoiceId,
        'explanation': exp,
        'remedial': rq,
      });
      _selectedRemedialChoiceIds.add(null);
    }

    _index = 0;
  }

  Future<void> _fetchTake() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final ApiResponse<Map<String, dynamic>> res =
        await StudentRemedialController.fetchRemedialTake(
          teacherAssessmentID: _teacherAssessmentID!,
          learnersTypeId: _learnersTypeId!,
        );

    if (!mounted) return;

    if (res.success) {
      _takeData = res.data ?? <String, dynamic>{};
      try {
        _debugJson = const JsonEncoder.withIndent(
          '  ',
        ).convert(_takeData ?? {});
      } catch (_) {
        _debugJson = jsonEncode(_takeData ?? {});
      }
      _assembleItems();
      setState(() => _loading = false);
    } else {
      setState(() {
        _loading = false;
        _error = res.message ?? 'Failed to fetch remedial data.';
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didFetch) return;
    _didFetch = true;

    final argsRaw = ModalRoute.of(context)?.settings.arguments;
    final Map<String, dynamic>? args = (argsRaw is Map)
        ? Map<String, dynamic>.from(argsRaw)
        : null;

    _teacherAssessmentID = _asInt(args?['teacherAssessmentID']);
    final mastery = args?['mastery'];
    _learnersTypeId =
        _asInt(args?['learnersTypeId']) ??
        _deriveLearnerTypeIdFromMastery(mastery);

    if (_teacherAssessmentID == null || _teacherAssessmentID! <= 0) {
      setState(() => _error = 'teacherAssessmentID is required in arguments.');
      return;
    }
    if (_learnersTypeId == null || _learnersTypeId! <= 0) {
      setState(() => _error = 'learners_type_id could not be derived.');
      return;
    }

    _fetchTake();
  }

  void _selectRemedialChoice(int choiceId) {
    if (_index < 0 || _index >= _selectedRemedialChoiceIds.length) return;
    setState(() => _selectedRemedialChoiceIds[_index] = choiceId);
  }

  void _goBack() {
    if (_index > 0) setState(() => _index -= 1);
  }

  void _goNextOrSubmit() {
    final isLast = _index >= _items.length - 1;
    if (!isLast) {
      setState(() => _index += 1);
    } else {
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.remedialQuizResult,
        (route) => false,
        arguments: {
          'selected_choices': _selectedRemedialChoiceIds,
          'items_count': _items.length,
          'teacherAssessmentID': _teacherAssessmentID,
          'assessment_details': _takeData?['assessment_details'],
          'raw': _takeData,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final blue = const Color(0xFF2B50FF);
    final green = const Color(0xFF22C55E);
    final orange = const Color(0xFFFF8A00);

    final hasData = _items.isNotEmpty && _index >= 0 && _index < _items.length;
    final Map<String, dynamic>? current = hasData ? _items[_index] : null;

    final Map<String, dynamic>? wrong =
        (current != null && current['wrong'] is Map)
        ? (current['wrong'] as Map<String, dynamic>)
        : null;

    final int? correctChoiceId = _asInt(current?['correctChoiceId']);
    final int? chosenWrongId = _asInt(wrong?['choicesID']);

    final Map<String, dynamic>? exp =
        (current != null && current['explanation'] is Map)
        ? (current['explanation'] as Map<String, dynamic>?)
        : null;

    final String expText = (exp?['explanation']?.toString() ?? '').trim();

    final Map<String, dynamic>? remedial =
        (current != null && current['remedial'] is Map)
        ? (current['remedial'] as Map<String, dynamic>?)
        : null;

    final List<Map<String, dynamic>> remedialChoices =
        (remedial != null && remedial['choices'] is List)
        ? List<Map<String, dynamic>>.from(
            (remedial['choices'] as List).map(
              (e) => (e is Map)
                  ? Map<String, dynamic>.from(e)
                  : <String, dynamic>{},
            ),
          )
        : <Map<String, dynamic>>[];

    final int? selectedChoiceId =
        (_index >= 0 && _index < _selectedRemedialChoiceIds.length)
        ? _selectedRemedialChoiceIds[_index]
        : null;

    final bool canContinue =
        remedial == null || remedialChoices.isEmpty || selectedChoiceId != null;

    final bool isLast = hasData ? _index >= _items.length - 1 : true;

    final progressRow = Row(
      children: [
        const Spacer(),
        Text(
          hasData ? '${_index + 1}/${_items.length}' : '0/0',
          style: GoogleFonts.poppins(
            color: Colors.black38,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9),
      appBar: const GlobalAppBar(
        title: 'Review & Master',
        showNotifications: false,
        showProfile: false,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : (_error != null)
                ? Center(
                    child: Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                : (!hasData)
                ? Center(
                    child: Text(
                      'No remedial items.',
                      style: GoogleFonts.poppins(color: Colors.black54),
                    ),
                  )
                : ListView(
                    children: [
                      progressRow,
                      const SizedBox(height: 14),

                      _buildRemedialCard(
                        remedial,
                        remedialChoices,
                        selectedChoiceId,
                        _selectRemedialChoice,
                      ),

                      const SizedBox(height: 14),

                      _CollapsibleTile(
                        color: orange,
                        icon: Icons.refresh_rounded,
                        title: 'Previous Mistake',
                        initiallyExpanded: false,
                        child: _buildWrongCardBody(
                          wrong,
                          chosenWrongId,
                          correctChoiceId,
                        ),
                      ),

                      const SizedBox(height: 14),

                      _CollapsibleTile(
                        color: green,
                        icon: Icons.psychology_rounded,
                        title: 'Explanation',
                        initiallyExpanded: false,
                        child: expText.isEmpty
                            ? Text(
                                'No explanation available.',
                                style: GoogleFonts.poppins(
                                  color: Colors.black54,
                                  fontSize: 13,
                                ),
                              )
                            : Text(
                                expText,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Colors.black87,
                                  height: 1.4,
                                ),
                              ),
                      ),

                      const SizedBox(height: 120), // space for floating buttons
                    ],
                  ),
          ),

          // Floating bottom buttons
          if (!_loading && _error == null && hasData)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    (_index > 0)
                        ? Expanded(
                            child: OutlinedButton(
                              onPressed: _goBack,
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Color(0xFF2B50FF),
                                  width: 2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                backgroundColor: Colors.white,
                                elevation: 0,
                              ),
                              child: Text(
                                'Go back',
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF2B50FF),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                    (_index > 0)
                        ? const SizedBox(width: 12)
                        : const SizedBox.shrink(),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: canContinue
                            ? ElevatedButton(
                                onPressed: _goNextOrSubmit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2B50FF),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 6,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                ),
                                child: Text(
                                  isLast ? 'Submit' : 'Continue',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWrongCardBody(
    Map<String, dynamic>? wrong,
    int? chosenWrongId,
    int? correctChoiceId,
  ) {
    final q = (wrong != null && wrong['question'] is Map)
        ? (wrong['question'] as Map)
        : null;
    final qText = q?['question_text']?.toString() ?? 'Question';
    final choices = (wrong != null && wrong['question_choices'] is List)
        ? (wrong['question_choices'] as List)
        : const <dynamic>[];

    final List<Widget> choiceWidgets = <Widget>[];
    for (int i = 0; i < choices.length; i++) {
      final c = (choices[i] is Map) ? (choices[i] as Map) : <String, dynamic>{};
      final cid = _asInt(c['id']);
      final isCorrect = _asInt(c['is_correct']) == 1;

      _ChoiceVisualState state;
      if (cid == chosenWrongId) {
        state = _ChoiceVisualState.wrongSelected;
      } else if (isCorrect) {
        state = _ChoiceVisualState.correctUnselected;
      } else {
        state = _ChoiceVisualState.neutral;
      }

      choiceWidgets.add(
        Padding(
          padding: EdgeInsets.only(bottom: i == choices.length - 1 ? 0 : 10),
          child: _ChoiceTile(
            index: i,
            label: (c['choices'] ?? '').toString(),
            selected: cid == chosenWrongId,
            correct: isCorrect,
            state: state,
            onSelect: (_) {},
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          qText,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 12),
        Column(children: choiceWidgets),
      ],
    );
  }

  Widget _buildRemedialCard(
    Map<String, dynamic>? remedial,
    List<Map<String, dynamic>> remedialChoices,
    int? selectedChoiceId,
    void Function(int choiceId) onPick,
  ) {
    final title =
        (remedial != null &&
            remedial['question_text'] != null &&
            remedial['question_text'].toString().trim().isNotEmpty)
        ? remedial['question_text'].toString()
        : 'Remedial Question';

    final List<Widget> choiceWidgets = <Widget>[];
    for (int i = 0; i < remedialChoices.length; i++) {
      final c = remedialChoices[i];
      final cid = _asInt(c['id']);
      final picked = (selectedChoiceId != null && cid == selectedChoiceId);
      choiceWidgets.add(
        Padding(
          padding: EdgeInsets.only(
            bottom: i == remedialChoices.length - 1 ? 0 : 10,
          ),
          child: _RemedialChoiceTile(
            index: i,
            label: (c['choices'] ?? '').toString(),
            picked: picked,
            onPick: () {
              if (cid != null) onPick(cid);
            },
          ),
        ),
      );
    }

    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 12),
          remedialChoices.isEmpty
              ? Text(
                  'No remedial choices available.',
                  style: GoogleFonts.poppins(color: Colors.black54),
                )
              : Column(children: choiceWidgets),
        ],
      ),
    );
  }
}

class _CardShell extends StatelessWidget {
  const _CardShell({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 5,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        child: child,
      ),
    );
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
      default:
        bg = Colors.white;
    }

    final String letter = String.fromCharCode(65 + index);

    return InkWell(
      onTap: () => onSelect(index),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: state == _ChoiceVisualState.correctSelected
                ? const Color(0xFF22C55E)
                : state == _ChoiceVisualState.correctUnselected
                ? const Color(0xFF22C55E).withOpacity(0.8)
                : state == _ChoiceVisualState.wrongSelected
                ? const Color(0xFFE53935)
                : const Color.fromARGB(0, 255, 255, 255),
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            Text(
              '$letter.',
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
            (tail != null)
                ? Row(
                    children: [
                      const SizedBox(width: 10),
                      Icon(
                        tail,
                        size: 20,
                        color: state == _ChoiceVisualState.wrongSelected
                            ? const Color(0xFFE53935)
                            : const Color(0xFF22C55E),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}

class _RemedialChoiceTile extends StatelessWidget {
  const _RemedialChoiceTile({
    required this.index,
    required this.label,
    required this.picked,
    required this.onPick,
  });

  final int index;
  final String label;
  final bool picked;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final blue = const Color(0xFF2B50FF);
    final Color bg = picked ? blue.withOpacity(0.10) : Colors.white;
    final Color border = picked ? blue : const Color.fromARGB(0, 0, 0, 0);
    final IconData tail = picked
        ? Icons.radio_button_checked
        : Icons.radio_button_unchecked;

    final String letter = String.fromCharCode(65 + index);

    return InkWell(
      onTap: onPick,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: border, width: 1.2),
        ),
        child: Row(
          children: [
            Text(
              '$letter.',
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
            const SizedBox(width: 10),
            Icon(tail, size: 20, color: picked ? blue : Colors.black26),
          ],
        ),
      ),
    );
  }
}

class _CollapsibleTile extends StatefulWidget {
  const _CollapsibleTile({
    required this.color,
    required this.icon,
    required this.title,
    required this.child,
    this.initiallyExpanded = false,
  });

  final Color color;
  final IconData icon;
  final String title;
  final Widget child;
  final bool initiallyExpanded;

  @override
  State<_CollapsibleTile> createState() => _CollapsibleTileState();
}

class _CollapsibleTileState extends State<_CollapsibleTile>
    with TickerProviderStateMixin {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  void _toggle() => setState(() => _expanded = !_expanded);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: widget.color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: widget.color.withOpacity(0.8), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(widget.icon, color: widget.color, size: 28),
                const SizedBox(width: 8),
                Text(
                  widget.title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w800,
                    fontSize: 16.5,
                    color: widget.color,
                  ),
                ),
                const Spacer(),
                Icon(
                  _expanded
                      ? Icons.expand_less_rounded
                      : Icons.expand_more_rounded,
                  color: widget.color,
                  size: 24,
                ),
              ],
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeInOut,
              child: _expanded
                  ? Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: widget.child,
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
