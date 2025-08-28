import 'package:flutter/material.dart';
import 'package:flutter_lms/widgets/cards_list.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_lms/config/constants.dart';
import 'package:flutter_lms/config/routes.dart';
import 'package:flutter_lms/controllers/api_response.dart';
import 'package:flutter_lms/controllers/student/student_home.dart';

import 'package:flutter_lms/models/items.dart';
import 'package:flutter_lms/views/student/student_global_layout.dart';
import 'package:flutter_lms/widgets/app_bar.dart';

class StudentAssignmentPage extends StatefulWidget {
  final String? token;
  final String? uid;

  const StudentAssignmentPage({super.key, this.token, this.uid});

  @override
  State<StudentAssignmentPage> createState() => _StudentAssignmentPageState();
}

class _StudentAssignmentPageState extends State<StudentAssignmentPage> {
  bool _loading = true;
  String? _error;
  List<AssignmentItem> _items = [];

  String? _token;
  String? _uid;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    _token = widget.token ?? await _resolveTokenFromPrefs();
    _uid = widget.uid ?? await _resolveUidFromPrefs();

    if (_token == null || _uid == null) {
      setState(() {
        _loading = false;
        _error = 'Missing credentials. Please re-login.';
      });
      return;
    }
    await _fetchAllAssessments(_token!, _uid!);
  }

  Future<String?> _resolveTokenFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<String?> _resolveUidFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('uid');
  }

  Future<void> _fetchAllAssessments(String token, String uid) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final ApiResponse<Map<String, dynamic>> resp =
        await StudentHomeController.fetchStudentHome(token: token, uid: uid);

    if (!(resp.success && resp.data != null)) {
      setState(() {
        _loading = false;
        _error = resp.message ?? 'Failed to load assignments.';
        _items = const [];
      });
      return;
    }

    final raw = resp.data!;
    final subjects = (raw['subjects'] as List?) ?? const [];

    // Build flat list of AssignmentItem from all subjects' assessments
    final List<_AssessRow> rows = [];
    for (final s in subjects) {
      if (s is! Map) continue;

      final subjectName =
          (s['subject_name'] ??
                  s['subject'] ??
                  s['subject_code'] ??
                  s['code'] ??
                  'Subject')
              .toString();

      final assessments = (s['assessments'] as List?) ?? const [];
      for (final a in assessments) {
        if (a is! Map<String, dynamic>) continue;

        final title = (a['title'] ?? 'Assessment').toString();
        final dateLabel = _assessmentStartLabel(a);
        final durLabel = _assessmentDuration(a);

        // Decide "type" label similar to StudentHomePage
        String type = 'Assessment';
        final desc = (a['description'] ?? '').toString().trim();
        if (desc.isNotEmpty) {
          type = desc.length > 24 ? '${desc.substring(0, 24)}…' : desc;
        } else {
          final Map<String, dynamic>? totals = (a['totals'] is Map)
              ? Map<String, dynamic>.from(a['totals'] as Map)
              : null;
          final int q = _asNum(totals?['questions'])?.toInt() ?? 0;
          type = q > 0 ? 'Quiz' : 'Assessment';
        }

        final subjectIcon = _resolveImagePath(
          ((s['image'] ?? '').toString().trim()),
        );

        rows.add(
          _AssessRow(
            item: AssignmentItem(
              title: title,
              subject: subjectName,
              date: dateLabel,
              duration: durLabel,
              type: type,
              assessment: a,
              subjectData: Map<String, dynamic>.from(s),
              subjectIcon: subjectIcon,
            ),
            when: _assessmentStartDate(a) ?? _parseDateTime(a['created_at']),
          ),
        );
      }
    }

    // Newest first
    rows.sort((x, y) {
      final ax = x.when;
      final by = y.when;
      if (ax == null && by == null) return 0;
      if (ax == null) return 1;
      if (by == null) return -1;
      return by.compareTo(ax);
    });

    setState(() {
      _loading = false;
      _error = null;
      _items = rows.map((e) => e.item).toList();
    });
  }

  // ---------------- Helpers (mirrors StudentHomePage) ----------------

  DateTime? _parseDateTime(Object? s) {
    if (s == null) return null;
    var raw = s.toString().trim();
    if (raw.isEmpty) return null;
    if (raw.contains(' ') && !raw.contains('T')) {
      raw = raw.replaceFirst(' ', 'T');
    }
    try {
      return DateTime.parse(raw);
    } catch (_) {
      return null;
    }
  }

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

  String _humanDateLabel(DateTime target, {DateTime? now}) {
    final DateTime nowLocal = (now ?? DateTime.now()).toLocal();
    final DateTime dNow = DateTime(nowLocal.year, nowLocal.month, nowLocal.day);
    final DateTime dTar = DateTime(target.year, target.month, target.day);
    final int dayDiff = dNow.difference(dTar).inDays;

    if (dayDiff == 0) return 'Today';
    if (dayDiff == 1) return 'Yesterday';
    if (dayDiff == -1) return 'Tomorrow';

    if (dayDiff > 0) {
      if (dayDiff < 7) return '$dayDiff day${dayDiff == 1 ? '' : 's'} ago';
      final int weeks = dayDiff ~/ 7;
      if (weeks == 1) return '1 week ago';
      if (weeks == 2) return '2 weeks ago';
      if (weeks == 3) return '3 weeks ago';
      if (weeks >= 4 && dayDiff < 60) return 'a month ago';
      return _formatAbsoluteDate(target);
    }

    final int ahead = -dayDiff;
    if (ahead < 7) return 'in $ahead day${ahead == 1 ? '' : 's'}';
    final int weeksAhead = ahead ~/ 7;
    if (weeksAhead == 1) return 'in 1 week';
    if (weeksAhead == 2) return 'in 2 weeks';
    if (weeksAhead == 3) return 'in 3 weeks';
    if (weeksAhead >= 4 && ahead < 60) return 'in a month';
    return _formatAbsoluteDate(target);
  }

  String _assessmentDuration(Map<String, dynamic> a) {
    final aw = a['active_window'];
    if (aw is Map) {
      final int? days = _asNum(aw['days'])?.toInt();
      final int? hours = _asNum(aw['hours'])?.toInt();
      if (days != null && days > 0 && hours != null) {
        return '${days}D ${hours}H';
      }
      if (days != null && days > 0) return '${days}D';
      if (hours != null) return '${hours}H';
    }
    return '—';
  }

  String _assessmentStartLabel(Map<String, dynamic> a) {
    final aw = a['active_window'];
    DateTime? dt;
    if (aw is Map) dt = _parseDateTime(aw['start']);
    dt ??= _parseDateTime(a['created_at']);
    if (dt == null) return '—';
    return _humanDateLabel(dt.toLocal());
  }

  DateTime? _assessmentStartDate(Map<String, dynamic> a) {
    final aw = a['active_window'];
    DateTime? dt;
    if (aw is Map) dt = _parseDateTime(aw['start']);
    dt ??= _parseDateTime(a['created_at']);
    return dt;
  }

  num? _asNum(dynamic v) {
    if (v == null) return null;
    if (v is num) return v;
    return num.tryParse(v.toString());
  }

  String _resolveImagePath(String p) {
    if (p.isEmpty) return '';
    final lower = p.toLowerCase();
    if (lower.startsWith('http://') || lower.startsWith('https://')) return p;

    String originFromBase(String base) {
      final u = Uri.parse(base);
      final port = u.hasPort ? ':${u.port}' : '';
      return '${u.scheme}://${u.host}$port';
    }

    final origin = originFromBase(AppConstants.baseURL);
    if (p.contains('/')) return '$origin/storage/$p';
    return p;
  }

  // ---------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return StudentGlobalLayout(
      useScaffold: false,
      useSafeArea: false,
      header: GlobalAppBar(
        title: 'Assignments',
        onNotificationsTap: () {},
        onProfileTap: () {},
      ),
      onRefresh: (_token != null && _uid != null)
          ? () => _fetchAllAssessments(_token!, _uid!)
          : null,
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : (_error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _error!,
                            style: GoogleFonts.poppins(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () {
                              if (_token != null && _uid != null) {
                                _fetchAllAssessments(_token!, _uid!);
                              }
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    // ✅ makes body scrollable
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(top: 12, bottom: 12),
                    child: SafeArea(
                      top: false,
                      child: Column(
                        children: [
                          CardsList<AssignmentItem>(
                            items: _items,
                            variant: CardVariant.assignment,
                            onAssignmentTap: (a) {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.quizInfo,
                                arguments: a.assessment,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  )),
    );
  }
}

class _AssessRow {
  final AssignmentItem item;
  final DateTime? when;
  const _AssessRow({required this.item, required this.when});
}
