import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_lms/config/routes.dart';
import 'package:flutter_lms/controllers/api_response.dart';
import 'package:flutter_lms/controllers/student/student_home.dart';
import 'package:flutter_lms/views/student/home/cards_list.dart';
import 'package:flutter_lms/views/student/home/quick_actions.dart';
import 'package:flutter_lms/views/student/student_global_layout.dart';
import 'package:flutter_lms/widgets/app_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_lms/config/constants.dart';
import 'package:flutter_lms/views/student/tabs/student_tabs.dart';
import 'package:flutter_lms/models/items.dart';

class StudentHomePage extends StatefulWidget {
  final String token;
  final String uid;
  final int userType;

  const StudentHomePage({
    super.key,
    required this.token,
    required this.uid,
    required this.userType,
  });

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  bool _loading = true; // network in-flight
  bool _ready = false; // payload validated & normalized
  String? _error;

  Map<String, dynamic>? _data; // normalized payload
  String? _token;
  String? _uid;

  // Loop/dup guards
  bool _initialized = false; // run bootstrap exactly once
  bool _navigated = false; // prevent multiple redirects
  String? _lastFetchKey; // avoid duplicate fetch for same (token,uid)

  void _goToClasses() {
    StudentTabs.of(context).setIndex(1);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;

    _token = widget.token;
    _uid = widget.uid;

    _initialized = true;
    _safeLoad(_token!, _uid!);
  }

  // Public retry or pull-to-refresh can call this safely.
  Future<void> _safeLoad(String token, String uid) async {
    final key = '$token::$uid';
    if (_lastFetchKey == key && (_data != null || _loading)) {
      // Already loaded or in-flight for these creds; do nothing.
      return;
    }
    _lastFetchKey = key;
    await _load(token, uid);
  }

  bool _isCompletePayload(Map<String, dynamic> d) {
    const requiredKeys = <String>[
      'subjects',
      'hobbies_type',
      'learner_questions',
      'enrollment_data',
    ];
    for (final k in requiredKeys) {
      if (!d.containsKey(k)) return false;
    }
    if (d['subjects'] is! List) return false;
    if (d['hobbies_type'] is! List) return false;
    if (d['learner_questions'] is! List) return false;
    if (d['enrollment_data'] != null && d['enrollment_data'] is! Map) {
      return false;
    }
    if (d.containsKey('learners_profile') && d['learners_profile'] != null) {
      if (d['learners_profile'] is! List) return false;
    }
    if (d.containsKey('student') &&
        d['student'] != null &&
        d['student'] is! Map) {
      return false;
    }
    return true;
  }

  Map<String, dynamic> _normalize(Map<String, dynamic> d) {
    final subjects = (d['subjects'] as List?) ?? const <dynamic>[];
    return {
      ...d,
      'subjects': (d['subjects'] as List?) ?? const <dynamic>[],
      'hobbies_type': (d['hobbies_type'] as List?) ?? const <dynamic>[],
      'learner_questions':
          (d['learner_questions'] as List?) ?? const <dynamic>[],
      'learners_profile': (d['learners_profile'] as List?) ?? const <dynamic>[],
      'enrollment_data': (d['enrollment_data'] as Map?) ?? <String, dynamic>{},
      'student': (d['student'] as Map?) ?? <String, dynamic>{},
    };
  }

  Future<void> _load(String token, String uid) async {
    // Keep state churn minimal to avoid layout thrash
    if (mounted) {
      setState(() {
        _loading = true;
        _ready = false;
        _error = null;
      });
    }

    final ApiResponse<Map<String, dynamic>> resp =
        await StudentHomeController.fetchStudentHome(token: token, uid: uid);

    if (!mounted) return;

    if (!(resp.success && resp.data != null)) {
      setState(() {
        _loading = false;
        _ready = false;
        _error = resp.message ?? 'Failed to load student home.';
      });
      return;
    }

    final raw = resp.data!;

    // Single-fire redirect rule
    final learnersProfile = (raw['learners_profile'] as List?) ?? const [];

    final enrollmentData = raw['enrollment_data'];
    if (!_navigated && learnersProfile.isEmpty && enrollmentData != null) {
      _navigated = true;
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
            'studentHomeData': raw,
          },
        );
      });
      return;
    }

    // Validate + normalize before displaying
    if (!_isCompletePayload(raw)) {
      setState(() {
        _loading = false;
        _ready = false;
        _error = 'Incomplete payload received. Pull to refresh or try again.';
      });
      return;
    }

    final normalized = _normalize(raw);

    setState(() {
      _data = normalized;
      _loading = false;
      _ready = true;
      _error = null;
    });
  }

  String get _welcomeFirstName {
    final s = _data?['student'];
    if (s is Map) {
      final first = (s['firstname'] ?? s['first_name'] ?? '').toString().trim();
      if (first.isNotEmpty) return first;
    }
    return 'Student';
  }

  // Uses shared model: AssignmentItem (from models/items.dart)
  final assignments = <AssignmentItem>[
    const AssignmentItem(
      title: 'Quadratic Equations',
      subject: 'Mathematics',
      date: 'Today, 3:00 PM',
      duration: '20 min',
      type: 'Quiz',
    ),
    const AssignmentItem(
      title: 'Photosynthesis',
      subject: 'Science',
      date: 'Tomorrow, 9:00 AM',
      duration: '45 min',
      type: 'Assignment',
    ),
    const AssignmentItem(
      title: 'World War II',
      subject: 'History',
      date: 'Aug 15, 1:30 PM',
      duration: '1 hr',
      type: 'Essay',
    ),
  ];

  String _resolveImagePath(String p) {
    if (p.isEmpty) return '';

    // Absolute URL? Use as-is.
    final lower = p.toLowerCase();
    if (lower.startsWith('http://') || lower.startsWith('https://')) return p;

    // Build origin (scheme://host[:port]) from your API base URL
    String originFromBase(String base) {
      final u = Uri.parse(base);
      final port = u.hasPort ? ':${u.port}' : '';
      return '${u.scheme}://${u.host}$port';
    }

    final origin = originFromBase(AppConstants.baseURL);

    if (p.contains('/')) return '$origin/storage/$p';

    // Otherwise assume it's a bundled asset path
    return p;
    // NOTE: cards_list.dart handles both asset and network paths gracefully.
  }

  // Build Class Progress items directly from `_data['subjects']`
  List<ClassProgressItem> get classes {
    final subjects = (_data?['subjects'] as List?) ?? const [];
    final List<ClassProgressItem> result = [];

    for (final s in subjects) {
      if (s is! Map) continue;

      final title = (s['subject_name'] ?? s['subject'] ?? 'Untitled')
          .toString();

      // teacher_book_content: list with hierarchyID & hierarchyName
      final tbc = (s['teacher_book_content'] as List?) ?? const [];

      int firstCount = 0;
      int secondCount = 0;
      String firstLabel = 'Level 1';
      String secondLabel = 'Level 2';

      for (final row in tbc) {
        if (row is! Map) continue;
        final level = row['hierarchyLevel'];
        String name = (row['hierarchyName'] ?? '').toString().trim();

        if (level == 1) {
          firstCount++;
          if (name.isNotEmpty) {
            firstLabel = (firstCount > 1 && !name.endsWith('s'))
                ? '${name}S'
                : name;
          }
        } else if (level == 2) {
          secondCount++;
          if (name.isNotEmpty) {
            secondLabel = (secondCount > 1 && !name.endsWith('s'))
                ? '${name}S'
                : name;
          }
        }
      }

      // Image can be absolute URL, relative storage path ("Subject/...png"), or asset
      final rawImage = (s['image'] ?? '').toString().trim();
      final iconPath = _resolveImagePath(rawImage);

      result.add(
        ClassProgressItem(
          title: title,
          firstHierarchy: firstCount,
          secondHierarchy: secondCount,
          firstHierarchyLabel: firstLabel,
          secondHierarchyLabel: secondLabel,
          progress: 0.6, // temporary default
          iconAsset: iconPath, // asset or URL; card handles both
          accent: Colors.blueAccent, // fallback; card computes dominant color
        ),
      );
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    double clampNum(double v, double min, double max) =>
        v < min ? min : (v > max ? max : v);

    final double sp = clampNum(w * 0.05, 0, 3);

    final bodyPadH = clampNum(w * 0.07, 20, 32);
    final bodyPadV = clampNum(w * 0.04, 16, 28);

    final learnersProfiles = (_data?['learners_profile'] as List?) ?? [];

    final viewInset = MediaQuery.of(context).padding.bottom;
    const navBarHeight = 88.0; // <-- FancyStudentNavBar’s actual height
    final bottomGap = navBarHeight + viewInset + 24.0;

    final usedAccents = <int>{};

    return StudentGlobalLayout(
      useScaffold: false,
      useSafeArea: false,
      header: GlobalAppBar(
        // render your app bar as a header widget
        title: 'Home',
        onNotificationsTap: () => StudentTabs.of(context).setIndex(3),
        onProfileTap: () {
          final s = _data?['student'];
          if (s is Map && s.isNotEmpty) {
            Navigator.pushNamed(
              context,
              AppRoutes.profilePage,
              arguments: {'student': s},
            );
          }
        },
      ),
      padding: EdgeInsets.symmetric(horizontal: sp),
      onRefresh: (_token != null && _uid != null)
          ? () => _safeLoad(_token!, _uid!)
          : null,
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : (_error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {
                            if (_token != null && _uid != null) {
                              _safeLoad(_token!, _uid!);
                            }
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : (_ready
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // === Welcome Row (NON-SCROLLABLE) ===
                            Padding(
                              padding: EdgeInsets.fromLTRB(
                                bodyPadH,
                                bodyPadV,
                                bodyPadH,
                                12, // keep your 12px spacing after welcome
                              ),
                              child: Row(
                                children: [
                                  const CircleAvatar(
                                    radius: 26,
                                    backgroundColor: Color(0xFFF1F3F6),
                                    backgroundImage: AssetImage(
                                      'assets/images/student-home/default-avatar-female.png',
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Welcome $_welcomeFirstName.',
                                        style: GoogleFonts.poppins(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 4,
                                        children: learnersProfiles.isNotEmpty
                                            ? learnersProfiles.map<Widget>((
                                                lp,
                                              ) {
                                                if (lp is Map &&
                                                    lp['learners_types']
                                                        is Map) {
                                                  final typeName =
                                                      (lp['learners_types']['name'] ??
                                                              '')
                                                          .toString();
                                                  return Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 10,
                                                          vertical: 6,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.blue
                                                          .withOpacity(0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            999,
                                                          ),
                                                      border: Border.all(
                                                        color: Colors.blue
                                                            .withOpacity(0.25),
                                                      ),
                                                    ),
                                                    child: Text(
                                                      "$typeName Learner",
                                                      style:
                                                          GoogleFonts.poppins(
                                                            fontSize: 12,
                                                            color: Colors
                                                                .blue[800],
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                    ),
                                                  );
                                                }
                                                return const SizedBox.shrink();
                                              }).toList()
                                            : [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 6,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey
                                                        .withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          999,
                                                        ),
                                                    border: Border.all(
                                                      color: Colors.grey
                                                          .withOpacity(0.25),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    'No Learner Type',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 12,
                                                      color: Colors.grey[700],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // === Badges Row (NON-SCROLLABLE) ===
                            Padding(
                              padding: EdgeInsets.fromLTRB(
                                bodyPadH,
                                0,
                                bodyPadH,
                                20, // keep your 20px spacing after badges
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                        color: Colors.orange.withOpacity(0.25),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.local_fire_department_outlined,
                                          size: 14,
                                          color: Colors.orange,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '7 day streak',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: Colors.orange,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFB3E5FC),
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                        color: const Color(0xFF81D4FA),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.water_drop_outlined,
                                          size: 14,
                                          color: Color(0xFF0288D1),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Level 5',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: Color(0xFF0288D1),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // === Scrollable content below ===
                            Expanded(
                              child: ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: EdgeInsets.fromLTRB(
                                  bodyPadH,
                                  0, // content starts right after badges' 20px spacer
                                  bodyPadH,
                                  bodyPadV,
                                ),
                                children: [
                                  // === Assignments ===
                                  CardsList<AssignmentItem>(
                                    headerTitle: 'My Assignments',
                                    headerIcon:
                                        'assets/images/student-home/my-assignments-vector.png',
                                    items: assignments,
                                    variant: CardVariant.assignment,
                                    ctaLabel: 'View All Assignments',
                                    onCta: () {
                                      /* navigate */
                                    },
                                    onAssignmentTap: (a) {
                                      Navigator.pushNamed(
                                        context,
                                        AppRoutes.quizInfo,
                                        arguments: {
                                          'title': a.title,
                                          'subject': a.subject,
                                          'date': a.date,
                                          'duration': a.duration,
                                          'type': a.type,
                                        },
                                      );
                                    },
                                  ),

                                  const SizedBox(height: 20),

                                  // === Class Progress ===
                                  CardsList<ClassProgressItem>(
                                    headerTitle: 'Class Progress',
                                    headerIcon:
                                        'assets/images/student-home/class-progress-vector.png',
                                    items: classes,
                                    variant: CardVariant.progress,
                                    ctaLabel: 'View All Classes',
                                    onCta: _goToClasses,
                                  ),

                                  const SizedBox(height: 20),

                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.access_time_outlined,
                                        color: Colors.black87,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Quick Actions',
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),

                                  Row(
                                    children: [
                                      Expanded(
                                        child: QuickActionTile(
                                          iconAsset:
                                              'assets/images/student-home/lessons-vector.png',
                                          label: 'Lessons',
                                          onTap: () {
                                            /* navigate */
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: QuickActionTile(
                                          iconAsset:
                                              'assets/images/student-home/assignments.png',
                                          label: 'Assignments',
                                          onTap: () {
                                            /* navigate */
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),

                                  Row(
                                    children: [
                                      Expanded(
                                        child: QuickActionTile(
                                          iconAsset:
                                              'assets/images/student-home/classes-quickactions.png',
                                          label: 'Classes',
                                          onTap: () {
                                            /* navigate */
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: QuickActionTile(
                                          iconAsset:
                                              'assets/images/student-home/leaderboards-quickactions.png',
                                          label: 'Assignments',
                                          onTap: () {
                                            /* navigate */
                                          },
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 12),
                                  // keep your extra bottom space so last item isn't hidden by navbar
                                  SizedBox(height: bottomGap - 100),
                                ],
                              ),
                            ),
                          ],
                        )
                      : const Center(child: CircularProgressIndicator()))),
    );
  }
}
