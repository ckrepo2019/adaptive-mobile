import 'package:flutter/material.dart';
import 'package:flutter_lms/controllers/api_response.dart';
import 'package:flutter_lms/controllers/student/student_class.dart';
import 'package:flutter_lms/utils/utils.dart'; // ScheduleUtils, NameUtils, MediaUtils (barrel)
import 'package:flutter_lms/widgets/app_bar.dart';
import 'package:flutter_lms/views/utilities/layouts/global_layout.dart';
import 'package:flutter_lms/widgets/global_chip.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_lms/widgets/global_subject_widget.dart';
import 'package:flutter_lms/config/routes.dart';
import 'package:flutter_lms/views/student/tabs/student_tabs.dart';

class StudentClassPage extends StatefulWidget {
  const StudentClassPage({super.key});

  @override
  State<StudentClassPage> createState() => _StudentClassPageState();
}

class _StudentClassPageState extends State<StudentClassPage> {
  bool _loading = true;
  String? _error;

  // raw from backend
  List<dynamic> _subjects = const [];
  List<dynamic> _subjectsWithUnits = const [];
  // merged (de-duplicated) subjects, preferring entries with units
  List<Map<String, dynamic>> _mergedSubjects = const [];

  void _goHome() => StudentTabs.of(context).setIndex(0);

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch({String? query}) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final ApiResponse<Map<String, dynamic>> resp =
        await StudentClassController.fetchClasses(query: query);

    if (!mounted) return;

    if (resp.success) {
      final subjects = (resp.data?['subjects'] as List<dynamic>? ?? const []);
      final subjectsWithUnits =
          (resp.data?['subjects_with_units'] as List<dynamic>? ?? const []);

      final Map<String, Map<String, dynamic>> merged = {};

      String keyOf(Map<String, dynamic> m) {
        final id = m['id'] ?? m['subject_id'];
        if (id != null) return 'id:$id';
        final name = (m['subject_name'] ?? '').toString();
        return 'name:$name';
      }

      for (final e in subjects) {
        final m = Map<String, dynamic>.from(e as Map);
        merged[keyOf(m)] = m;
      }
      for (final e in subjectsWithUnits) {
        final m = Map<String, dynamic>.from(e as Map);
        merged[keyOf(m)] = m; // prefer richer entry
      }

      final result = merged.values.toList()
        ..sort(
          (a, b) => (a['subject_name'] ?? '')
              .toString()
              .toLowerCase()
              .compareTo((b['subject_name'] ?? '').toString().toLowerCase()),
        );

      setState(() {
        _subjects = subjects;
        _subjectsWithUnits = subjectsWithUnits;
        _mergedSubjects = List<Map<String, dynamic>>.from(result);
        _loading = false;
      });
    } else {
      setState(() {
        _error = resp.message ?? 'Failed to load classes';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: GlobalAppBar(
        // <— set here
        title: 'Classes',
        onNotificationsTap: () {}, // wire as needed
        onProfileTap: () {},
      ),
      backgroundColor: Colors.white,
      body: StudentGlobalLayout(
        onRefresh: () => _fetch(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== Chips Row + Add Button =====
            Row(
              children: [
                const CustomChip(
                  backgroundColor: Colors.black,
                  textColor: Colors.white,
                  borderColor: Colors.black54,
                  chipTitle: 'Current',
                  iconData: Icons.access_time,
                ),
                SizedBox(width: w * 0.02),
                const CustomChip(
                  backgroundColor: Colors.white,
                  textColor: Colors.black54,
                  borderColor: Colors.black54,
                  chipTitle: 'Archived',
                  iconData: Icons.archive_outlined,
                ),
                const Spacer(),
                InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Get.toNamed(AppRoutes.studentJoinClass);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: w * 0.03,
                      vertical: h * 0.008,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: const Color(0xFF234EF4),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.add, size: w * 0.04, color: Colors.white),
                        SizedBox(width: w * 0.015),
                        Text(
                          'Add Class',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: w * 0.035,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: h * 0.02),

            // ===== Subject List (merged) =====
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : (_error != null)
                  ? Center(
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    )
                  : _mergedSubjects.isEmpty
                  ? const Center(child: Text('No classes found.'))
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: _mergedSubjects.length,
                      itemBuilder: (context, index) {
                        final m = _mergedSubjects[index];

                        final subject = (m['subject_name'] ?? '').toString();
                        final code = (m['subject_code'] ?? 'No code')
                            .toString();

                        final sched = (m['schedule'] is List)
                            ? (m['schedule'] as List)
                            : const [];
                        final timeStr = ScheduleUtils.formatSchedule(sched);

                        final teacher = NameUtils.formatTeacher(m['teacher']);
                        final img = MediaUtils.pickImageUrl(m);

                        // --- fallback if missing/null ---
                        final safeImg = (img != null && img.trim().isNotEmpty)
                            ? img
                            : 'assets/images/default-images/default-classes.jpg';

                        return GlobalSubjectWidget(
                          subject: subject.isEmpty ? 'Untitled' : subject,
                          classCode: code,
                          time:
                              timeStr, // e.g. "Today, Monday - Friday • 8:00–9:30 AM"
                          teacherName: teacher,
                          imageUrl: safeImg,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
