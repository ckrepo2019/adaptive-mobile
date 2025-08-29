import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_lms/config/routes.dart';
import 'package:flutter_lms/views/base_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_lms/controllers/student/student_home.dart';
import 'package:flutter_lms/controllers/api_response.dart';

class ResultLeanerPage extends BaseView {
  const ResultLeanerPage({super.key});

  @override
  Widget build(BuildContext context) => const _ResultLeanerBody();
}

class _ResultLeanerBody extends StatefulWidget {
  const _ResultLeanerBody();

  @override
  State<_ResultLeanerBody> createState() => _ResultLeanerBodyState();
}

class _ResultLeanerBodyState extends State<_ResultLeanerBody> {
  List<dynamic>? _profiles;
  int? _studentId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_profiles != null) return;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is List) {
      _profiles = List<dynamic>.from(args);
    } else if (args is Map && args['profiles'] is List) {
      _profiles = List<dynamic>.from(args['profiles']);
    }
    if (args is Map && args['studentId'] != null) {
      _studentId = args['studentId'] is int
          ? args['studentId'] as int
          : int.tryParse(args['studentId'].toString());
    }
    if (_profiles != null) {
      try {
        debugPrint('🔎 ResultLeanerPage initial profiles:');
        debugPrint(const JsonEncoder.withIndent('  ').convert(_profiles));
      } catch (_) {
        debugPrint('🔎 ResultLeanerPage profiles: $_profiles');
      }
      setState(() {});
    }
  }

  Future<void> _refresh() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final id = _studentId ?? prefs.getInt('id');
      if (token == null || id == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Missing session or student ID.')),
        );
        return;
      }
      final ApiResponse<List<dynamic>> resp =
          await StudentHomeController.fetchLearnerProfiles(
            token: token,
            studentId: id,
          );
      if (!mounted) return;
      if (resp.success && resp.data != null) {
        setState(() => _profiles = resp.data);
        try {
          debugPrint('🔄 Refreshed learner profiles:');
          debugPrint(const JsonEncoder.withIndent('  ').convert(_profiles));
        } catch (_) {
          debugPrint('🔄 Refreshed learner profiles: $_profiles');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(resp.message ?? 'Failed to refresh data.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  String _firstTypeName() {
    if (_profiles == null || _profiles!.isEmpty) return 'Learner';
    final m = _profiles!.first;
    if (m is Map) {
      final mt = m['learners_types'];
      if (mt is Map && mt['name'] != null) {
        return mt['name'].toString();
      }
      if (m['learners_typeID'] != null) {
        return 'Type #${m['learners_typeID']}';
      }
    }
    return 'Learner';
  }

  IconData _iconForType(String typeName) {
    final t = typeName.toLowerCase();
    if (t.contains('visual')) return Icons.remove_red_eye_outlined;
    if (t.contains('auditory') || t.contains('aural')) return Icons.hearing;
    if (t.contains('read') || t.contains('write')) {
      return Icons.menu_book_outlined;
    }
    if (t.contains('kinesthetic') || t.contains('hands')) {
      return Icons.pan_tool_alt_outlined;
    }
    return Icons.school_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final w = mq.size.width;
    final h = mq.size.height;
    double clampNum(double v, double min, double max) =>
        v < min ? min : (v > max ? max : v);
    final panelHeight = clampNum(h * 0.38, 280, 420);
    final imgAreaHeight = clampNum(h - panelHeight + 60, 320, h * 0.65);
    final imgMaxWidth = clampNum(w * 1.35, 420, 1100);
    final titleSize = clampNum(w * 0.10, 28, 48);
    final bodySize = clampNum(w * 0.035, 12, 16);
    final iconSize = clampNum(titleSize * 0.9, 24, 44);
    final padX = clampNum(w * 0.06, 20, 40);
    final panelRadius = clampNum(w * 0.06, 20, 30);
    final typeName = _firstTypeName();
    final icon = _iconForType(typeName);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: Colors.white,
        backgroundColor: const Color(0xFF0055FF),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: h,
            width: w,
            child: Stack(
              children: [
                Positioned(
                  top: mq.padding.top * 2.5,
                  left: 0,
                  right: 0,
                  height: imgAreaHeight,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: imgMaxWidth,
                        maxHeight: imgAreaHeight,
                      ),
                      child: Image.asset(
                        'assets/images/intro/result_model.png',
                        fit: BoxFit.contain,
                        alignment: Alignment.topCenter,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: panelHeight,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0055FF),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(panelRadius),
                      ),
                    ),
                    padding: EdgeInsets.fromLTRB(padX, padX, padX, padX * 0.8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "You are a",
                          style: TextStyle(
                            color: Colors.grey.shade200,
                            fontSize: clampNum(bodySize * 0.95, 11, 14),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                typeName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: titleSize,
                                  fontWeight: FontWeight.w700,
                                  height: 1.1,
                                ),
                              ),
                            ),
                            SizedBox(width: clampNum(w * 0.02, 8, 16)),
                            Icon(icon, size: iconSize, color: Colors.white),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Congratulations on completing your assessment! '
                          'Your results indicate that you are a $typeName.',
                          style: TextStyle(
                            color: Colors.grey.shade200,
                            fontSize: bodySize,
                            fontWeight: FontWeight.w400,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'We\'ll customize the content to fit your learning style, '
                          'ensuring you have the best experience possible.',
                          style: TextStyle(
                            color: Colors.grey.shade200,
                            fontSize: bodySize,
                            fontWeight: FontWeight.w400,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 24.0),
                        SizedBox(
                          height: clampNum(50, 46, 56),
                          width: double.infinity,
                          child: InkWell(
                            onTap: () async {
                              final prefs =
                                  await SharedPreferences.getInstance();
                              final token = prefs.getString('token');
                              final uid = prefs.getString('uid');
                              final userType = prefs.getInt('usertype_ID');
                              if (token == null || uid == null) {
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Missing session data.'),
                                  ),
                                );
                                return;
                              }
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                AppRoutes.studentShell,
                                (route) => false,
                                arguments: {
                                  'token': token,
                                  'uid': uid,
                                  'usertype_ID': userType,
                                },
                              );
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "Get Started",
                                style: TextStyle(
                                  color: const Color(0xFF0055FF),
                                  fontWeight: FontWeight.bold,
                                  fontSize: clampNum(16, 20, 18),
                                ),
                              ),
                            ),
                          ),
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
