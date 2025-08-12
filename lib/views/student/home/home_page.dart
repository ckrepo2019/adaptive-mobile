import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_lms/config/routes.dart';
import 'package:flutter_lms/controllers/api_response.dart';
import 'package:flutter_lms/controllers/student/student_home.dart';

class StudentHomePage extends StatefulWidget {
  const StudentHomePage({super.key});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  bool _loading = true;
  String? _error;

  Map<String, dynamic>? _data; // payload from /student-home/{uid}
  String? _token;
  String? _uid;

  /// Log big strings in chunks so Logcat doesn't truncate them
  void _logLarge(Object? obj, {int chunk = 900}) {
    final s = obj is String
        ? obj
        : const JsonEncoder.withIndent('  ').convert(obj);
    for (var i = 0; i < s.length; i += chunk) {
      debugPrint(s.substring(i, math.min(i + chunk, s.length)));
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is! Map) {
      setState(() {
        _loading = false;
        _error = 'Missing route arguments.';
      });
      return;
    }
    _token = args['token'] as String?;
    _uid = args['uid'] as String?;
    if (_token == null || _uid == null) {
      setState(() {
        _loading = false;
        _error = 'Invalid route arguments.';
      });
      return;
    }
    _load(_token!, _uid!);
  }

  Future<void> _load(String token, String uid) async {
    final ApiResponse<Map<String, dynamic>> resp =
        await StudentHomeController.fetchStudentHome(token: token, uid: uid);

    if (!mounted) return;

    if (resp.success && resp.data != null) {
      final d = resp.data!;
      // ---- PRINT SUMMARY ----
      final subjectsLen = (d['subjects'] as List?)?.length ?? 0;
      final hobbiesTypeLen = (d['hobbies_type'] as List?)?.length ?? 0;
      final learnersProfileLen = (d['learners_profile'] as List?)?.length ?? 0;
      final questionsLen = (d['learner_questions'] as List?)?.length ?? 0;
      debugPrint('[student-home] ✅ success');
      debugPrint(
        '[student-home] subjects=$subjectsLen '
        'hobbyTypes=$hobbiesTypeLen learnersProfile=$learnersProfileLen '
        'questions=$questionsLen',
      );

      // ---- PRINT FULL PAYLOAD (pretty) ----
      debugPrint('----- student-home payload (pretty) -----');
      _logLarge(d);
      debugPrint('----- end payload -----');

      // ---- Redirect rule: if no learners_profile but has enrollment_data -> GetStarted ----
      final learnersProfile = (d['learners_profile'] as List?) ?? const [];
      final enrollmentData = d['enrollment_data'];
      if (learnersProfile.isEmpty && enrollmentData != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.getStarted,
            (route) => false,
            arguments: {
              'token': token,
              'uid': uid,
              'userType': 4,
              'studentHomeData': d, // <-- pass entire payload
            },
          );
        });
        return;
      }

      setState(() {
        _data = d;
        _loading = false;
        _error = null;
      });
    } else {
      debugPrint('[student-home] ❌ ${resp.message}');
      setState(() {
        _loading = false;
        _error = resp.message ?? 'Failed to load student home.';
      });
    }
  }

  // --- UI helpers ---
  Widget _sectionTitle(String text, {IconData icon = Icons.info_outline}) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.black54),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _kv(String k, dynamic v, {double kWidth = 140}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: kWidth,
            child: Text(
              k,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: Text(
              (v == null || (v is String && v.isEmpty)) ? '—' : v.toString(),
              style: const TextStyle(fontWeight: FontWeight.w500),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      margin: const EdgeInsets.only(right: 8, bottom: 8),
      decoration: BoxDecoration(
        color: Colors.blueGrey.withOpacity(0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.black12),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Student Home')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(_error!, style: const TextStyle(color: Colors.red)),
          ),
        ),
      );
    }

    final d = _data!;
    final student = (d['student'] as Map?)?.cast<String, dynamic>();
    final enrolled = (d['enrolled'] as List?)?.cast<dynamic>() ?? [];
    final sy = (d['sy'] as Map?)?.cast<String, dynamic>();
    final learnersProfile =
        (d['learners_profile'] as List?)?.cast<dynamic>() ?? [];
    final subjects = (d['subjects'] as List?)?.cast<dynamic>() ?? [];
    final hobbiesType = (d['hobbies_type'] as List?)?.cast<dynamic>() ?? [];
    final interests = (d['interests'] as List?)?.cast<dynamic>() ?? [];
    final enrollmentData = (d['enrollment_data'] as Map?)
        ?.cast<String, dynamic>();
    final learnerAssessment = (d['learner_assessment'] as Map?)
        ?.cast<String, dynamic>();
    final learnerQuestions =
        (d['learner_questions'] as List?)?.cast<dynamic>() ?? [];

    final fullName = student == null
        ? 'Student'
        : [
            student['firstname'],
            student['middlename'],
            student['lastname'],
            student['suffix'],
          ].where((x) => x != null && x.toString().trim().isNotEmpty).join(' ');

    return Scaffold(
      appBar: AppBar(title: Text(fullName.isEmpty ? 'Student Home' : fullName)),
      body: RefreshIndicator(
        onRefresh: () async {
          if (_token != null && _uid != null) {
            await _load(_token!, _uid!);
          }
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Profile
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('Profile', icon: Icons.person),
                    if (student == null)
                      const Text('No profile found.')
                    else ...[
                      _kv('SID', student['sid']),
                      _kv('LRN', student['lrn']),
                      _kv('Firstname', student['firstname']),
                      _kv('Middlename', student['middlename']),
                      _kv('Lastname', student['lastname']),
                      _kv('Suffix', student['suffix']),
                      _kv('Date of Birth', student['date_of_birth']),
                      _kv('Gender', student['gender']),
                      _kv('Age', student['age']),
                      _kv('Email', student['emailaddress']),
                      _kv('Contact No.', student['contactnumber']),
                      _kv('Address', student['address']),
                      _kv('City', student['city']),
                      _kv('Province', student['province']),
                      _kv('Zip', student['zipcode']),
                      _kv('Country', student['country']),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Enrollment / School Year
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('Enrollment', icon: Icons.school),
                    if (enrollmentData == null)
                      const Text('No active enrollment found.')
                    else ...[
                      _kv('Level', enrollmentData['level_name']),
                      _kv('SY ID', enrollmentData['syID']),
                      _kv('Section ID', enrollmentData['sectionID']),
                      _kv('Block ID', enrollmentData['blockID']),
                    ],
                    const SizedBox(height: 8),
                    _sectionTitle(
                      'Active School Year',
                      icon: Icons.calendar_today,
                    ),
                    if (sy == null)
                      const Text('No active school year.')
                    else ...[
                      _kv('SY Name', sy['sy_name']),
                      _kv('Start', sy['sy_start']),
                      _kv('End', sy['sy_end']),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Learners Profile
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle(
                      'Learners Profile',
                      icon: Icons.assignment_ind,
                    ),
                    Text('Records: ${learnersProfile.length}'),
                    const SizedBox(height: 8),
                    if (learnersProfile.isEmpty)
                      const Text('No learner profile for the active SY.')
                    else
                      ...learnersProfile.take(3).map((lp) {
                        final m = (lp as Map).cast<String, dynamic>();
                        final lt = (m['learners_types'] as Map?)
                            ?.cast<String, dynamic>();
                        final typeName = lt?['name'] ?? 'Type';
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '- type: $typeName',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              _kv('ID', m['id'], kWidth: 80),
                              _kv('SY ID', m['syID'], kWidth: 80),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Subjects
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('Subjects', icon: Icons.menu_book),
                    if (subjects.isEmpty)
                      const Text('No subjects found.')
                    else
                      Wrap(
                        children: subjects.map((s) {
                          final m = (s as Map).cast<String, dynamic>();
                          return _chip(
                            m['subject_name']?.toString() ?? 'Subject',
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Hobbies
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('Hobbies', icon: Icons.sports_esports),
                    if (hobbiesType.isEmpty)
                      const Text('No hobbies available.')
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: hobbiesType.map((t) {
                          final tm = (t as Map).cast<String, dynamic>();
                          final title = tm['name']?.toString() ?? 'Type';
                          final hs =
                              (tm['hobbies'] as List?)?.cast<dynamic>() ?? [];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                if (hs.isEmpty)
                                  const Text('—')
                                else
                                  Wrap(
                                    children: hs.map((h) {
                                      final hm = (h as Map)
                                          .cast<String, dynamic>();
                                      return _chip(
                                        hm['name']?.toString() ?? 'Hobby',
                                      );
                                    }).toList(),
                                  ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Interests
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('Interests', icon: Icons.favorite),
                    if (interests.isEmpty)
                      const Text('No interests available.')
                    else
                      Wrap(
                        children: interests.map((i) {
                          final im = (i as Map).cast<String, dynamic>();
                          return _chip(im['name']?.toString() ?? 'Interest');
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Assessment
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('Assessment', icon: Icons.quiz),
                    if (learnerAssessment == null)
                      const Text('No assessment available for current level.')
                    else ...[
                      _kv('Assessment ID', learnerAssessment['id']),
                      _kv('Assessment', learnerAssessment['assessment_name']),
                      _kv('Mode', learnerAssessment['level_mode']),
                      const SizedBox(height: 8),
                      Text(
                        'Questions: ${learnerQuestions.length}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
