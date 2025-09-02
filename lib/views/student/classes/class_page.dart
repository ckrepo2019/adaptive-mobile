import 'package:flutter/material.dart';
import 'package:flutter_lms/config/routes.dart';
import 'package:flutter_lms/controllers/api_response.dart';
import 'package:flutter_lms/controllers/student/student_class.dart';
import 'package:flutter_lms/views/utilities/layouts/global_layout.dart';
import 'package:flutter_lms/widgets/app_bar.dart';
import 'package:flutter_lms/widgets/class_progress_card.dart';
import 'package:flutter_lms/widgets/students_count_card.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_lms/widgets/cards_list.dart';

class SubjectClassPage extends StatefulWidget {
  const SubjectClassPage({super.key});

  @override
  State<SubjectClassPage> createState() => _SubjectClassPageState();
}

class _SubjectClassPageState extends State<SubjectClassPage> {
  int? subjectId;

  bool _loading = true;
  String? _error;

  // Response fields
  List<dynamic> _subjects = const [];
  Map<String, dynamic>? _studentUser;
  List<dynamic> _classmates = const [];
  int _studentsCount = 0;
  List<dynamic> _classmateUnits = const [];

  bool _didArgs = false;

  // New: assessments & first content
  List<Map<String, dynamic>> _assessments = const [];
  Map<String, dynamic>? _firstContent;

  static const _tabs = [
    ("Let's Learn", Icons.menu_book_outlined),
    ("Badges", Icons.emoji_events_outlined),
    ("Grades", Icons.grade_outlined),
    ("Insights", Icons.insights_outlined),
  ];

  static const _bannerData = [
    ("Unit 1", "Algebraic Expressions", Icons.menu_book_outlined),
    ("Badges", "Earn and track achievements", Icons.emoji_events_outlined),
    ("Grades", "Your latest performance", Icons.grade_outlined),
    ("Insights", "Progress & time on task", Icons.insights_outlined),
  ];

  int _activeTab = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didArgs) return;
    _didArgs = true;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map && args['subject_ID'] != null) {
      final raw = args['subject_ID'];
      subjectId = raw is int ? raw : int.tryParse(raw.toString());
    }

    if (subjectId == null || subjectId! <= 0) {
      setState(() {
        _loading = false;
        _error = 'No subject ID provided';
      });
      return;
    }

    _fetch();
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final ApiResponse<Map<String, dynamic>> resp =
        await StudentClassController.fetchClassSubject(subjectId: subjectId!);

    if (!mounted) return;

    if (resp.success) {
      final data = resp.data ?? {};
      setState(() {
        _subjects = (data['subjects'] as List?) ?? const [];
        _studentUser = (data['studentUser'] as Map?)?.cast<String, dynamic>();
        _classmates = (data['listofStudents'] as List?) ?? const [];
        _studentsCount = (data['students_count'] as int?) ?? 0;
        _classmateUnits = (data['classmateunits'] as List?) ?? const [];

        _assessments = (data['assessments'] is List)
            ? List<Map<String, dynamic>>.from(
                (data['assessments'] as List).map(
                  (e) => e is Map<String, dynamic>
                      ? e
                      : Map<String, dynamic>.from(e as Map),
                ),
              )
            : const [];

        _firstContent = (data['first_content'] is Map)
            ? Map<String, dynamic>.from(data['first_content'])
            : null;

        _loading = false;
      });
    } else {
      setState(() {
        _error = resp.message ?? 'Failed to load subject details';
        _loading = false;
      });
    }
  }

  // ---- helpers ----
  String _teacherName(Map<String, dynamic> s) {
    final first = (s['firstname'] ?? '').toString().trim();
    final mid = (s['middlename'] ?? '').toString().trim();
    final last = (s['lastname'] ?? '').toString().trim();
    final parts = [
      first,
      if (mid.isNotEmpty) mid,
      last,
    ].where((e) => e.isNotEmpty).toList();
    return parts.isNotEmpty ? parts.join(' ') : '—';
  }

  void _goToOverview() {
    if (subjectId == null || subjectId! <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Missing subject_ID')));
      return;
    }

    final String subjectName = (_subjects.isNotEmpty && _subjects.first is Map)
        ? ((_subjects.first as Map)['subject_name']?.toString() ?? '').trim()
        : '';
    final String subjectCode = (_subjects.isNotEmpty && _subjects.first is Map)
        ? ((_subjects.first as Map)['subject_code']?.toString() ?? '').trim()
        : '';

    Navigator.of(context).pushNamed(
      AppRoutes.classSubjectOverview,
      arguments: {
        'subject_ID': subjectId,
        'subject_name': subjectName,
        'subject_code': subjectCode,
      },
    );
  }

  // Parse "2025-03-11 10:23:11" or ISO with/without Z
  DateTime? _parseDateTime(Object? s) {
    if (s == null) return null;
    var raw = s.toString().trim();
    if (raw.isEmpty) return null;
    // convert "YYYY-MM-DD HH:MM:SS" => "YYYY-MM-DDTHH:MM:SS"
    if (raw.contains(' ') && !raw.contains('T')) {
      raw = raw.replaceFirst(' ', 'T');
    }
    try {
      return DateTime.parse(raw);
    } catch (_) {
      return null;
    }
  }

  // Format a duration like "1h 30m", "45m", "2d 3h"
  String _formatDuration(Duration d) {
    if (d.inMinutes < 1) return '0m';
    final days = d.inDays;
    final hours = d.inHours % 24;
    final mins = d.inMinutes % 60;
    final parts = <String>[];
    if (days > 0) parts.add('${days}d');
    if (hours > 0) parts.add('${hours}h');
    if (mins > 0 && days == 0) parts.add('${mins}m'); // keep it compact
    return parts.join(' ');
  }

  // Pull a nice duration string from an assessment row
  String _assessmentDuration(Map<String, dynamic> a) {
    final aw = a['active_window'];
    if (aw is Map) {
      final int? days = (aw['days'] is int)
          ? aw['days'] as int
          : int.tryParse(aw['days']?.toString() ?? '');
      final int? hours = (aw['hours'] is int)
          ? aw['hours'] as int
          : int.tryParse(aw['hours']?.toString() ?? '');

      if (days != null && days > 0 && hours != null) {
        // both days and hours
        return '${days}D ${hours}H';
      } else if (days != null && days > 0) {
        // only days
        return '${days}D';
      } else if (hours != null) {
        // only hours (or days == 0)
        return '${hours}H';
      }
    }
    return '—';
  }

  // Prefer active-window start; else created_at; show human label.
  String _assessmentStartLabel(Map<String, dynamic> a) {
    final aw = a['active_window'];
    DateTime? dt;
    if (aw is Map) dt = _parseDateTime(aw['start']);
    dt ??= _parseDateTime(a['created_at']);
    if (dt == null) return '—';
    return _humanDateLabel(dt.toLocal());
  }

  // --- helpers ---

  // Returns: Today / Yesterday / Tomorrow / 3 days ago / 1 week ago / 2 weeks ago / a month ago
  // Otherwise: January 1, 2025
  String _humanDateLabel(DateTime target, {DateTime? now}) {
    final DateTime nowLocal = (now ?? DateTime.now()).toLocal();

    // Compare by date (ignore time)
    final DateTime dNow = DateTime(nowLocal.year, nowLocal.month, nowLocal.day);
    final DateTime dTar = DateTime(target.year, target.month, target.day);

    final int dayDiff = dNow.difference(dTar).inDays; // positive = past

    // Exact buckets
    if (dayDiff == 0) return 'Today';
    if (dayDiff == 1) return 'Yesterday';
    if (dayDiff == -1) return 'Tomorrow';

    // Past
    if (dayDiff > 0) {
      if (dayDiff < 7) return '$dayDiff day${dayDiff == 1 ? '' : 's'} ago';
      final int weeks = dayDiff ~/ 7; // floor
      if (weeks == 1) return '1 week ago';
      if (weeks == 2) return '2 weeks ago';
      if (weeks == 3) return '3 weeks ago';
      if (weeks >= 4 && dayDiff < 60) return 'a month ago'; // simple bucket
      // Fallback to absolute
      return _formatAbsoluteDate(target);
    }

    // Future (dayDiff < 0)
    final int ahead = -dayDiff;
    if (ahead < 7) return 'in $ahead day${ahead == 1 ? '' : 's'}';
    final int weeksAhead = ahead ~/ 7;
    if (weeksAhead == 1) return 'in 1 week';
    if (weeksAhead == 2) return 'in 2 weeks';
    if (weeksAhead == 3) return 'in 3 weeks';
    if (weeksAhead >= 4 && ahead < 60) return 'in a month';
    // Fallback to absolute
    return _formatAbsoluteDate(target);
  }

  // Absolute like "January 1, 2025"
  String _formatAbsoluteDate(DateTime dt) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final m = months[dt.month - 1];
    return '$m ${dt.day}, ${dt.year}';
  }

  // Friendly fallback for title
  String _assessmentTitle(Map<String, dynamic> a) {
    final t = (a['title'] ?? '').toString().trim();
    if (t.isNotEmpty) return t;
    final ty = (a['type'] ?? '').toString().trim();
    return ty.isNotEmpty ? ty : 'Assessment';
  }

  @override
  Widget build(BuildContext context) {
    final subject = (_subjects.isNotEmpty && _subjects.first is Map)
        ? Map<String, dynamic>.from(_subjects.first as Map)
        : const <String, dynamic>{};

    final subjectName = (subject['subject_name'] ?? 'Subject')
        .toString()
        .trim();
    final code = (subject['code'] ?? '—').toString().trim();
    final subjectCode = (subject['subject_code'] ?? '—').toString().trim();
    final teacher = subject.isEmpty ? '—' : _teacherName(subject);

    final gradeLabel =
        (_studentUser?['name'] ?? _studentUser?['yearlevel'] ?? 'Grade 7')
            .toString();

    final sched = (subject['schedule'] is List)
        ? subject['schedule'] as List
        : [];
    String scheduleText;
    if (sched.isEmpty) {
      scheduleText = 'Mon, Wed, Fri · 9:00 AM';
    } else {
      final names = sched
          .map((e) => (e is Map ? (e['day_name'] ?? '') : '').toString())
          .where((s) => s.isNotEmpty)
          .toList();
      scheduleText = names.isNotEmpty ? names.join(', ') : 'Schedule';
      final time0 =
          (sched.first is Map ? (sched.first['start_time'] ?? '') : '')
              .toString();
      if (time0.isNotEmpty) scheduleText = '$scheduleText · $time0';
    }

    // --- Show only assessments with NO score yet ---
    final pendingAssessments = _assessments
        .where(
          (a) => (a['student'] is Map) ? (a['student']['score'] == null) : true,
        )
        .toList();

    return StudentGlobalLayout(
      padding: const EdgeInsets.only(top: 12, bottom: 12),
      appBar: GlobalAppBar(
        title: subjectCode.isEmpty ? 'Subject Name' : subjectCode,
        showBack: true,
      ),
      onRefresh: _fetch,
      child: _loading
          ? const SizedBox(
              height: 280,
              child: Center(child: CircularProgressIndicator()),
            )
          : (_error != null)
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 120),
              child: Center(
                child: Text(
                  _error!,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
          : ListView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: EdgeInsets.zero,
              children: [
                // ---- Title + subtitle (keep padded) ----
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _InfoHeaderCard(code: code, scheduleText: scheduleText),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Expanded(
                            child: ClassProgressCard(
                              value: 0.10,
                              size: 70,
                              strokeWidth: 5,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                final subjectName =
                                    (subject['subject_name'] ?? '').toString();
                                Navigator.of(context).pushNamed(
                                  AppRoutes.myClassmates,
                                  arguments: {
                                    'subjectName': subjectName,
                                    'classmates': _classmates,
                                  },
                                );
                              },
                              child: StudentsCountCard(
                                count: _studentsCount,
                                iconSize: 40,
                                padding: 22,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                    ],
                  ),
                ),

                // ---- Action chips ----
                SizedBox(
                  height: 44,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(width: 16),
                        ...List.generate(_tabs.length, (i) {
                          final (label, icon) = _tabs[i];
                          final filled = i == _activeTab;
                          return Padding(
                            padding: EdgeInsets.only(
                              right: i == _tabs.length - 1 ? 0 : 8,
                            ),
                            child: GestureDetector(
                              onTap: () {
                                if (i == 0) {
                                  _goToOverview();
                                } else {
                                  setState(() => _activeTab = i);
                                }
                              },
                              child: _ActionChip(
                                text: label,
                                icon: icon,
                                filled: filled,
                              ),
                            ),
                          );
                        }),
                        const SizedBox(width: 16),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ---- Swipeable banner; linked to chips ----
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    height: 190,
                    child: Column(
                      children: [
                        GestureDetector(
                          onHorizontalDragEnd: (details) {
                            final v = details.primaryVelocity ?? 0;
                            if (v < 0 && _activeTab < _bannerData.length - 1) {
                              setState(() => _activeTab += 1);
                            } else if (v > 0 && _activeTab > 0) {
                              setState(() => _activeTab -= 1);
                            }
                          },
                          child: SizedBox(
                            height: 150,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 280),
                              switchInCurve: Curves.easeOut,
                              switchOutCurve: Curves.easeIn,
                              transitionBuilder: (child, anim) =>
                                  FadeTransition(opacity: anim, child: child),
                              child: Builder(
                                key: ValueKey(_activeTab),
                                builder: (_) {
                                  if (_activeTab == 0) {
                                    final hasCourseware =
                                        _firstContent != null &&
                                        (_firstContent?['name']
                                                    ?.toString()
                                                    .trim()
                                                    .isNotEmpty ==
                                                true ||
                                            _firstContent?['hierarchy_name']
                                                    ?.toString()
                                                    .trim()
                                                    .isNotEmpty ==
                                                true);

                                    final String unitTitle = hasCourseware
                                        ? '${(_firstContent?['hierarchy_name'] ?? 'Unit').toString()} 1'
                                        : "Let's Learn";

                                    final String subtitle = hasCourseware
                                        ? (_firstContent?['name']?.toString() ??
                                              '—')
                                        : 'No courseware published yet!';

                                    return InkWell(
                                      onTap: hasCourseware
                                          ? _goToOverview
                                          : null,
                                      child: _UnitBannerCard(
                                        unitTitle: unitTitle,
                                        subtitle: subtitle,
                                      ),
                                    );
                                  } else {
                                    final (title, sub, icon) =
                                        _bannerData[_activeTab];
                                    return InkWell(
                                      onTap: _goToOverview,
                                      child: _UnitBannerCard(
                                        unitTitle: title,
                                        subtitle: sub,
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(_bannerData.length, (i) {
                            final isActive = i == _activeTab;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              height: 7,
                              width: isActive ? 28 : 7,
                              decoration: BoxDecoration(
                                color: isActive
                                    ? Colors.black
                                    : Colors.black.withOpacity(.35),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                // ---- Assessments (padded) ----
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      if (pendingAssessments.isEmpty)
                        const _EmptyInfoCard(
                          text: 'Horay! No Assignments Left!',
                        )
                      else
                        CardsList<Map<String, dynamic>>(
                          headerTitle: '$subjectCode Assessments',
                          headerIcon: Icons.menu_book_outlined,
                          pillText: '${pendingAssessments.length} Pending',
                          items: pendingAssessments,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemBuilder: (ctx, item, i, _) {
                            final title = _assessmentTitle(item);
                            final description =
                                (item['description'] ?? 'Assessment')
                                    .toString();
                            final subtitle = description;

                            final leftDate = _assessmentStartLabel(item);
                            final duration = _assessmentDuration(item);

                            return GestureDetector(
                              onTap: () {
                                Navigator.of(context).pushNamed(
                                  AppRoutes.quizInfo,
                                  arguments: item,
                                );
                              },
                              child: _AssignmentCard(
                                title: title,
                                subtitle: subtitle,
                                metaLeft: leftDate,
                                metaRight: duration,
                              ),
                            );
                          },
                        ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

// ===== UI PARTIALS =====

class _InfoHeaderCard extends StatelessWidget {
  final String code;
  final String scheduleText;

  const _InfoHeaderCard({required this.code, required this.scheduleText});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(right: 18, top: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0x11000000)),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            height: 150,
            width: 180,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/images/default-images/default-female-teacher-class.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Class Code',
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    color: Colors.black45,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  code.isEmpty ? '—' : code,
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  scheduleText,
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool filled;

  const _ActionChip({
    required this.text,
    required this.icon,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = filled ? const Color(0xFF234EF4) : Colors.white;
    final fg = filled ? Colors.white : Colors.black54;
    final border = filled ? Colors.transparent : const Color(0x22000000);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: border),
        boxShadow: filled
            ? const [
                BoxShadow(
                  color: Color(0x1A234EF4),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ]
            : const [],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: fg),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: fg,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _UnitBannerCard extends StatelessWidget {
  final String unitTitle;
  final String subtitle;

  static const double _artWidth = 130;

  const _UnitBannerCard({required this.unitTitle, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF234FF5), Color(0xFF142E8F)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            width: _artWidth,
            height: 130,
            child: Image.asset(
              'assets/images/default-images/default-subject-unit.png',
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 34, 18, 16),
            child: DefaultTextStyle(
              style: GoogleFonts.poppins(color: Colors.white),
              child: Padding(
                padding: const EdgeInsets.only(right: _artWidth + 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      unitTitle,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.yellowAccent,
                      ),
                    ),
                    Text(
                      subtitle,
                      maxLines: 4,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      textWidthBasis: TextWidthBasis.parent,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AssignmentCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String metaLeft;
  final String metaRight;

  const _AssignmentCard({
    required this.title,
    required this.subtitle,
    required this.metaLeft,
    required this.metaRight,
  });

  Color _accentFromSeed(String seed) {
    final palette = <Color>[
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];
    final h = seed.hashCode;
    return palette[(h.abs()) % palette.length];
  }

  @override
  Widget build(BuildContext context) {
    const double kRadius = 14; // <- single source of truth
    final Color accent = _accentFromSeed(title.isEmpty ? subtitle : title);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(kRadius),
        border: Border.all(color: const Color(0x11000000)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      // Clip children to the same rounded shape so the stripe corners match
      child: ClipRRect(
        borderRadius: BorderRadius.circular(kRadius),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left color stripe
              Container(
                width: 4,
                decoration: const BoxDecoration(
                  // radius MUST match parent to avoid mismatch at corners
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(kRadius),
                    bottomLeft: Radius.circular(kRadius),
                  ),
                  // color is set below with foreground decoration
                ),
                foregroundDecoration: BoxDecoration(color: accent),
              ),

              // Main content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 12.5,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 16,
                            color: Colors.black54,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              metaLeft,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 12.5,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.timer_outlined,
                            size: 16,
                            color: Colors.black54,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            metaRight,
                            style: GoogleFonts.poppins(
                              fontSize: 12.5,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyInfoCard extends StatelessWidget {
  final String text;
  const _EmptyInfoCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x11000000)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFFE8F5E9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_outline,
              color: Color(0xFF4CAF50),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
