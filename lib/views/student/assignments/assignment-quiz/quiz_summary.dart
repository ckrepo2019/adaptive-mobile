import 'package:flutter/material.dart';
import 'package:Adaptive/controllers/student/student_subject.dart';
import 'package:Adaptive/controllers/student/student_remedial.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Adaptive/controllers/api_response.dart';
import 'package:Adaptive/config/routes.dart';

class QuizSummaryPage extends StatefulWidget {
  const QuizSummaryPage({super.key});

  @override
  State<QuizSummaryPage> createState() => _QuizSummaryPageState();
}

class _QuizSummaryPageState extends State<QuizSummaryPage> {
  late final int assessmentId;
  late final List<Map<String, dynamic>> questions;
  late final List<Map<String, dynamic>> answers;
  Map<String, dynamic>? _assessment;

  bool _submitting = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final raw = ModalRoute.of(context)?.settings.arguments;
    if (raw is Map) {
      assessmentId = (raw['assessmentId'] is int)
          ? raw['assessmentId'] as int
          : int.tryParse('${raw['assessmentId'] ?? 0}') ?? 0;

      final qs = (raw['questions'] is List)
          ? List<Map<String, dynamic>>.from(raw['questions'])
          : <Map<String, dynamic>>[];
      final as = (raw['answers'] is List)
          ? List<Map<String, dynamic>>.from(raw['answers'])
          : <Map<String, dynamic>>[];

      _assessment = (raw['assessment'] is Map)
          ? Map<String, dynamic>.from(raw['assessment'])
          : null;

      questions = qs;
      answers = as;
    } else {
      assessmentId = 0;
      questions = const [];
      answers = const [];
      _assessment = null;
    }
  }

  Map<String, dynamic>? _findQuestion(int qid) {
    try {
      return questions.firstWhere((q) => (q['id'] ?? 0) == qid);
    } catch (_) {
      return null;
    }
  }

  bool _looksLikeImageUrl(String value) {
    if (value.isEmpty) return false;
    final v = value.toLowerCase();
    final bool isHttp = v.startsWith('http://') || v.startsWith('https://');
    final bool hasExt = RegExp(
      r'\.(png|jpe?g|gif|webp|bmp)(\?|#|$)',
    ).hasMatch(v);
    return isHttp && hasExt;
  }

  Widget _buildAnswerWidget(Map<String, dynamic> ans) {
    final int qid = int.tryParse('${ans['questionID'] ?? 0}') ?? 0;
    final q = _findQuestion(qid);

    if (q == null) {
      return _AnswerBubble(
        child: Text(
          '(Unknown question)',
          style: GoogleFonts.poppins(color: const Color(0xFF1D2A5B)),
        ),
      );
    }

    final String type = '${q['type'] ?? ''}';

    if (type == 'identification' || type == 'essay' || type == 'short_answer') {
      final t = (ans['answer_text'] ?? '').toString().trim();
      if (t.isEmpty) {
        return _AnswerBubble(
          child: Text(
            '(No answer)',
            style: GoogleFonts.poppins(color: const Color(0xFF1D2A5B)),
          ),
        );
      }
      if (_looksLikeImageUrl(t)) {
        return _AnswerBubble.image(t, altText: t);
      }
      return _AnswerBubble(
        child: Text(
          t,
          style: GoogleFonts.poppins(color: const Color(0xFF1D2A5B)),
        ),
      );
    }

    final int selectedChoiceId = int.tryParse('${ans['choicesID'] ?? 0}') ?? 0;
    final List choices = (q['choices'] is List)
        ? List.from(q['choices'])
        : const [];
    final choice = choices.cast<Map<String, dynamic>?>().firstWhere(
      (c) => (c?['id'] ?? 0) == selectedChoiceId,
      orElse: () => null,
    );

    if (choice == null) {
      return _AnswerBubble(
        child: Text(
          '(No selection)',
          style: GoogleFonts.poppins(color: const Color(0xFF1D2A5B)),
        ),
      );
    }

    final String text = '${choice['text'] ?? ''}'.trim();
    final String image = '${choice['image'] ?? ''}'.trim();

    if (image.isNotEmpty) {
      return _AnswerBubble.image(
        image,
        altText: text.isNotEmpty ? text : 'Selected image',
      );
    }

    return _AnswerBubble(
      child: Text(
        text.isEmpty ? '(No text)' : text,
        style: GoogleFonts.poppins(color: const Color(0xFF1D2A5B)),
      ),
    );
  }

  Future<Map<String, dynamic>?> _fetchAiExplanationWithModal() async {
    // Show the non-dismissible modal immediately
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Your animated GIF at the top
              Image.asset(
                'assets/images/student-class/ai_analysis.gif',
                height: 120,
                width: 120,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 12),
              Text(
                'Answer Submitted',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'AI is working for Analysis, Please Wait',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(strokeWidth: 2.4),
              ),
            ],
          ),
        );
      },
    );

    // Fire the API call while the modal is visible
    final resp = await StudentRemedialController.generateExplanation(
      assessmentID: assessmentId,
    );

    if (!mounted) return null;

    // Close the modal
    Navigator.of(context, rootNavigator: true).pop();

    if (resp.success) {
      // Expecting { message, output } from the controller
      return resp.data ?? <String, dynamic>{};
    } else {
      _showSnack(resp.message ?? 'AI analysis failed.');
      return null;
    }
  }

  Future<void> _confirmAndSubmit() async {
    if (assessmentId <= 0) {
      _showSnack('Missing assessment ID.');
      return;
    }

    final payloadAnswers = answers.map((a) {
      final int qid = int.tryParse('${a['questionID'] ?? 0}') ?? 0;
      final q = _findQuestion(qid);
      final type = '${q?['type'] ?? ''}';

      if (type == 'identification' ||
          type == 'essay' ||
          type == 'short_answer') {
        final text = (a['answer_text'] ?? '').toString();
        return {'questionID': qid, 'text': text};
        // For essay-type you might also want to include images/attachments if you have them
      } else {
        final int choiceId = int.tryParse('${a['choicesID'] ?? 0}') ?? 0;
        return {'questionID': qid, 'choicesID': choiceId};
      }
    }).toList();

    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/assignments/check.gif',
              height: 84,
              width: 84,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 12),
            Text(
              'Submit Assessment?',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Are you sure you want to submit your answers now?\nYou won't be able to change them after submitting.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: Text('Cancel', style: GoogleFonts.poppins()),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        elevation: 0,
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF234FF5), Color(0xFF5173FF)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'Submit Assessment',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
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
    );

    if (ok != true) return;

    setState(() => _submitting = true);

    final ApiResponse<Map<String, dynamic>> resp =
        await StudentSubjectController.submitAssessment(
          assessmentId: assessmentId,
          answers: payloadAnswers,
        );

    setState(() => _submitting = false);

    if (!mounted) return;

    if (!resp.success) {
      _showSnack(resp.message ?? 'Submit failed.');
      return;
    }

    final Map<String, dynamic> resultArg = (resp.data is Map)
        ? Map<String, dynamic>.from(resp.data!)
        : {};

    // Show the AI modal and fetch explanation
    final aiData = await _fetchAiExplanationWithModal();
    if (!mounted) return;

    // Proceed to next page, carrying AI data if available
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.quizResult,
      arguments: {
        'result': resultArg,
        'assessmentId': assessmentId,
        if (_assessment != null) 'assessment': _assessment,
        if (aiData != null) 'ai_explanation': aiData,
      },
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg, style: GoogleFonts.poppins())));
  }

  @override
  Widget build(BuildContext context) {
    final total = questions.length;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Quiz Summary',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: total == 0
          ? Center(
              child: Text('No items to review.', style: GoogleFonts.poppins()),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
              itemCount: answers.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final ans = answers[i];
                final qid = int.tryParse('${ans['questionID'] ?? 0}') ?? 0;
                final q = _findQuestion(qid);
                final qText =
                    q?['text']?.toString() ?? '(Question text missing)';

                return _SummaryTile(
                  index: i + 1,
                  question: qText,
                  answerWidget: _buildAnswerWidget(ans),
                );
              },
            ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
          child: SizedBox(
            height: 54,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitting ? null : _confirmAndSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF234FF5),
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.black12,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _submitting
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : Text(
                      'Submit',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.index,
    required this.question,
    required this.answerWidget,
  });

  final int index;
  final String question;
  final Widget answerWidget;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 0,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$index. ',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                ),
                Expanded(
                  child: Text(
                    question,
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _AnswerBubble(child: answerWidget),
          ],
        ),
      ),
    );
  }
}

class _AnswerBubble extends StatelessWidget {
  const _AnswerBubble({required this.child});

  final Widget child;

  factory _AnswerBubble.image(String url, {String? altText}) {
    return _AnswerBubble(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Image.network(
            url,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return Center(
                child: SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    valueColor: const AlwaysStoppedAnimation(Colors.black54),
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stack) {
              return Container(
                color: const Color(0xFFF5F7FF),
                alignment: Alignment.center,
                padding: const EdgeInsets.all(12),
                child: Text(
                  (altText?.isNotEmpty ?? false)
                      ? altText!
                      : '(Image failed to load)',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(color: const Color(0xFF1D2A5B)),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: child,
    );
  }
}
